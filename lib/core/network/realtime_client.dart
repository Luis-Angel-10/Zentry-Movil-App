import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:stomp_dart_client/stomp_dart_client.dart';

import 'package:Zentry/core/config/api_config.dart';
import 'package:Zentry/core/models/backend/message_response.dart';
import 'package:Zentry/core/models/backend/profile_response.dart';
import 'package:Zentry/core/network/api_exception.dart';
import 'package:Zentry/core/network/profile_api.dart';
import 'package:Zentry/core/network/token_storage.dart';
import 'package:Zentry/core/services/notification_service.dart';

/// Cliente STOMP-sobre-WebSocket ÚNICO de la app, contra el broker real del
/// backend (`WebSocketConfig`: endpoint `/ws`, broker `/topic`/`/queue`,
/// `StompAuthChannelInterceptor` exige `Authorization: Bearer <jwt>` como
/// header STOMP nativo en el CONNECT).
///
/// El backend publica cada mensaje nuevo (venga por REST o por STOMP) en
/// `/topic/conversations/{conversationId}` (`MessageService.create` llama
/// `messagingTemplate.convertAndSend(...)` siempre). Por eso Flutter sigue
/// **enviando por REST** (`MessagesApi.send`, con respuesta/errores
/// síncronos) y sólo usa STOMP para **recibir** en tiempo real — no hay dos
/// sistemas de mensajería paralelos, es el mismo backend por dos vías.
///
/// Una sola conexión para toda la sesión (no una por pantalla): se activa de
/// forma perezosa en el primer `subscribeToConversation` y se cierra en
/// `disconnect()` (logout / sesión inválida). Reconecta sola
/// (`StompConfig.reconnectDelay`) y vuelve a suscribir automáticamente todo
/// lo que estuviera suscrito antes de perder la conexión.
///
/// **Un único punto de decisión para las notificaciones locales de mensajes**
/// (ver `_maybeNotify`): vive aquí, no en cada pantalla, precisamente porque
/// más de una pantalla puede estar suscrita a la misma conversación a la vez
/// (p. ej. la bandeja de chats sigue montada debajo de una conversación
/// abierta) — si cada pantalla decidiera notificar por su cuenta, un mismo
/// mensaje dispararía notificaciones duplicadas.
class RealtimeClient {
  RealtimeClient._();
  static final RealtimeClient instance = RealtimeClient._();

  StompClient? _client;

  /// Varias pantallas pueden querer enterarse de la misma conversación a la
  /// vez (la bandeja de chats + una conversación abierta encima) — de ahí el
  /// `Set` de callbacks por id, en vez de uno solo que se pisaría.
  final Map<int, Set<void Function(MessageResponse)>> _handlers = {};
  final Map<int, StompUnsubscribe> _subs = {};
  final Map<int, ProfileResponse> _senderProfileCache = {};

  /// `true` mientras el socket STOMP está conectado y autenticado.
  final ValueNotifier<bool> isConnected = ValueNotifier(false);

  /// Id de la conversación que el usuario tiene abierta EXACTAMENTE en este
  /// momento (`ConversationScreen` la fija/limpia). Mientras coincida con el
  /// id de un mensaje entrante, no se dispara notificación local para él
  /// (Caso A del reporte: ya se ve en tiempo real en pantalla).
  int? activeConversationId;

  /// Id del usuario autenticado, para no notificarnos jamás de nuestros
  /// propios mensajes (el broker nos los reenvía si estamos suscritos a
  /// nuestra propia conversación abierta). Lo fija `AuthController`.
  int? currentUserId;

  void _ensureClient() {
    if (_client != null) return;
    final token = TokenStorage.instance.token;
    if (token == null || token.isEmpty) return;

    _client = StompClient(
      config: StompConfig(
        url: ApiConfig.wsUrl,
        reconnectDelay: const Duration(seconds: 5),
        stompConnectHeaders: {'Authorization': 'Bearer $token'},
        webSocketConnectHeaders: {'Authorization': 'Bearer $token'},
        onConnect: _onConnect,
        onDisconnect: (_) => isConnected.value = false,
        onWebSocketDone: () => isConnected.value = false,
        onWebSocketError: (dynamic error) {
          isConnected.value = false;
          if (kDebugMode) debugPrint('[Zentry WS] error: $error');
        },
        onStompError: (frame) {
          if (kDebugMode) {
            debugPrint('[Zentry WS] STOMP error: ${frame.body}');
          }
        },
      ),
    );
    _client!.activate();
  }

  void _onConnect(StompFrame frame) {
    isConnected.value = true;
    // El broker no recuerda suscripciones de una conexión anterior: se
    // reaplican todas las que la app todavía quiere mantener.
    for (final conversationId in _handlers.keys.toList()) {
      _subscribeNow(conversationId);
    }
  }

  void _subscribeNow(int conversationId) {
    final client = _client;
    if (client == null || !client.connected) return;
    _subs.remove(conversationId)?.call();
    _subs[conversationId] = client.subscribe(
      destination: '/topic/conversations/$conversationId',
      callback: (frame) {
        final body = frame.body;
        if (body == null || body.isEmpty) return;
        try {
          final json = jsonDecode(body);
          if (json is! Map) return;
          final message = MessageResponse.fromJson(
            Map<String, dynamic>.from(json),
          );
          // Decisión de notificación ÚNICA por mensaje, antes de repartirlo a
          // los listeners de pantalla (que solo actualizan UI).
          _maybeNotify(conversationId, message);
          for (final handler in Set.of(_handlers[conversationId] ?? const {})) {
            handler(message);
          }
        } catch (e) {
          if (kDebugMode) debugPrint('[Zentry WS] payload inválido: $e');
        }
      },
    );
  }

  Future<void> _maybeNotify(int conversationId, MessageResponse message) async {
    // Nunca notificar de mensajes propios (pueden llegar de eco si estoy
    // suscrito a mi propia conversación abierta).
    if (currentUserId != null && message.senderId == currentUserId) return;
    // Caso A: la conversación está abierta exactamente ahora -> ya se ve en
    // tiempo real en pantalla, no se genera notificación.
    if (conversationId == activeConversationId) return;

    try {
      final profile = _senderProfileCache[message.senderId] ??= await ProfileApi
          .instance
          .getProfileByUserId(message.senderId);
      final senderName = (profile.name?.isNotEmpty ?? false)
          ? profile.name!
          : (profile.username.isNotEmpty
                ? profile.username
                : 'Usuario #${message.senderId}');
      await NotificationService.instance.showMessage(
        conversationId: conversationId,
        senderName: senderName,
        body: _bodyFor(message),
        payload: jsonEncode({
          'type': 'message',
          'conversationId': conversationId,
          'otherUserId': message.senderId,
          'otherUsername': profile.username,
          'otherDisplayName': senderName,
          'otherAvatarUrl': profile.avatarUrl,
        }),
      );
    } on ApiException catch (e) {
      // No se pudo resolver el remitente (perfil no encontrado, sin red):
      // se muestra igual con lo que hay, en vez de perder la notificación.
      if (kDebugMode) debugPrint('[Zentry WS] perfil remitente: $e');
      await NotificationService.instance.showMessage(
        conversationId: conversationId,
        senderName: 'Nuevo mensaje',
        body: _bodyFor(message),
        payload: jsonEncode({
          'type': 'message',
          'conversationId': conversationId,
          'otherUserId': message.senderId,
        }),
      );
    }
  }

  /// El backend (`MessageRequest`/`MessageResponse`) hoy sólo transporta
  /// texto (`type` es un String libre de máx. 10 caracteres, "text" por
  /// convención) — no hay adjuntos reales todavía. Este mapeo es defensivo
  /// para cuando `type` traiga otra cosa, sin romper mensajes de texto.
  String _bodyFor(MessageResponse message) {
    final type = message.type?.toLowerCase().trim() ?? 'text';
    if (type.startsWith('image') || type.startsWith('img')) return '📷 Imagen';
    if (type.startsWith('video')) return '🎥 Video';
    if (type.startsWith('audio')) return '🎵 Audio';
    if (type.startsWith('file') || type.startsWith('doc'))
      return '📎 Documento';
    final content = message.content?.trim() ?? '';
    return content.isEmpty ? 'Nuevo mensaje' : content;
  }

  /// Se suscribe a los mensajes nuevos de [conversationId]. Admite varios
  /// listeners simultáneos para el mismo id (p. ej. bandeja + conversación
  /// abierta); cada uno debe guardar la referencia de [onMessage] que pasó
  /// para poder llamarse luego a [unsubscribeFromConversation] con la misma.
  void subscribeToConversation(
    int conversationId,
    void Function(MessageResponse message) onMessage,
  ) {
    _handlers.putIfAbsent(conversationId, () => {}).add(onMessage);
    _ensureClient();
    if (_client?.connected == true) {
      _subscribeNow(conversationId);
    }
    // Si todavía no hay conexión, `_onConnect` se encargará de suscribir en
    // cuanto el handshake STOMP termine.
  }

  /// Quita [onMessage] de los listeners de [conversationId]. Sólo cierra la
  /// suscripción STOMP real cuando ya no queda ningún listener para ese id
  /// (para no desconectar a otra pantalla que siga interesada en él).
  void unsubscribeFromConversation(
    int conversationId,
    void Function(MessageResponse message) onMessage,
  ) {
    final set = _handlers[conversationId];
    set?.remove(onMessage);
    if (set == null || set.isEmpty) {
      _handlers.remove(conversationId);
      _subs.remove(conversationId)?.call();
    }
  }

  /// Cierra la conexión y limpia todas las suscripciones. Se llama al cerrar
  /// sesión o cuando el backend invalida el token (401/403).
  void disconnect() {
    for (final unsub in _subs.values) {
      unsub.call();
    }
    _subs.clear();
    _handlers.clear();
    _senderProfileCache.clear();
    activeConversationId = null;
    currentUserId = null;
    _client?.deactivate();
    _client = null;
    isConnected.value = false;
  }
}
