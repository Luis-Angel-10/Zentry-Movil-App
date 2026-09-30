import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:Zentry/core/models/achievement.dart';
import 'package:Zentry/core/models/app_user.dart';
import 'package:Zentry/core/models/avatar_frame.dart';
import 'package:Zentry/core/models/backend/friend_user_response.dart';
import 'package:Zentry/core/models/backend/post_response.dart';
import 'package:Zentry/core/models/backend/profile_response.dart';
import 'package:Zentry/core/network/api_exception.dart';
import 'package:Zentry/core/network/friends_api.dart';
import 'package:Zentry/core/network/posts_api.dart';
import 'package:Zentry/core/network/profile_api.dart';
import 'package:Zentry/core/providers/auth_controller.dart';
import 'package:Zentry/core/providers/community_controller.dart';
import 'package:Zentry/core/providers/follow_controller.dart';
import 'package:Zentry/core/providers/notifications_controller.dart';
import 'package:Zentry/core/providers/posts_controller.dart';
import 'package:Zentry/core/widgets/zentry_network_image.dart';
import 'package:Zentry/features/chat/conversation_screen.dart';
import 'package:Zentry/features/profile/profile_avatar_story_ring.dart';
import 'package:Zentry/l10n/generated/app_localizations.dart';
import 'package:Zentry/theme/theme_controller.dart';

enum _FriendState { none, sent, received, friends, unknown }

/// Perfil de OTRO usuario (no el propio). Recibe el [AppUser] local (id,
/// username, displayName, ...) que ya tenía la app en el punto de navegación
/// que sea (búsqueda, seguidores, comentario, notificación, amigos...) y, al
/// montarse, intenta enriquecerlo con datos REALES del backend por username
/// (`GET /api/core/profiles/{username}`, `GET /api/core/posts/by-user/{u}`).
///
/// Si el backend no reconoce ese username (perfil puramente local/mock —
/// recomendaciones, miembros de comunidad de ejemplo, etc.) se degrada
/// automáticamente a mostrar sólo los datos locales que ya mostraba antes,
/// sin romper esas pantallas.
class PublicProfileScreen extends StatefulWidget {
  final AppUser user;

  const PublicProfileScreen({super.key, required this.user});

  @override
  State<PublicProfileScreen> createState() => _PublicProfileScreenState();
}

class _PublicProfileScreenState extends State<PublicProfileScreen> {
  ProfileResponse? _profile;
  List<PostResponse>? _backendPosts;
  bool _isBackendUser = false;
  bool _loadingProfile = true;

  bool _followBusy = false;
  bool? _followingOverride; // optimista; null = usar el valor del backend

  _FriendState _friendState = _FriendState.unknown;
  int? _friendRequestId; // requestId relevante para aceptar/rechazar/cancelar
  int? _resolvedOtherId; // id numérico real, si se pudo determinar
  bool _friendBusy = false;
  bool _loadingFriendState = true;

  @override
  void initState() {
    super.initState();
    _resolvedOtherId = widget.user.id > 0 ? widget.user.id : null;
    _loadProfile();
    _loadFriendState();
  }

  Future<void> _loadProfile() async {
    try {
      final results = await Future.wait([
        ProfileApi.instance.getProfile(widget.user.username),
        PostsApi.instance
            .getPostsByUsername(widget.user.username)
            .catchError((_) => const <PostResponse>[]),
      ]);
      if (!mounted) return;
      setState(() {
        _profile = results[0] as ProfileResponse;
        _backendPosts = results[1] as List<PostResponse>;
        _isBackendUser = true;
        _loadingProfile = false;
      });
    } on ApiException {
      // Perfil puramente local (mock de recomendaciones/comunidades/etc.):
      // se conserva el comportamiento previo, sin datos reales.
      if (!mounted) return;
      setState(() => _loadingProfile = false);
    }
  }

  Future<void> _loadFriendState() async {
    try {
      final results = await Future.wait([
        FriendsApi.instance.getFriends(),
        FriendsApi.instance.getPendingRequests(),
        FriendsApi.instance.getSentRequests(),
      ]);
      if (!mounted) return;
      final friends = results[0];
      final pending = results[1]; // recibidas
      final sent = results[2];

      FriendUserResponse? match(List<FriendUserResponse> list) {
        for (final f in list) {
          if (f.username != null &&
              f.username!.toLowerCase() == widget.user.username.toLowerCase()) {
            return f;
          }
        }
        return null;
      }

      final asFriend = match(friends);
      final asPending = match(pending);
      final asSent = match(sent);

      setState(() {
        if (asFriend != null) {
          _friendState = _FriendState.friends;
          _resolvedOtherId ??= asFriend.id;
        } else if (asPending != null) {
          _friendState = _FriendState.received;
          _friendRequestId = asPending.requestId;
          _resolvedOtherId ??= asPending.id;
        } else if (asSent != null) {
          _friendState = _FriendState.sent;
          _friendRequestId = asSent.requestId;
          _resolvedOtherId ??= asSent.id;
        } else {
          _friendState = _FriendState.none;
        }
        _loadingFriendState = false;
      });
    } on ApiException {
      if (!mounted) return;
      setState(() {
        _friendState = _FriendState.unknown;
        _loadingFriendState = false;
      });
    }
  }

  bool get _isMe {
    final me = context.read<AuthController>().currentUser;
    return me != null &&
        me.username.toLowerCase() == widget.user.username.toLowerCase();
  }

  // ─── Follow (real) ─────────────────────────────────────────────────────

  Future<void> _toggleFollowReal() async {
    if (_followBusy || _profile == null) return;
    final current = _followingOverride ?? _profile!.isFollowing;
    setState(() {
      _followBusy = true;
      _followingOverride = !current; // respuesta visual inmediata
    });
    try {
      final result = await ProfileApi.instance.toggleFollow(
        widget.user.username,
      );
      if (!mounted) return;
      setState(() {
        _profile = ProfileResponse(
          username: _profile!.username,
          name: _profile!.name,
          artisticName: _profile!.artisticName,
          discipline: _profile!.discipline,
          experienceLevel: _profile!.experienceLevel,
          rank: _profile!.rank,
          location: _profile!.location,
          bio: _profile!.bio,
          avatarUrl: _profile!.avatarUrl,
          bannerUrl: _profile!.bannerUrl,
          isPrivate: _profile!.isPrivate,
          showSavedPosts: _profile!.showSavedPosts,
          showLikedPosts: _profile!.showLikedPosts,
          followersCount: result.followersCount,
          followingCount: _profile!.followingCount,
          isFollowing: result.following,
          createdAt: _profile!.createdAt,
        );
        _followingOverride = null; // ya reflejado en _profile
        _followBusy = false;
      });
    } on ApiException catch (e) {
      if (!mounted) return;
      // La API falló: se revierte el estado optimista, NUNCA se deja un
      // contador/estado falso.
      setState(() {
        _followingOverride = current;
        _followBusy = false;
      });
      _snack(e.message, error: true);
    }
  }

  // ─── Amistad (real) ────────────────────────────────────────────────────

  Future<void> _sendFriendRequest() async {
    if (_friendBusy) return;
    setState(() => _friendBusy = true);
    try {
      await FriendsApi.instance.sendRequest(
        targetUsername: widget.user.username,
      );
      if (!mounted) return;
      setState(() {
        _friendState = _FriendState.sent;
        _friendBusy = false;
      });
      _snack('Solicitud de amistad enviada');
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() => _friendBusy = false);
      // "Ya son amigos" / "Ya has enviado una solicitud" -> refrescar estado
      // real en vez de dejar un botón desincronizado.
      _loadFriendState();
      _snack(e.message, error: true);
    }
  }

  Future<void> _cancelSentRequest() async {
    final id = _friendRequestId;
    if (id == null || _friendBusy) return;
    setState(() => _friendBusy = true);
    try {
      await FriendsApi.instance.rejectRequest(id);
      if (!mounted) return;
      setState(() {
        _friendState = _FriendState.none;
        _friendRequestId = null;
        _friendBusy = false;
      });
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() => _friendBusy = false);
      _snack(e.message, error: true);
    }
  }

  Future<void> _respondToRequest(bool accept) async {
    final id = _friendRequestId;
    if (id == null || _friendBusy) return;
    setState(() => _friendBusy = true);
    try {
      if (accept) {
        await FriendsApi.instance.acceptRequest(id);
      } else {
        await FriendsApi.instance.rejectRequest(id);
      }
      if (!mounted) return;
      setState(() {
        _friendState = accept ? _FriendState.friends : _FriendState.none;
        _friendRequestId = null;
        _friendBusy = false;
      });
      _snack(accept ? '¡Ahora son amigos!' : 'Solicitud rechazada');
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() => _friendBusy = false);
      _snack(e.message, error: true);
    }
  }

  Future<void> _removeFriend() async {
    final id = _resolvedOtherId;
    if (id == null || _friendBusy) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E2D),
        title: const Text(
          '¿Eliminar amistad?',
          style: TextStyle(color: Colors.white),
        ),
        content: Text(
          'Dejarás de ser amigo de ${widget.user.displayName}.',
          style: TextStyle(color: Colors.grey.shade400),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text(
              'Eliminar',
              style: TextStyle(color: Colors.redAccent),
            ),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    setState(() => _friendBusy = true);
    try {
      await FriendsApi.instance.removeFriend(id);
      if (!mounted) return;
      setState(() {
        _friendState = _FriendState.none;
        _friendBusy = false;
      });
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() => _friendBusy = false);
      _snack(e.message, error: true);
    }
  }

  // ─── Mensaje (real) ────────────────────────────────────────────────────

  Future<void> _openMessage() async {
    final otherId = _resolvedOtherId;
    if (otherId == null) {
      _snack(
        'Aún no podemos abrir un chat real con este perfil (falta '
        'identificarlo en el backend). Sigue a la persona o espera a que '
        'tenga una interacción real para habilitarlo.',
      );
      return;
    }
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ConversationScreen(
          otherUserId: otherId,
          otherUsername: widget.user.username,
          otherDisplayName: widget.user.displayName,
          otherAvatarUrl: _profile?.avatarUrl,
        ),
      ),
    );
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
    final l10n = AppLocalizations.of(context)!;
    final accentColor = context.watch<ThemeController>().accentColor;
    final follow = context.watch<FollowController>();
    final currentUser = context.watch<AuthController>().currentUser;

    final localPosts = context
        .watch<PostsController>()
        .postsByUser(widget.user.displayName)
        .where((p) => p["communityId"] == null)
        .toList();
    final myCommunities = context.watch<CommunityController>().myCommunities(
      widget.user.id,
    );

    final isMe = currentUser?.id == widget.user.id || _isMe;

    // Fuente de datos: real si el backend reconoce al usuario, local si no.
    final displayName = _isBackendUser
        ? ((_profile?.name?.isNotEmpty ?? false)
              ? _profile!.name!
              : (_profile?.artisticName?.isNotEmpty ?? false)
              ? _profile!.artisticName!
              : widget.user.displayName)
        : widget.user.displayName;
    final bio = _isBackendUser
        ? (_profile?.bio ?? '')
        : (widget.user.bio ?? '');
    final discipline = _isBackendUser
        ? _profile?.discipline
        : widget.user.discipline;
    final avatarUrlAbs = _isBackendUser ? _profile?.avatarUrlAbsolute : null;
    final bannerUrlAbs = _isBackendUser ? _profile?.bannerUrlAbsolute : null;

    final isFollowing = _isBackendUser
        ? (_followingOverride ?? _profile?.isFollowing ?? false)
        : (currentUser != null
              ? follow.isFollowing(currentUser.id, widget.user.id)
              : false);
    final followersCount = _isBackendUser
        ? (_profile?.followersCount ?? 0)
        : follow.followersCount(widget.user.id);
    final followingCount = _isBackendUser
        ? (_profile?.followingCount ?? 0)
        : follow.followingCount(widget.user.id);

    final postsCount = _isBackendUser
        ? (_backendPosts?.length ?? 0)
        : localPosts.length;

    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: Column(
                children: [
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Container(
                        height: 150,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          gradient:
                              (widget.user.coverPhotoPath == null &&
                                  bannerUrlAbs == null)
                              ? const LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    Color(0xFF2A1B4D),
                                    Color(0xFF120F1F),
                                  ],
                                )
                              : null,
                          image: widget.user.coverPhotoPath != null
                              ? DecorationImage(
                                  image: FileImage(
                                    File(widget.user.coverPhotoPath!),
                                  ),
                                  fit: BoxFit.cover,
                                )
                              : bannerUrlAbs != null
                              ? DecorationImage(
                                  image: NetworkImage(bannerUrlAbs),
                                  fit: BoxFit.cover,
                                )
                              : null,
                        ),
                      ),
                      Positioned(
                        top: 8,
                        left: 4,
                        child: IconButton(
                          icon: const Icon(
                            Icons.arrow_back,
                            color: Colors.white,
                          ),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ),
                      Positioned(
                        left: 18,
                        bottom: -34,
                        child: ProfileAvatarStoryRing(
                          userId: _resolvedOtherId ?? 0,
                          displayName: widget.user.displayName,
                          username: widget.user.username,
                          avatarUrl: avatarUrlAbs,
                          fallbackGradient: avatarFrameColors(
                            widget.user.avatarFrameId,
                          ),
                          child: Container(
                            padding: const EdgeInsets.all(3),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Theme.of(context).scaffoldBackgroundColor,
                            ),
                            child: CircleAvatar(
                              radius: 34,
                              backgroundColor: Colors.white10,
                              backgroundImage: widget.user.photoPath != null
                                  ? FileImage(File(widget.user.photoPath!))
                                  : avatarUrlAbs != null
                                  ? NetworkImage(avatarUrlAbs)
                                  : null,
                              child:
                                  (widget.user.photoPath == null &&
                                      avatarUrlAbs == null)
                                  ? const Icon(
                                      Icons.person,
                                      color: Colors.white54,
                                      size: 30,
                                    )
                                  : null,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 44),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                displayName,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            if ((_profile?.rank ?? '').isNotEmpty) ...[
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: accentColor.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  _profile!.rank!,
                                  style: TextStyle(
                                    color: accentColor,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ],
                            for (final id in widget.user.featuredBadgeIds)
                              if (kAchievementDefs
                                  .where((d) => d.id == id)
                                  .isNotEmpty)
                                Padding(
                                  padding: const EdgeInsets.only(left: 6),
                                  child: Icon(
                                    kAchievementDefs
                                        .firstWhere((d) => d.id == id)
                                        .icon,
                                    color: kAchievementDefs
                                        .firstWhere((d) => d.id == id)
                                        .color,
                                    size: 18,
                                  ),
                                ),
                          ],
                        ),
                        Text(
                          '@${widget.user.username}',
                          style: TextStyle(
                            color: Colors.grey.shade500,
                            fontSize: 13,
                          ),
                        ),
                        if ((discipline ?? '').isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            discipline!,
                            style: TextStyle(color: Colors.grey.shade400),
                          ),
                        ],
                        if (bio.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Text(
                            bio,
                            style: TextStyle(
                              color: Colors.grey.shade400,
                              fontSize: 13,
                              height: 1.4,
                            ),
                          ),
                        ],
                        const SizedBox(height: 18),
                        Row(
                          children: [
                            _stat('$postsCount', l10n.profilePostsLabel),
                            const SizedBox(width: 24),
                            _stat(
                              '$followersCount',
                              l10n.profileFollowersLabel,
                            ),
                            const SizedBox(width: 24),
                            _stat(
                              '$followingCount',
                              l10n.profileFollowingLabel,
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        if (!isMe)
                          Column(
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: ElevatedButton(
                                      onPressed: _isBackendUser
                                          ? (_followBusy
                                                ? null
                                                : _toggleFollowReal)
                                          : () => _toggleFollowLocal(
                                              currentUser,
                                              isFollowing,
                                            ),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: isFollowing
                                            ? Colors.grey.shade800
                                            : accentColor,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            14,
                                          ),
                                        ),
                                      ),
                                      child: _followBusy
                                          ? const SizedBox(
                                              height: 18,
                                              width: 18,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                                color: Colors.white,
                                              ),
                                            )
                                          : Text(
                                              isFollowing
                                                  ? l10n.publicProfileFollowingButton
                                                  : l10n.publicProfileFollowButton,
                                              style: const TextStyle(
                                                color: Colors.white,
                                              ),
                                            ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: OutlinedButton.icon(
                                      onPressed: _openMessage,
                                      icon: Icon(
                                        _resolvedOtherId == null
                                            ? Icons.chat_bubble_outline
                                            : Icons.chat_bubble,
                                      ),
                                      label: Text(
                                        l10n.publicProfileMessageButton,
                                      ),
                                      style: OutlinedButton.styleFrom(
                                        side: const BorderSide(
                                          color: Colors.white24,
                                        ),
                                        foregroundColor:
                                            _resolvedOtherId == null
                                            ? Colors.white38
                                            : null,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              if (_isBackendUser) ...[
                                const SizedBox(height: 10),
                                _friendActionButton(accentColor),
                              ],
                            ],
                          ),
                        if (myCommunities.isNotEmpty) ...[
                          const SizedBox(height: 20),
                          Text(
                            l10n.communitiesScreenTitle,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: myCommunities
                                .map(
                                  (c) => Chip(
                                    label: Text(c.name),
                                    backgroundColor: Theme.of(
                                      context,
                                    ).cardColor,
                                    labelStyle: const TextStyle(
                                      color: Colors.white70,
                                    ),
                                  ),
                                )
                                .toList(),
                          ),
                        ],
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            if (_loadingProfile)
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 40),
                  child: Center(child: CircularProgressIndicator()),
                ),
              )
            else if (_isBackendUser && (_backendPosts?.isEmpty ?? true))
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 60),
                  child: Center(
                    child: Text(
                      l10n.publicProfileNoPosts,
                      style: TextStyle(color: Colors.grey.shade500),
                    ),
                  ),
                ),
              )
            else if (!_isBackendUser && localPosts.isEmpty)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 60),
                  child: Center(
                    child: Text(
                      l10n.publicProfileNoPosts,
                      style: TextStyle(color: Colors.grey.shade500),
                    ),
                  ),
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 4,
                    mainAxisSpacing: 4,
                  ),
                  delegate: _isBackendUser
                      ? SliverChildBuilderDelegate((context, index) {
                          final post = _backendPosts![index];
                          final url = post.imageUrlAbsolute;
                          return Container(
                            color: Colors.white10,
                            child: url != null
                                ? ZentryNetworkImage(
                                    imageUrl: url,
                                    fit: BoxFit.cover,
                                  )
                                : Padding(
                                    padding: const EdgeInsets.all(8),
                                    child: Text(
                                      post.content ?? '',
                                      maxLines: 4,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        color: Colors.white70,
                                        fontSize: 11,
                                      ),
                                    ),
                                  ),
                          );
                        }, childCount: _backendPosts!.length)
                      : SliverChildBuilderDelegate((context, index) {
                          final post = localPosts[index];
                          final imageFile = post["imageFile"] as File?;
                          final imageUrl = post["image"] as String?;
                          return Container(
                            color: Colors.white10,
                            child: imageFile != null
                                ? Image.file(
                                    imageFile,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) =>
                                        const SizedBox.shrink(),
                                  )
                                : imageUrl != null
                                ? ZentryNetworkImage(
                                    imageUrl: imageUrl,
                                    fit: BoxFit.cover,
                                  )
                                : Padding(
                                    padding: const EdgeInsets.all(8),
                                    child: Text(
                                      post["content"] as String? ?? '',
                                      maxLines: 4,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        color: Colors.white70,
                                        fontSize: 11,
                                      ),
                                    ),
                                  ),
                          );
                        }, childCount: localPosts.length),
                ),
              ),
            const SliverToBoxAdapter(child: SizedBox(height: 40)),
          ],
        ),
      ),
    );
  }

  Widget _friendActionButton(Color accentColor) {
    if (_loadingFriendState) {
      return const SizedBox(
        height: 40,
        child: Center(
          child: SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      );
    }

    switch (_friendState) {
      case _FriendState.friends:
        return SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: _friendBusy ? null : _removeFriend,
            icon: const Icon(Icons.people, color: Colors.greenAccent),
            label: Text(
              _friendBusy ? 'Procesando…' : 'Amigos',
              style: const TextStyle(color: Colors.greenAccent),
            ),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Colors.greenAccent),
            ),
          ),
        );
      case _FriendState.sent:
        return SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: _friendBusy ? null : _cancelSentRequest,
            icon: const Icon(Icons.hourglass_top, color: Colors.orangeAccent),
            label: const Text(
              'Solicitud enviada (toca para cancelar)',
              style: TextStyle(color: Colors.orangeAccent),
            ),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Colors.orangeAccent),
            ),
          ),
        );
      case _FriendState.received:
        return Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: _friendBusy ? null : () => _respondToRequest(true),
                icon: const Icon(Icons.check),
                label: const Text('Aceptar'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green.shade600,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _friendBusy ? null : () => _respondToRequest(false),
                icon: const Icon(Icons.close),
                label: const Text('Rechazar'),
              ),
            ),
          ],
        );
      case _FriendState.none:
      case _FriendState.unknown:
        return SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: _friendBusy ? null : _sendFriendRequest,
            icon: Icon(Icons.person_add_alt_1, color: accentColor),
            label: Text('Agregar amigo', style: TextStyle(color: accentColor)),
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: accentColor.withOpacity(0.6)),
            ),
          ),
        );
    }
  }

  Widget _stat(String value, String label) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        Text(
          label,
          style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
        ),
      ],
    );
  }

  /// Rama SOLO para `!_isBackendUser`: perfiles que el backend no reconoce
  /// (mock de recomendaciones/comunidades/etc. que aún no tienen usuario
  /// real). Ver el doc-comment de `FollowController` — nunca debe usarse
  /// para un usuario real, esos siempre pasan por `_toggleFollowReal`.
  Future<void> _toggleFollowLocal(
    AppUser? currentUser,
    bool isFollowing,
  ) async {
    if (currentUser == null) return;

    final follow = context.read<FollowController>();
    await follow.toggle(currentUser.id, widget.user.id);

    if (!mounted) return;

    if (!isFollowing) {
      context.read<NotificationsController>().push(AppNotificationType.follow, {
        'actorName': currentUser.displayName,
        'actorUserId': currentUser.id,
      });
    }
  }
}
