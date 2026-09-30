import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'package:Zentry/core/models/app_user.dart';
import 'package:Zentry/core/navigation/app_navigator.dart';
import 'package:Zentry/core/network/posts_api.dart';
import 'package:Zentry/features/chat/conversation_screen.dart';
import 'package:Zentry/features/home/widgets/backend_feed.dart'
    show showBackendCommentSheet;
import 'package:Zentry/features/profile/public_profile_screen.dart';

class NotificationService {
  NotificationService._();

  static final NotificationService instance = NotificationService._();

  // Canal general (logros, retos, actividad social) — sin cambios.
  static const _channelId = 'zentry_general';
  static const _channelName = 'Zentry';
  static const _channelDescription =
      'Logros, retos y actividad de tu cuenta Zentry';

  // Canal dedicado a mensajes de chat (Fase 4): distinto del general para
  // que el usuario pueda silenciar/ajustar uno sin afectar al otro.
  static const _messagesChannelId = 'zentry_messages';
  static const _messagesChannelName = 'Mensajes de Zentry';
  static const _messagesChannelDescription =
      'Notificaciones de nuevos mensajes y conversaciones.';

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;
  int _nextId =
      1000; // rango separado del id determinista de mensajes (conversationId)

  Future<void> init() async {
    if (_initialized || kIsWeb) return;

    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const darwinInit = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    await _plugin.initialize(
      const InitializationSettings(android: androidInit, iOS: darwinInit),
      onDidReceiveNotificationResponse: (response) {
        _handleTapPayload(response.payload);
      },
    );

    if (Platform.isAndroid) {
      const generalChannel = AndroidNotificationChannel(
        _channelId,
        _channelName,
        description: _channelDescription,
        importance: Importance.high,
      );
      const messagesChannel = AndroidNotificationChannel(
        _messagesChannelId,
        _messagesChannelName,
        description: _messagesChannelDescription,
        importance: Importance.high,
      );
      final androidPlugin = _plugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();
      await androidPlugin?.createNotificationChannel(generalChannel);
      await androidPlugin?.createNotificationChannel(messagesChannel);
      // Sólo se pide una vez por proceso: `init()` está protegido por
      // `_initialized` y se llama una sola vez desde `main.dart`.
      await androidPlugin?.requestNotificationsPermission();
    } else if (Platform.isIOS || Platform.isMacOS) {
      await _plugin
          .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin
          >()
          ?.requestPermissions(alert: true, badge: true, sound: true);
    }

    _initialized = true;

    // App abierta desde frío TOCANDO una notificación (proceso estaba
    // completamente terminado): hay que navegar en cuanto la UI esté lista.
    final launchDetails = await _plugin.getNotificationAppLaunchDetails();
    if (launchDetails?.didNotificationLaunchApp == true) {
      final payload = launchDetails!.notificationResponse?.payload;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _handleTapPayload(payload);
      });
    }
  }

  Future<void> show({
    required String title,
    required String body,
    String? payload,
  }) async {
    if (!_initialized || kIsWeb) return;

    const androidDetails = AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: _channelDescription,
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );
    const darwinDetails = DarwinNotificationDetails();

    await _plugin.show(
      _nextId++,
      title,
      body,
      const NotificationDetails(android: androidDetails, iOS: darwinDetails),
      payload: payload,
    );
  }

  /// Notificación local de un mensaje de chat nuevo (Fase 3/4). Usa
  /// [conversationId] como ID de notificación a propósito: un segundo
  /// mensaje de la misma conversación **reemplaza** la notificación anterior
  /// en vez de apilarse, evitando spam visual cuando llegan varios mensajes
  /// seguidos de la misma persona antes de que el usuario los revise.
  Future<void> showMessage({
    required int conversationId,
    required String senderName,
    required String body,
    String? payload,
  }) async {
    if (!_initialized || kIsWeb) return;

    final androidDetails = AndroidNotificationDetails(
      _messagesChannelId,
      _messagesChannelName,
      channelDescription: _messagesChannelDescription,
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
      styleInformation: BigTextStyleInformation(body),
    );
    const darwinDetails = DarwinNotificationDetails();

    await _plugin.show(
      conversationId,
      senderName,
      body,
      NotificationDetails(android: androidDetails, iOS: darwinDetails),
      payload: payload,
    );
  }

  /// Quita la notificación de una conversación (p. ej. al abrirla desde la
  /// bandeja de chats sin pasar por el tap de la notificación).
  Future<void> cancelMessageNotification(int conversationId) async {
    if (!_initialized || kIsWeb) return;
    await _plugin.cancel(conversationId);
  }

  /// Evita navegar dos veces por el mismo evento cuando FCM entrega el tap
  /// por más de una vía a la vez (p. ej. `getInitialMessage` +
  /// `onMessageOpenedApp` en un cold start — caso documentado de FCM).
  String? _lastHandledNotificationKey;

  void _handleTapPayload(String? payload) {
    if (payload == null || payload.isEmpty) return;
    try {
      final data = jsonDecode(payload);
      if (data is! Map) return;
      handleNotificationData(Map<String, dynamic>.from(data));
    } catch (e) {
      if (kDebugMode)
        debugPrint('[Zentry] payload de notificación inválido: $e');
    }
  }

  /// Punto único de navegación al tocar CUALQUIER notificación, venga de una
  /// notificación local (chat) o de FCM (Fase 8/9 del reporte). Centraliza el
  /// deep-link aquí para que ninguna otra parte de la app duplique esta
  /// lógica ni pueda mostrar dos navegaciones para el mismo evento.
  ///
  /// Contrato del payload (Fase 7): identifica el destino SIEMPRE por ids
  /// reales (`type`, `actorId`, `conversationId`/`postId`,
  /// `notificationId`), nunca por el nombre mostrado.
  void handleNotificationData(Map<String, dynamic> data) {
    final dedupeKey =
        data['notificationId']?.toString() ??
        data['conversationId']?.toString();
    if (dedupeKey != null && dedupeKey == _lastHandledNotificationKey) return;
    _lastHandledNotificationKey = dedupeKey;

    final navigator = appNavigatorKey.currentState;
    if (navigator == null) return;

    final type = data['type'] as String?;
    switch (type) {
      case 'like':
      case 'comment':
        _openPost(navigator, data);
      case 'follow':
      case 'friend_request':
      case 'friend_accept':
        _openProfile(navigator, data);
      case 'message':
        _openConversation(navigator, data);
      default:
        // Compatibilidad con notificaciones locales de chat previas a que
        // se añadiera el campo `type` (sólo llevaban `conversationId`).
        if (data.containsKey('conversationId')) {
          _openConversation(navigator, data);
        }
    }
  }

  void _openConversation(NavigatorState navigator, Map<String, dynamic> data) {
    final conversationId = (data['conversationId'] as num?)?.toInt();
    if (conversationId == null) return;
    final otherUserId = (data['otherUserId'] as num?)?.toInt();
    final otherUsername = data['otherUsername'] as String?;

    navigator.push(
      MaterialPageRoute(
        builder: (_) => ConversationScreen(
          conversationId: conversationId,
          otherUserId: otherUserId,
          otherUsername: otherUsername ?? '',
          otherDisplayName: data['otherDisplayName'] as String?,
          otherAvatarUrl: data['otherAvatarUrl'] as String?,
        ),
      ),
    );
  }

  /// Abre la publicación relacionada (like/reacción o comentario) mostrando
  /// la misma hoja de comentarios que usa el feed real. El backend sólo
  /// manda el id en el payload, así que primero se trae el post completo
  /// (`GET /api/core/posts/{id}`).
  Future<void> _openPost(
    NavigatorState navigator,
    Map<String, dynamic> data,
  ) async {
    final postId =
        (data['postId'] as num?)?.toInt() ??
        (data['relatedId'] as num?)?.toInt();
    if (postId == null) return;

    try {
      final post = await PostsApi.instance.getById(postId);
      final context = navigator.context;
      if (!context.mounted) return;
      showBackendCommentSheet(context, post);
    } catch (e) {
      if (kDebugMode) debugPrint('[Zentry] no se pudo abrir post $postId: $e');
    }
  }

  /// Abre el perfil de quien generó el evento (follow / solicitud / amistad
  /// aceptada). Se arma un [AppUser] mínimo con lo que trae el payload;
  /// `PublicProfileScreen` se encarga de completarlo desde el backend.
  void _openProfile(NavigatorState navigator, Map<String, dynamic> data) {
    final actorId = (data['actorId'] as num?)?.toInt();
    final username =
        (data['actorUsername'] ?? data['sourceUsername']) as String?;
    if (actorId == null || username == null || username.isEmpty) return;

    navigator.push(
      MaterialPageRoute(
        builder: (_) => PublicProfileScreen(
          user: AppUser(
            id: actorId,
            fullName: username,
            username: username,
            email: '',
            photoPath:
                (data['actorAvatarUrl'] ?? data['sourceAvatarUrl']) as String?,
          ),
        ),
      ),
    );
  }
}
