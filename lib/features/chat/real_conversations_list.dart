import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:Zentry/core/config/api_config.dart';
import 'package:Zentry/core/models/backend/conversation_response.dart';
import 'package:Zentry/core/models/backend/profile_response.dart';
import 'package:Zentry/core/network/api_exception.dart';
import 'package:Zentry/core/network/conversations_api.dart';
import 'package:Zentry/core/network/profile_api.dart';
import 'package:Zentry/core/models/backend/message_response.dart';
import 'package:Zentry/core/network/realtime_client.dart';
import 'package:Zentry/core/providers/auth_controller.dart';
import 'package:Zentry/theme/theme_controller.dart';

import 'conversation_screen.dart';

/// Bandeja de entrada REAL: `GET /api/realtime/conversations/mine` +
/// perfiles resueltos por `GET /api/core/profiles/by-user-id/{id}` (la
/// bandeja sólo trae `otherUserId`, sin avatar/username — ver reporte).
///
/// Se suscribe por STOMP a cada conversación visible para refrescarse sola
/// en cuanto llega un mensaje nuevo (último mensaje, hora, orden, no
/// leídos), sin reiniciar la app ni esperar a que el usuario haga pull to
/// refresh.
class RealConversationsList extends StatefulWidget {
  const RealConversationsList({super.key});

  @override
  State<RealConversationsList> createState() => _RealConversationsListState();
}

class _RealConversationsListState extends State<RealConversationsList> {
  List<ConversationSummaryResponse> _conversations = [];
  final Map<int, ProfileResponse> _profilesByUserId = {};
  // Una closure ESTABLE por conversación (no una nueva en cada suscripción):
  // se necesita la misma referencia para poder des-suscribirla en dispose().
  final Map<int, void Function(MessageResponse)> _liveHandlers = {};
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    for (final entry in _liveHandlers.entries) {
      RealtimeClient.instance.unsubscribeFromConversation(
        entry.key,
        entry.value,
      );
    }
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final list = await ConversationsApi.instance.listMine(size: 50);
      if (!mounted) return;

      // Resuelve el perfil (avatar/nombre) de cada "otro usuario" que no se
      // conozca todavía; las conversaciones grupales ya traen `name`.
      final idsToResolve = list
          .map((c) => c.otherUserId)
          .whereType<int>()
          .where((id) => !_profilesByUserId.containsKey(id))
          .toSet();
      for (final id in idsToResolve) {
        try {
          _profilesByUserId[id] = await ProfileApi.instance.getProfileByUserId(
            id,
          );
        } on ApiException {
          // Se conserva la fila sin avatar/nombre resuelto en vez de fallar
          // toda la bandeja por un perfil puntual.
        }
      }

      if (!mounted) return;
      setState(() {
        _conversations = list;
        _loading = false;
      });

      // Suscribe (una vez) a las conversaciones nuevas de esta bandeja.
      for (final c in list) {
        if (_liveHandlers.containsKey(c.id)) continue;
        void handler(MessageResponse _) => _onLiveMessage();
        _liveHandlers[c.id] = handler;
        RealtimeClient.instance.subscribeToConversation(c.id, handler);
      }
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.message;
        _loading = false;
      });
    }
  }

  /// Cualquier mensaje nuevo en cualquiera de las conversaciones suscritas:
  /// se resincroniza la bandeja completa desde el backend (REST = fuente de
  /// verdad de último mensaje/hora/orden/no-leídos), en vez de intentar
  /// llevar la cuenta manualmente en el cliente. La notificación local (si
  /// corresponde) ya la decidió `RealtimeClient` una única vez, antes de
  /// avisar a este listener.
  void _onLiveMessage() {
    if (!mounted) return;
    _load();
  }

  String _timeLabel(DateTime? dt) {
    if (dt == null) return '';
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inMinutes < 1) return 'Ahora';
    if (diff.inHours < 1) return '${diff.inMinutes} min';
    if (diff.inDays < 1) {
      return '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    }
    if (diff.inDays < 7) return '${diff.inDays} d';
    return '${dt.day}/${dt.month}/${dt.year}';
  }

  @override
  Widget build(BuildContext context) {
    final accentColor = context.watch<ThemeController>().accentColor;

    if (_loading && _conversations.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null && _conversations.isEmpty) {
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
                onPressed: _load,
                icon: const Icon(Icons.refresh),
                label: const Text('Reintentar'),
                style: ElevatedButton.styleFrom(backgroundColor: accentColor),
              ),
            ],
          ),
        ),
      );
    }
    if (_conversations.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            'Todavía no tienes conversaciones. Escribe a alguien desde su '
            'perfil con el botón "Mensaje".',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey.shade500),
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _load,
      child: ListView.builder(
        padding: const EdgeInsets.only(top: 10),
        itemCount: _conversations.length,
        itemBuilder: (_, i) => _tile(_conversations[i], accentColor),
      ),
    );
  }

  Widget _tile(ConversationSummaryResponse c, Color accentColor) {
    final profile = c.otherUserId != null
        ? _profilesByUserId[c.otherUserId]
        : null;
    final displayName = c.isGroup
        ? (c.name?.isNotEmpty == true ? c.name! : 'Grupo')
        : (profile?.name?.isNotEmpty == true
              ? profile!.name!
              : (profile?.username ?? 'Usuario #${c.otherUserId ?? ''}'));
    final avatarUrl = profile?.avatarUrl != null
        ? ApiConfig.resolveMediaUrl(profile!.avatarUrl)
        : null;
    final unread = c.unreadCount > 0;
    final myId = context.read<AuthController>().currentUser?.id;
    final lastFromMe = myId != null && c.lastMessageSenderId != null
        ? c.lastMessageSenderId == myId
        : false;

    return ListTile(
      leading: Stack(
        clipBehavior: Clip.none,
        children: [
          CircleAvatar(
            backgroundColor: accentColor,
            backgroundImage: (avatarUrl != null && avatarUrl.isNotEmpty)
                ? NetworkImage(avatarUrl)
                : null,
            child: (avatarUrl == null || avatarUrl.isEmpty)
                ? Icon(c.isGroup ? Icons.groups : Icons.person)
                : null,
          ),
          if (unread)
            Positioned(
              right: -2,
              top: -2,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: const BoxDecoration(
                  color: Colors.redAccent,
                  shape: BoxShape.circle,
                ),
                constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
                child: Text(
                  c.unreadCount > 9 ? '9+' : '${c.unreadCount}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white, fontSize: 10),
                ),
              ),
            ),
        ],
      ),
      title: Text(
        displayName,
        style: TextStyle(
          color: Colors.white,
          fontWeight: unread ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      subtitle: Text(
        c.lastMessageContent?.isNotEmpty == true
            ? '${lastFromMe ? 'Tú: ' : ''}${c.lastMessageContent}'
            : 'Sin mensajes todavía',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          color: unread ? Colors.white70 : Colors.white54,
          fontWeight: unread ? FontWeight.w600 : FontWeight.normal,
        ),
      ),
      trailing: Text(
        _timeLabel(c.lastMessageAt),
        style: TextStyle(
          color: unread ? accentColor : Colors.white38,
          fontSize: 12,
          fontWeight: unread ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      onTap: () async {
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ConversationScreen(
              conversationId: c.id,
              otherUserId: c.otherUserId,
              otherUsername: profile?.username ?? displayName,
              otherDisplayName: displayName,
              otherAvatarUrl: profile?.avatarUrl,
            ),
          ),
        );
        if (mounted) _load();
      },
    );
  }
}
