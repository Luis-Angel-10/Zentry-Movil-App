import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'package:Zentry/core/navigation/app_navigator.dart';
import 'package:Zentry/features/chat/conversation_screen.dart';

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
  int _nextId = 1000; // rango separado del id determinista de mensajes (conversationId)

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

  Future<void> show({required String title, required String body}) async {
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

  void _handleTapPayload(String? payload) {
    if (payload == null || payload.isEmpty) return;
    try {
      final data = jsonDecode(payload);
      if (data is! Map) return;
      final conversationId = (data['conversationId'] as num?)?.toInt();
      if (conversationId == null) return;
      final otherUserId = (data['otherUserId'] as num?)?.toInt();
      final otherUsername = data['otherUsername'] as String?;

      final navigator = appNavigatorKey.currentState;
      if (navigator == null) return;
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
    } catch (e) {
      if (kDebugMode) debugPrint('[Zentry] payload de notificación inválido: $e');
    }
  }
}
