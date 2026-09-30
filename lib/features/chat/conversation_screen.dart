import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:Zentry/core/config/api_config.dart';
import 'package:Zentry/core/models/backend/message_response.dart';
import 'package:Zentry/core/network/api_exception.dart';
import 'package:Zentry/core/network/conversations_api.dart';
import 'package:Zentry/core/network/messages_api.dart';
import 'package:Zentry/core/network/realtime_client.dart';
import 'package:Zentry/core/providers/auth_controller.dart';
import 'package:Zentry/core/services/notification_service.dart';
import 'package:Zentry/l10n/generated/app_localizations.dart';
import 'package:Zentry/theme/theme_controller.dart';

/// Conversación 1 a 1 REAL contra el backend
/// (`/api/realtime/conversations`, `/api/realtime/messages`) con entrega en
/// tiempo real por STOMP/WebSocket (`/topic/conversations/{id}` — el mismo
/// backend publica ahí cada mensaje nuevo, venga por REST o por STOMP).
///
/// Arquitectura: **REST envía y da el historial; WebSocket sólo empuja
/// actualizaciones en vivo mientras esta pantalla está abierta.** Enviar
/// sigue siendo por REST (`MessagesApi.send`, con error/validación
/// síncronos); STOMP es exclusivamente para recibir. Al reconectar (o al
/// entrar) se recarga el historial real por REST para reconciliar cualquier
/// mensaje perdido mientras no había conexión — nunca se depende sólo del
/// socket para reconstruir la conversación.
///
/// Sólo soporta texto: el backend (`MessageRequest`) no tiene campo de
/// adjunto todavía (ver BACKEND GAP en el reporte de la sesión). El chat
/// local con multimedia/llamadas/estados en [ChatScreen] no se toca — sigue
/// siendo el flujo mock existente para esas funciones.
///
/// Se puede abrir con [conversationId] ya conocido (p. ej. desde la bandeja
/// de entrada) o con [otherUserId] (p. ej. desde un perfil), en cuyo caso la
/// conversación 1 a 1 se obtiene o se crea automáticamente
/// (`POST /direct/{otherUserId}`, idempotente: nunca duplica conversaciones
/// entre el mismo par de usuarios).
class ConversationScreen extends StatefulWidget {
  const ConversationScreen({
    super.key,
    this.conversationId,
    this.otherUserId,
    required this.otherUsername,
    this.otherDisplayName,
    this.otherAvatarUrl,
  }) : assert(
         conversationId != null || otherUserId != null,
         'Se requiere conversationId u otherUserId',
       );

  final int? conversationId;
  final int? otherUserId;
  final String otherUsername;
  final String? otherDisplayName;
  final String? otherAvatarUrl;

  @override
  State<ConversationScreen> createState() => _ConversationScreenState();
}

class _ConversationScreenState extends State<ConversationScreen> {
  final _input = TextEditingController();
  final _scroll = ScrollController();

  int? _conversationId;
  List<MessageResponse> _messages = [];
  bool _loading = true;
  bool _sending = false;
  String? _error;
  VoidCallback? _connectionListener;
  bool _wasConnected = false;

  int? get _myId => context.read<AuthController>().currentUser?.id;

  String get _title => widget.otherDisplayName?.isNotEmpty == true
      ? widget.otherDisplayName!
      : widget.otherUsername;

  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  @override
  void dispose() {
    final id = _conversationId;
    if (id != null) {
      RealtimeClient.instance.unsubscribeFromConversation(id, _onLiveMessage);
      if (RealtimeClient.instance.activeConversationId == id) {
        RealtimeClient.instance.activeConversationId = null;
      }
    }
    final listener = _connectionListener;
    if (listener != null) {
      RealtimeClient.instance.isConnected.removeListener(listener);
    }
    _input.dispose();
    _scroll.dispose();
    super.dispose();
  }

  Future<void> _bootstrap() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      int convId;
      if (widget.conversationId != null) {
        convId = widget.conversationId!;
      } else {
        final conv = await ConversationsApi.instance.startDirect(
          widget.otherUserId!,
        );
        convId = conv.id;
      }
      if (!mounted) return;
      _conversationId = convId;
      // Marca esta conversación como "abierta ahora": mientras lo esté, no
      // se generan notificaciones locales para sus mensajes entrantes (Caso
      // A) — ya se ven en tiempo real más abajo en esta misma pantalla.
      RealtimeClient.instance.activeConversationId = convId;
      unawaited(NotificationService.instance.cancelMessageNotification(convId));
      await _loadMessages();
      unawaited(ConversationsApi.instance.markRead(convId).catchError((_) {}));

      // Tiempo real: se suscribe a /topic/conversations/{id} (STOMP). El
      // backend publica ahí cada mensaje nuevo de esta conversación, venga
      // por REST o por STOMP — ver MessageService.create en el backend.
      _wasConnected = RealtimeClient.instance.isConnected.value;
      RealtimeClient.instance.subscribeToConversation(convId, _onLiveMessage);

      // REST sigue siendo la fuente de verdad del historial: si el socket
      // se reconecta (tras perder señal, background, etc.) se recarga desde
      // el backend para reconciliar cualquier mensaje perdido mientras
      // estuvo desconectado, en vez de confiar sólo en lo que llegue por WS.
      _connectionListener = () {
        final nowConnected = RealtimeClient.instance.isConnected.value;
        if (nowConnected && !_wasConnected && mounted) {
          _loadMessages(silent: true);
          unawaited(
            ConversationsApi.instance.markRead(convId).catchError((_) {}),
          );
        }
        _wasConnected = nowConnected;
      };
      RealtimeClient.instance.isConnected.addListener(_connectionListener!);
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.message;
        _loading = false;
      });
    }
  }

  /// Mensaje recibido en vivo por STOMP para esta conversación.
  void _onLiveMessage(MessageResponse message) {
    if (!mounted) return;
    // Dedupe por id: si YO envié el mensaje, el broker también me lo
    // reenvía por estar suscrito a mi propia conversación abierta — el envío
    // real ya lo agregó `_send()` con la respuesta confirmada del POST.
    if (_messages.any((m) => m.id == message.id)) return;
    setState(() => _messages = [..._messages, message]);
    _scrollToBottom();
    final convId = _conversationId;
    if (convId != null && message.senderId != _myId) {
      unawaited(ConversationsApi.instance.markRead(convId).catchError((_) {}));
    }
  }

  Future<void> _loadMessages({bool silent = false}) async {
    final convId = _conversationId;
    if (convId == null) return;
    if (!silent) {
      setState(() {
        _loading = true;
        _error = null;
      });
    }
    try {
      final list = await MessagesApi.instance.listByConversation(
        convId,
        size: 50,
      );
      if (!mounted) return;
      // El backend devuelve del más reciente al más antiguo; para pintar de
      // arriba (antiguo) hacia abajo (reciente) se invierte aquí.
      final chronological = list.reversed.toList();
      final wasAtBottom =
          !_scroll.hasClients ||
          _scroll.position.pixels >= _scroll.position.maxScrollExtent - 40;
      setState(() {
        _messages = chronological;
        _loading = false;
      });
      if (wasAtBottom) _scrollToBottom();
    } on ApiException catch (e) {
      if (!mounted) return;
      if (!silent) {
        setState(() {
          _error = e.message;
          _loading = false;
        });
      }
      // Un fallo del poll silencioso no interrumpe la conversación ya cargada.
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_scroll.hasClients) return;
      _scroll.animateTo(
        _scroll.position.maxScrollExtent,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    });
  }

  Future<void> _send() async {
    final text = _input.text.trim();
    final convId = _conversationId;
    if (text.isEmpty || convId == null || _sending) return;

    setState(() => _sending = true);
    _input.clear();
    try {
      final sent = await MessagesApi.instance.send(
        conversationId: convId,
        content: text,
      );
      if (!mounted) return;
      setState(() {
        // Dedupe: si el eco por STOMP llegó primero (reconexión en curso),
        // no se duplica el mensaje.
        if (!_messages.any((m) => m.id == sent.id)) {
          _messages = [..._messages, sent];
        }
        _sending = false;
      });
      _scrollToBottom();
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() => _sending = false);
      _input.text = text;
      _snack(e.message, error: true);
    }
  }

  void _snack(String msg, {bool error = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(msg),
          backgroundColor: error ? Colors.red.shade400 : null,
          behavior: SnackBarBehavior.floating,
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    final accentColor = context.watch<ThemeController>().accentColor;
    final avatarUrl = widget.otherAvatarUrl == null
        ? null
        : ApiConfig.resolveMediaUrl(widget.otherAvatarUrl);

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        titleSpacing: 0,
        title: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: accentColor,
              backgroundImage: avatarUrl != null
                  ? NetworkImage(avatarUrl)
                  : null,
              child: avatarUrl == null
                  ? const Icon(Icons.person, size: 18, color: Colors.white)
                  : null,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                _title,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(child: _buildBody(accentColor)),
            _buildComposer(accentColor),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(Color accentColor) {
    if (_loading && _messages.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null && _messages.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.cloud_off, size: 40, color: Colors.white38),
              const SizedBox(height: 12),
              Text(_error!, textAlign: TextAlign.center),
              const SizedBox(height: 14),
              ElevatedButton.icon(
                onPressed: () => _loadMessages(),
                icon: const Icon(Icons.refresh),
                label: const Text('Reintentar'),
              ),
            ],
          ),
        ),
      );
    }
    if (_messages.isEmpty) {
      return Center(
        child: Text(
          'Aún no hay mensajes. Envía el primero 👋',
          style: TextStyle(color: Colors.grey.shade500),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => _loadMessages(),
      child: ListView.builder(
        controller: _scroll,
        padding: const EdgeInsets.all(14),
        itemCount: _messages.length,
        itemBuilder: (_, i) => _bubble(_messages[i], accentColor),
      ),
    );
  }

  /// Parte una respuesta a historia real (`type:"story"`) en su preview
  /// citado y el texto real de la respuesta. El backend guarda esto como
  /// texto plano con el formato literal
  /// `↩️ "preview": respuesta` (o `↩️ respuesta` si la historia no tenía
  /// preview) — ver `StoryService.replyToStory` (sin modificar, sólo
  /// leído). No hay `storyId` ni URL de la historia en el mensaje
  /// (confirmado: `Message` no tiene esos campos), así que sólo se puede
  /// mostrar el texto citado, no una miniatura real de la historia.
  static final RegExp _storyReplyPattern = RegExp(r'^↩️ (?:"(.*)": )?(.*)$');

  Widget _bubble(MessageResponse msg, Color accentColor) {
    // Comparación explícita de enteros: senderId (backend Integer) contra
    // currentUser.id (int, mismo tipo desde la Fase 1 — nunca String/UUID).
    final isMe = _myId != null && msg.senderId == _myId;
    final isStoryReply = msg.type == 'story';
    final storyMatch = isStoryReply
        ? _storyReplyPattern.firstMatch(msg.content ?? '')
        : null;
    final storyPreview = storyMatch?.group(1);
    final replyText = storyMatch?.group(2) ?? msg.content ?? '';

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.78,
        ),
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 6),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            gradient: isMe
                ? LinearGradient(
                    colors: [
                      accentColor.withOpacity(0.55),
                      const Color(0xFF2B2B3D),
                    ],
                  )
                : null,
            color: isMe ? null : const Color(0xFF1E1E2D),
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(20),
              topRight: const Radius.circular(20),
              bottomLeft: Radius.circular(isMe ? 20 : 4),
              bottomRight: Radius.circular(isMe ? 4 : 20),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (isStoryReply) ...[
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.reply_rounded,
                      size: 13,
                      color: Colors.white.withOpacity(0.7),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      isMe
                          ? AppLocalizations.of(context)!.chatRepliedToStory
                          : AppLocalizations.of(
                              context,
                            )!.chatRepliedToYourStory,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.7),
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                if ((storyPreview ?? '').isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black26,
                      borderRadius: BorderRadius.circular(12),
                      border: Border(
                        left: BorderSide(color: accentColor, width: 3),
                      ),
                    ),
                    child: Text(
                      storyPreview!,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.85),
                        fontSize: 13,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 6),
              ],
              Text(
                replyText,
                style: const TextStyle(color: Colors.white, fontSize: 15),
              ),
              const SizedBox(height: 4),
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  _timeLabel(msg.createdAt),
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.55),
                    fontSize: 10.5,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _timeLabel(DateTime? dt) {
    if (dt == null) return '';
    return '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }

  Widget _buildComposer(Color accentColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: const BoxDecoration(color: Color(0xFF151526)),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: Colors.white10,
                borderRadius: BorderRadius.circular(30),
              ),
              child: TextField(
                controller: _input,
                minLines: 1,
                maxLines: 4,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  hintText: 'Escribe un mensaje…',
                  hintStyle: TextStyle(color: Colors.white54),
                  border: InputBorder.none,
                ),
                onSubmitted: (_) => _send(),
              ),
            ),
          ),
          const SizedBox(width: 8),
          CircleAvatar(
            radius: 24,
            backgroundColor: accentColor,
            child: _sending
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : IconButton(
                    icon: const Icon(Icons.send, color: Colors.white),
                    onPressed: _send,
                  ),
          ),
        ],
      ),
    );
  }
}
