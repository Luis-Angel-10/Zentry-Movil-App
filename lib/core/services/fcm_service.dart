import 'dart:async';
import 'dart:convert';
import 'dart:developer' as developer;

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import 'package:Zentry/core/network/realtime_client.dart';
import 'package:Zentry/core/services/notification_service.dart';

/// Handler de mensajes FCM en background/app terminada. Debe ser una función
/// de nivel superior (no un método de instancia): el motor de Flutter la
/// ejecuta en un isolate aparte, sin el estado del resto de la app.
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  try {
    await Firebase.initializeApp();
  } catch (_) {
    return; // Sin proyecto Firebase real configurado: nada que procesar.
  }
  await NotificationService.instance.init();
  await FcmService.showFromRemoteMessage(message);
}

/// Integración con Firebase Cloud Messaging.
///
/// Complementa (NO reemplaza) al WebSocket/STOMP de [RealtimeClient]: el WS
/// sigue siendo la vía de tiempo real mientras la app está en foreground y
/// con la conversación abierta; FCM cubre background, app cerrada, y
/// conversaciones que no están abiertas en este momento.
///
/// *** ESTADO REAL (ver reporte final) ***
/// El backend Zentry actual NO tiene ninguna infraestructura de FCM: sin
/// Firebase Admin SDK, sin entidad de device tokens, sin endpoint de
/// registro/borrado, sin servicio de envío de push. Este servicio deja listo
/// TODO el lado de Flutter (permisos, token, refresh, foreground/background/
/// cold start, deduplicación con WS, deep link) para el día en que el
/// backend agregue esos endpoints. Mientras tanto:
///   - si no existe `google-services.json`/`GoogleService-Info.plist` real,
///     `init()` falla de forma controlada y la app sigue funcionando
///     normalmente sólo con WebSocket + notificaciones locales;
///   - aunque Firebase esté configurado, la app NUNCA recibirá un push
///     real de otro usuario (like, comentario, mensaje, follow...) porque
///     ningún servicio del backend los envía todavía;
///   - `_syncTokenWithBackend`/`_deactivateToken` quedan documentados como
///     no-op explícito hasta que exista el endpoint.
class FcmService {
  FcmService._();
  static final FcmService instance = FcmService._();

  /// Cambiar a `true` únicamente cuando el backend exponga el endpoint de
  /// registro de device tokens documentado en el reporte final.
  static const bool kBackendSupportsDeviceTokens = false;

  bool _initialized = false;
  bool _available = false;
  StreamSubscription<String>? _tokenRefreshSub;
  StreamSubscription<RemoteMessage>? _foregroundSub;
  StreamSubscription<RemoteMessage>? _openedAppSub;

  /// `true` sólo si `Firebase.initializeApp()` tuvo éxito (hay configuración
  /// real de Firebase para esta plataforma).
  bool get isAvailable => _available;

  Future<void> init() async {
    if (_initialized) return;
    _initialized = true;

    try {
      await Firebase.initializeApp();
    } catch (e) {
      developer.log(
        'FCM no disponible: falta configurar un proyecto Firebase '
        '(google-services.json / GoogleService-Info.plist). $e',
        name: 'FcmService',
      );
      _available = false;
      return;
    }

    _available = true;
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

    final messaging = FirebaseMessaging.instance;
    // Android 13+ pide POST_NOTIFICATIONS vía este mismo permiso; iOS pide
    // autorización de alertas/badge/sonido. No se repite en cada arranque:
    // el plugin recuerda la decisión del usuario a nivel de SO.
    await messaging.requestPermission(alert: true, badge: true, sound: true);

    final token = await messaging.getToken();
    await _syncTokenWithBackend(token);
    _tokenRefreshSub = messaging.onTokenRefresh.listen(_syncTokenWithBackend);

    _foregroundSub = FirebaseMessaging.onMessage.listen(_handleForeground);
    _openedAppSub = FirebaseMessaging.onMessageOpenedApp.listen(
      (m) => NotificationService.instance.handleNotificationData(m.data),
    );

    // Cold start: la app estaba completamente cerrada y se abrió tocando la
    // notificación. Se difiere al primer frame para que exista Navigator.
    final initialMessage = await messaging.getInitialMessage();
    if (initialMessage != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        NotificationService.instance.handleNotificationData(
          initialMessage.data,
        );
      });
    }
  }

  /// Se llama desde `AuthController.logout()`. No-op hasta que el backend
  /// soporte desactivar tokens (ver [kBackendSupportsDeviceTokens]).
  Future<void> onLogout() async {
    if (!_available) return;
    await _deactivateToken();
  }

  Future<void> dispose() async {
    await _tokenRefreshSub?.cancel();
    await _foregroundSub?.cancel();
    await _openedAppSub?.cancel();
  }

  /// Decide si un mensaje FCM que llega con la app en FOREGROUND debe
  /// mostrarse como notificación (Fase 9: deduplicación con WebSocket).
  ///
  /// Regla: si es un mensaje de chat de la conversación que el usuario tiene
  /// abierta AHORA MISMO, el WebSocket ya lo entrega en tiempo real dentro de
  /// la pantalla -> no se duplica con push. Para cualquier otro caso (otra
  /// conversación, o cualquier otro tipo de evento) sí se muestra, porque hoy
  /// el WS sólo cubre la conversación abierta, no el resto de eventos.
  void _handleForeground(RemoteMessage message) {
    final data = message.data;
    if (data['type'] == 'message') {
      final conversationId = int.tryParse(data['conversationId'] ?? '');
      if (conversationId != null &&
          conversationId == RealtimeClient.instance.activeConversationId) {
        return;
      }
    }
    showFromRemoteMessage(message);
  }

  static Future<void> showFromRemoteMessage(RemoteMessage message) async {
    final data = message.data;
    final notification = message.notification;
    final title = notification?.title ?? data['title'] ?? 'Zentry';
    final body = notification?.body ?? data['body'] ?? '';
    final type = data['type'] as String?;

    if (type == 'message') {
      final conversationId = int.tryParse(data['conversationId'] ?? '');
      if (conversationId == null) return;
      await NotificationService.instance.showMessage(
        conversationId: conversationId,
        senderName: title,
        body: body,
        payload: _encodePayload(data),
      );
      return;
    }

    await NotificationService.instance.show(
      title: title,
      body: body,
      payload: _encodePayload(data),
    );
  }

  // `RemoteMessage.data` ya llega como Map<String, String>; se reenvía tal
  // cual como JSON para que `NotificationService.handleNotificationData` lo
  // decodifique igual que un payload de notificación local.
  static String _encodePayload(Map<String, dynamic> data) => jsonEncode(data);

  /// Sincroniza el token FCM con el backend tras login/refresh.
  ///
  /// NO-OP documentado: el backend no expone todavía un endpoint de
  /// registro de device tokens. Contrato sugerido en el reporte final:
  /// `POST /api/core/device-tokens {token, platform, deviceId?}`.
  Future<void> _syncTokenWithBackend(String? token) async {
    if (token == null || token.isEmpty) return;
    if (kDebugMode) {
      // Nunca se imprime el token completo, ni siquiera en debug.
      developer.log(
        'Token FCM obtenido (${token.substring(0, 8)}…). El backend aún no '
        'soporta registrar device tokens — ver reporte final.',
        name: 'FcmService',
      );
    }
    if (!kBackendSupportsDeviceTokens) return;
    // TODO(backend-fcm): POST /api/core/device-tokens {token, platform}
  }

  /// Contrato sugerido: `DELETE /api/core/device-tokens/{token}`.
  Future<void> _deactivateToken() async {
    if (!kBackendSupportsDeviceTokens) return;
    // TODO(backend-fcm): DELETE /api/core/device-tokens/{token}
  }
}
