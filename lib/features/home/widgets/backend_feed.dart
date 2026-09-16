import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';
import 'package:visibility_detector/visibility_detector.dart';

import 'package:Zentry/core/config/api_config.dart';
import 'package:Zentry/core/models/backend/comment_response.dart';
import 'package:Zentry/core/models/backend/post_response.dart';
import 'package:Zentry/core/network/api_exception.dart';
import 'package:Zentry/core/providers/auth_controller.dart';
import 'package:Zentry/core/providers/engagement_controller.dart';
import 'package:Zentry/core/providers/posts_controller.dart';
import 'package:Zentry/core/utils/text_format.dart';
import 'package:Zentry/features/chat/media_viewer_page.dart'
    show FullScreenVideo;
import 'package:Zentry/features/home/home_screen.dart'
    show AnimatedLikeButton, AnimatedActionButton;

/// Formatea una fecha del backend a texto relativo ("Hace 5 min").
String backendTimeAgo(DateTime? date) {
  if (date == null) return '';
  final diff = DateTime.now().difference(date);
  if (diff.inMinutes < 1) return 'Ahora';
  if (diff.inMinutes < 60) return 'Hace ${diff.inMinutes} min';
  if (diff.inHours < 24) return 'Hace ${diff.inHours} h';
  if (diff.inDays < 7) return 'Hace ${diff.inDays} d';
  return '${date.day}/${date.month}/${date.year}';
}

/// Tarjeta de publicación del feed real (backend). Replica el diseño de la
/// tarjeta local del Home pero se alimenta de un [PostResponse].
class BackendPostCard extends StatelessWidget {
  const BackendPostCard({super.key, required this.post});

  final PostResponse post;

  @override
  Widget build(BuildContext context) {
    final onSurface = Theme.of(context).colorScheme.onSurface;
    final postsController = context.read<PostsController>();
    final myUsername = context.select<AuthController, String?>(
      (a) => a.currentUser?.username,
    );
    final isMine =
        myUsername != null &&
        post.authorUsername != null &&
        myUsername.toLowerCase() == post.authorUsername!.toLowerCase();

    final avatarUrl = post.authorAvatar == null || post.authorAvatar!.isEmpty
        ? null
        : ApiConfig.resolveMediaUrl(post.authorAvatar);
    final imageUrl = post.imageUrlAbsolute;
    final subline = [
      if ((post.authorDiscipline ?? '').isNotEmpty) post.authorDiscipline,
      if (backendTimeAgo(post.createdAt).isNotEmpty)
        backendTimeAgo(post.createdAt),
    ].join(' • ');

    return Container(
      margin: const EdgeInsets.only(left: 14, right: 14, bottom: 18),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(26),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: Colors.white10,
                backgroundImage: avatarUrl != null
                    ? NetworkImage(avatarUrl)
                    : null,
                child: avatarUrl == null
                    ? const Icon(Icons.person, color: Colors.white54)
                    : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      post.authorName ?? post.authorUsername ?? 'usuario',
                      style: TextStyle(
                        color: onSurface,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    if (subline.isNotEmpty)
                      Text(
                        subline,
                        style: TextStyle(
                          color: onSurface.withOpacity(.6),
                          fontSize: 12,
                        ),
                      ),
                  ],
                ),
              ),
              if (isMine)
                IconButton(
                  onPressed: () => _confirmDelete(context, postsController),
                  icon: const Icon(Icons.more_horiz),
                )
              else
                const SizedBox(width: 8),
            ],
          ),
          const SizedBox(height: 14),
          if ((post.title ?? '').isNotEmpty) ...[
            Text(
              post.title!,
              style: TextStyle(
                color: onSurface,
                fontSize: 17,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
          ],
          if ((post.content ?? '').isNotEmpty)
            Text(
              stripArticleMarkers(post.content!),
              style: TextStyle(color: onSurface, fontSize: 15, height: 1.4),
            ),
          if (imageUrl != null && imageUrl.isNotEmpty) ...[
            const SizedBox(height: 14),
            ClipRRect(
              borderRadius: BorderRadius.circular(22),
              child: post.contentType == 'video'
                  ? _InlineFeedVideo(postId: post.id, url: imageUrl)
                  : Image.network(
                      imageUrl,
                      height: 240,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, progress) {
                        if (progress == null) return child;
                        return Container(
                          height: 240,
                          color: Colors.white10,
                          child: const Center(
                            child: CircularProgressIndicator(),
                          ),
                        );
                      },
                      errorBuilder: (_, __, ___) => Container(
                        height: 140,
                        color: Colors.white10,
                        alignment: Alignment.center,
                        child: const Icon(
                          Icons.broken_image_outlined,
                          color: Colors.white30,
                          size: 32,
                        ),
                      ),
                    ),
            ),
          ],
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              AnimatedLikeButton(
                key: ValueKey(
                  'like_${post.id}_${post.liked}_${post.likesCount}',
                ),
                likes: post.likesCount,
                initialLiked: post.liked,
                onToggle: (_) async {
                  try {
                    await postsController.toggleLikeBackend(post.id);
                  } on ApiException catch (e) {
                    _snack(context, e.message);
                  }
                },
                onLiked: () =>
                    context.read<EngagementController>().registerLike(),
              ),
              AnimatedActionButton(
                icon: Icons.mode_comment_outlined,
                badgeCount: post.commentsCount,
                onTap: () => showBackendCommentSheet(context, post),
              ),
              AnimatedActionButton(
                icon: Icons.share_outlined,
                onTap: () =>
                    context.read<EngagementController>().registerShare(),
              ),
              AnimatedActionButton(
                key: ValueKey('save_${post.id}_${post.saved}'),
                icon: Icons.bookmark_border,
                activeIcon: Icons.bookmark,
                initialActive: post.saved,
                onToggle: (_) async {
                  try {
                    await postsController.toggleBookmarkBackend(post.id);
                  } on ApiException catch (e) {
                    _snack(context, e.message);
                  }
                },
                onTap: () =>
                    context.read<EngagementController>().registerSave(),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _confirmDelete(
    BuildContext context,
    PostsController controller,
  ) async {
    final ok = await showModalBottomSheet<bool>(
      context: context,
      backgroundColor: Theme.of(context).cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (ctx) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(
                Icons.delete_outline,
                color: Colors.redAccent,
              ),
              title: const Text('Eliminar publicación'),
              onTap: () => Navigator.pop(ctx, true),
            ),
            ListTile(
              leading: const Icon(Icons.close),
              title: const Text('Cancelar'),
              onTap: () => Navigator.pop(ctx, false),
            ),
          ],
        ),
      ),
    );
    if (ok != true || !context.mounted) return;
    try {
      await controller.deleteBackendPost(post.id);
      _snack(context, 'Publicación eliminada');
    } on ApiException catch (e) {
      _snack(context, e.message);
    }
  }
}

/// Video inline del feed: mudo por defecto, sólo reproduce mientras está
/// suficientemente visible en pantalla (>=60%) y se pausa al salir de vista
/// — evita que varios videos del feed reproduzcan audio/CPU a la vez. Toca
/// para abrir a pantalla completa con controles (usa [FullScreenVideo],
/// el mismo reproductor reutilizado por el chat).
class _InlineFeedVideo extends StatefulWidget {
  const _InlineFeedVideo({required this.postId, required this.url});

  final int postId;
  final String url;

  @override
  State<_InlineFeedVideo> createState() => _InlineFeedVideoState();
}

class _InlineFeedVideoState extends State<_InlineFeedVideo> {
  VideoPlayerController? _controller;
  bool _error = false;
  bool _initializing = true;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    final c = VideoPlayerController.networkUrl(Uri.parse(widget.url));
    try {
      await c.initialize();
      if (!mounted) {
        c.dispose();
        return;
      }
      c
        ..setLooping(true)
        ..setVolume(0); // mudo por defecto en el feed
      setState(() {
        _controller = c;
        _initializing = false;
      });
    } catch (_) {
      c.dispose();
      if (!mounted) return;
      setState(() {
        _error = true;
        _initializing = false;
      });
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  void _onVisibilityChanged(VisibilityInfo info) {
    final c = _controller;
    if (c == null || !c.value.isInitialized) return;
    if (info.visibleFraction >= 0.6) {
      if (!c.value.isPlaying) c.play();
    } else {
      if (c.value.isPlaying) c.pause();
    }
  }

  void _openFullscreen() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0),
          body: Center(child: FullScreenVideo(networkUrl: widget.url)),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_error) {
      return Container(
        height: 200,
        color: Colors.white10,
        alignment: Alignment.center,
        child: const Icon(Icons.error_outline, color: Colors.white30, size: 32),
      );
    }
    if (_initializing || _controller == null) {
      return Container(
        height: 240,
        color: Colors.white10,
        alignment: Alignment.center,
        child: const CircularProgressIndicator(),
      );
    }

    final c = _controller!;
    return VisibilityDetector(
      key: ValueKey('feed_video_${widget.postId}'),
      onVisibilityChanged: _onVisibilityChanged,
      child: GestureDetector(
        onTap: _openFullscreen,
        child: AspectRatio(
          aspectRatio: c.value.aspectRatio,
          child: Stack(
            alignment: Alignment.center,
            fit: StackFit.expand,
            children: [
              VideoPlayer(c),
              if (!c.value.isPlaying)
                Container(
                  color: Colors.black26,
                  child: const Icon(
                    Icons.play_arrow,
                    color: Colors.white,
                    size: 46,
                  ),
                ),
              Positioned(
                right: 10,
                bottom: 10,
                child: Icon(
                  Icons.volume_off,
                  color: Colors.white.withOpacity(0.8),
                  size: 18,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

void _snack(BuildContext context, String msg) {
  if (!context.mounted) return;
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Text(msg),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
}

/// Hoja inferior de comentarios reales (`/api/core/comments/post/{id}`).
Future<void> showBackendCommentSheet(BuildContext context, PostResponse post) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Theme.of(context).cardColor,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
    ),
    builder: (_) => _CommentSheet(post: post),
  );
}

class _CommentSheet extends StatefulWidget {
  const _CommentSheet({required this.post});
  final PostResponse post;

  @override
  State<_CommentSheet> createState() => _CommentSheetState();
}

class _CommentSheetState extends State<_CommentSheet> {
  final _input = TextEditingController();
  final _scroll = ScrollController();
  List<CommentResponse> _comments = [];
  bool _loading = true;
  bool _sending = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _input.dispose();
    _scroll.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final list = await context.read<PostsController>().loadComments(
        widget.post.id,
      );
      if (!mounted) return;
      setState(() {
        _comments = list;
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

  Future<void> _send() async {
    final text = _input.text.trim();
    if (text.isEmpty || _sending) return;
    setState(() => _sending = true);
    try {
      final created = await context.read<PostsController>().addBackendComment(
        widget.post.id,
        text,
      );
      if (!mounted) return;
      setState(() {
        _comments = [..._comments, created];
        _input.clear();
        _sending = false;
      });
      context.read<EngagementController>().registerComment();
      await Future.delayed(const Duration(milliseconds: 100));
      if (_scroll.hasClients) {
        _scroll.animateTo(
          _scroll.position.maxScrollExtent,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
        );
      }
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() => _sending = false);
      _snack(context, e.message);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 14,
        bottom: MediaQuery.of(context).viewInsets.bottom + 14,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.white24,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 14),
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.42,
            child: _buildBody(),
          ),
          const Divider(height: 20),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _input,
                  minLines: 1,
                  maxLines: 4,
                  decoration: InputDecoration(
                    hintText: 'Escribe un comentario…',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              IconButton(
                onPressed: _sending ? null : _send,
                icon: _sending
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.send),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(_error!, textAlign: TextAlign.center),
            const SizedBox(height: 10),
            OutlinedButton(onPressed: _load, child: const Text('Reintentar')),
          ],
        ),
      );
    }
    if (_comments.isEmpty) {
      return const Center(
        child: Text(
          'Sé el primero en comentar',
          style: TextStyle(color: Colors.white54),
        ),
      );
    }
    return ListView.separated(
      controller: _scroll,
      itemCount: _comments.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (_, i) {
        final c = _comments[i];
        final avatar = c.authorAvatarUrlAbsolute;
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 16,
              backgroundColor: Colors.white10,
              backgroundImage: avatar != null ? NetworkImage(avatar) : null,
              child: avatar == null
                  ? const Icon(Icons.person, size: 16, color: Colors.white54)
                  : null,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    c.authorUsername ?? 'usuario',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(c.content ?? '', style: const TextStyle(fontSize: 14)),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
