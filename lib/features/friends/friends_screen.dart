import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:Zentry/core/models/app_user.dart';
import 'package:Zentry/core/models/backend/friend_user_response.dart';
import 'package:Zentry/core/network/api_exception.dart';
import 'package:Zentry/core/network/friends_api.dart';
import 'package:Zentry/features/chat/conversation_screen.dart';
import 'package:Zentry/features/profile/public_profile_screen.dart';
import 'package:Zentry/l10n/generated/app_localizations.dart';
import 'package:Zentry/theme/theme_controller.dart';

/// Amigos reales del usuario autenticado, contra `/api/core/friends/**`.
///
/// Reemplaza los datos hardcodeados anteriores (nombres/avatares de assets
/// ficticios). El diseño visual (tarjetas, stat cards, pestañas, búsqueda)
/// se conserva; sólo cambió el origen de los datos y las acciones.
class FriendsScreen extends StatefulWidget {
  const FriendsScreen({super.key});

  @override
  State<FriendsScreen> createState() => _FriendsScreenState();
}

class _FriendsScreenState extends State<FriendsScreen>
    with TickerProviderStateMixin {
  late AnimationController animationController;
  final ScrollController scrollController = ScrollController();
  final TextEditingController searchController = TextEditingController();

  bool searching = false;
  int selectedTab = 0;

  List<FriendUserResponse> _all = [];
  List<FriendUserResponse> _online = [];
  List<FriendUserResponse> _pending = [];
  bool _loading = true;
  String? _error;
  final Set<int> _busyRequestIds = {};

  List<String> _buildTabs(AppLocalizations l10n) {
    return [
      l10n.chatOnlineStatusLabel,
      l10n.friendsTabRequests,
      l10n.friendsStatFavoritesLabel,
      l10n.eventsFilterAll,
    ];
  }

  @override
  void initState() {
    super.initState();
    animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    animationController.forward();
    searchController.addListener(() => setState(() {}));
    _load();
  }

  @override
  void dispose() {
    animationController.dispose();
    searchController.dispose();
    scrollController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final results = await Future.wait([
        FriendsApi.instance.getFriends(),
        FriendsApi.instance.getFriends(onlineOnly: true),
        FriendsApi.instance.getPendingRequests(),
      ]);
      if (!mounted) return;
      setState(() {
        _all = results[0];
        _online = results[1];
        _pending = results[2];
        _loading = false;
      });
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.message;
        _loading = false;
      });
    }
  }

  List<FriendUserResponse> get _currentList {
    final query = searchController.text.trim().toLowerCase();
    List<FriendUserResponse> base;
    switch (selectedTab) {
      case 0:
        base = _online;
      case 1:
        base = _pending;
      default:
        base = _all; // "Favoritos" y "Todos" muestran la lista completa real
    }
    if (query.isEmpty) return base;
    return base
        .where(
          (f) =>
              f.displayName.toLowerCase().contains(query) ||
              (f.username ?? '').toLowerCase().contains(query),
        )
        .toList();
  }

  void _openProfile(FriendUserResponse f) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PublicProfileScreen(
          user: AppUser(
            id: f.id,
            fullName: f.displayName,
            username: f.username ?? f.displayName,
            email: '',
            discipline: f.discipline,
            bio: f.bio,
          ),
        ),
      ),
    );
  }

  void _openMessage(FriendUserResponse f) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ConversationScreen(
          otherUserId: f.id,
          otherUsername: f.username ?? f.displayName,
          otherDisplayName: f.displayName,
          otherAvatarUrl: f.avatarUrl,
        ),
      ),
    );
  }

  Future<void> _respond(FriendUserResponse f, bool accept) async {
    final requestId = f.requestId;
    if (requestId == null || _busyRequestIds.contains(requestId)) return;
    setState(() => _busyRequestIds.add(requestId));
    try {
      if (accept) {
        await FriendsApi.instance.acceptRequest(requestId);
      } else {
        await FriendsApi.instance.rejectRequest(requestId);
      }
      if (!mounted) return;
      setState(() {
        _pending.removeWhere((p) => p.requestId == requestId);
        _busyRequestIds.remove(requestId);
      });
      if (accept) _load(); // refresca la lista real de amigos
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() => _busyRequestIds.remove(requestId));
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.message),
          backgroundColor: Colors.red.shade400,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final tabs = _buildTabs(l10n);
    final accentColor = context.watch<ThemeController>().accentColor;
    final list = _currentList;

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: Text(
          l10n.friendsScreenTitle,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            onPressed: () => setState(() => searching = !searching),
            icon: Icon(searching ? Icons.close : Icons.search),
          ),
          IconButton(onPressed: _load, icon: const Icon(Icons.refresh)),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _load,
        child: ListView(
          controller: scrollController,
          padding: const EdgeInsets.all(18),
          children: [
            FadeTransition(
              opacity: animationController,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.friendsHeading,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    l10n.friendsSubtitle,
                    style: TextStyle(color: Colors.grey.shade500, fontSize: 14),
                  ),
                  const SizedBox(height: 25),
                  Row(
                    children: [
                      Expanded(
                        child: _statCard(
                          Icons.people,
                          Colors.blue,
                          _all.length.toString(),
                          l10n.friendsScreenTitle,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _statCard(
                          Icons.circle,
                          Colors.green,
                          _online.length.toString(),
                          l10n.chatOnlineStatusLabel,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _statCard(
                          Icons.mark_email_unread,
                          Colors.amber,
                          _pending.length.toString(),
                          l10n.friendsTabRequests,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _statCard(
                          Icons.verified,
                          Colors.cyan,
                          _all.length.toString(),
                          l10n.friendsStatVerifiedLabel,
                        ),
                      ),
                    ],
                  ),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    height: searching ? 65 : 0,
                    margin: EdgeInsets.only(top: searching ? 25 : 0),
                    child: TextField(
                      controller: searchController,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: const Color(0xff171725),
                        hintText: l10n.friendsSearchHint,
                        hintStyle: TextStyle(color: Colors.grey.shade500),
                        prefixIcon: const Icon(
                          Icons.search,
                          color: Colors.white70,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(18),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    height: 42,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: tabs.length,
                      itemBuilder: (_, index) {
                        bool selected = selectedTab == index;
                        return Padding(
                          padding: const EdgeInsets.only(right: 10),
                          child: ChoiceChip(
                            label: Text(
                              index == 1 && _pending.isNotEmpty
                                  ? '${tabs[index]} (${_pending.length})'
                                  : tabs[index],
                            ),
                            selected: selected,
                            selectedColor: accentColor,
                            backgroundColor: const Color(0xff171725),
                            labelStyle: TextStyle(
                              color: selected
                                  ? Colors.white
                                  : Colors.grey.shade400,
                            ),
                            onSelected: (_) =>
                                setState(() => selectedTab = index),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 25),
                  if (_loading)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 60),
                      child: Center(child: CircularProgressIndicator()),
                    )
                  else if (_error != null)
                    _errorState(_error!, accentColor)
                  else if (list.isEmpty)
                    _emptyState(l10n, accentColor)
                  else
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: list.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 15),
                      itemBuilder: (_, index) =>
                          _friendCard(list[index], accentColor),
                    ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: accentColor,
        elevation: 8,
        onPressed: () {
          scrollController.animateTo(
            0,
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeOut,
          );
        },
        child: const Icon(Icons.keyboard_arrow_up),
      ),
    );
  }

  Widget _friendCard(FriendUserResponse f, Color accentColor) {
    final isPendingTab = selectedTab == 1 && f.requestId != null;
    final busy = f.requestId != null && _busyRequestIds.contains(f.requestId);

    return GestureDetector(
      onTap: () => _openProfile(f),
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: const Color(0xff171725),
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(.25),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            Stack(
              children: [
                CircleAvatar(
                  radius: 34,
                  backgroundColor: Colors.white10,
                  backgroundImage: f.avatarUrlAbsolute != null
                      ? NetworkImage(f.avatarUrlAbsolute!)
                      : null,
                  child: f.avatarUrlAbsolute == null
                      ? const Icon(Icons.person, color: Colors.white54)
                      : null,
                ),
                if (f.isOnline)
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Container(
                      width: 16,
                      height: 16,
                      decoration: BoxDecoration(
                        color: Colors.green,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: const Color(0xff171725),
                          width: 2,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    f.displayName,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 17,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    '@${f.username ?? ''}',
                    style: TextStyle(color: Colors.grey.shade500),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(
                        Icons.circle,
                        color: f.isOnline ? Colors.green : Colors.grey,
                        size: 10,
                      ),
                      const SizedBox(width: 5),
                      Expanded(
                        child: Text(
                          f.projectTitle ??
                              (f.isOnline ? 'En línea' : 'Desconectado'),
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Colors.grey.shade400,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            if (isPendingTab)
              busy
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Column(
                      children: [
                        IconButton(
                          onPressed: () => _respond(f, true),
                          icon: const Icon(
                            Icons.check_circle,
                            color: Colors.green,
                          ),
                        ),
                        IconButton(
                          onPressed: () => _respond(f, false),
                          icon: const Icon(
                            Icons.cancel,
                            color: Colors.redAccent,
                          ),
                        ),
                      ],
                    )
            else
              Column(
                children: [
                  IconButton(
                    onPressed: () => _openMessage(f),
                    icon: Icon(Icons.chat_bubble, color: accentColor),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _statCard(IconData icon, Color color, String value, String title) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 18),
      decoration: BoxDecoration(
        color: const Color(0xff171725),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 10),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            title,
            style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _errorState(String message, Color accentColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 60),
      child: Center(
        child: Column(
          children: [
            const Icon(Icons.cloud_off, color: Colors.white38, size: 46),
            const SizedBox(height: 14),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade500),
            ),
            const SizedBox(height: 16),
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

  Widget _emptyState(AppLocalizations l10n, Color accentColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 80),
      child: Center(
        child: Column(
          children: [
            Icon(Icons.people_outline, color: Colors.grey.shade700, size: 70),
            const SizedBox(height: 20),
            Text(
              l10n.friendsEmptyTitle,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              l10n.friendsEmptySubtitle,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade500),
            ),
          ],
        ),
      ),
    );
  }
}
