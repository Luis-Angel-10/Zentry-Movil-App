import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';
import 'package:visibility_detector/visibility_detector.dart';

import 'package:Zentry/core/config/api_config.dart';
import 'package:Zentry/core/models/app_user.dart';
import 'package:Zentry/core/models/backend/comment_response.dart';
import 'package:Zentry/core/models/backend/post_response.dart';
import 'package:Zentry/core/network/api_exception.dart';
import 'package:Zentry/core/providers/auth_controller.dart';
import 'package:Zentry/core/providers/community_controller.dart';
import 'package:Zentry/core/providers/engagement_controller.dart';
import 'package:Zentry/core/providers/posts_controller.dart';
import 'package:Zentry/core/providers/streak_controller.dart';
import 'package:Zentry/core/utils/text_format.dart';
import 'package:Zentry/core/video/zentry_video_decoder_coordinator.dart';
import 'package:Zentry/core/widgets/zentry_network_image.dart';
import 'package:Zentry/features/chat/media_viewer_page.dart'
    show FullScreenVideo;
import 'package:Zentry/features/communities/community_detail_screen.dart';
import 'package:Zentry/features/home/home_screen.dart'
    show AnimatedActionButton;
import 'package:Zentry/features/home/widgets/feed_media_viewer.dart';
import 'package:Zentry/features/home/widgets/reaction_button.dart';
import 'package:Zentry/features/profile/profile_screen.dart';
import 'package:Zentry/features/profile/public_profile_screen.dart';
import 'package:Zentry/l10n/generated/app_localizations.dart';

/// Abre el perfil del autor real de un post: el propio (editable) si el
/// post es del usuario autenticado, o el perfil público de lectura si es de
/// otro. `PostResponse` no incluye el id numérico del autor (confirmado por
/// lectura de `PostResponse.java`/DTO real) — sólo `authorUsername`, que es
/// exactamente lo que `PublicProfileScreen` usa para resolver el perfil
/// real contra el backend, así que no hace falta el id para que funcione.
void openAuthorProfile(BuildContext context, PostResponse post) {
  final username = post.authorUsername;
  if (username == null || username.isEmpty) return;
  final myUsername = context.read<AuthController>().currentUser?.username;
  final isMine =
      myUsername != null && myUsername.toLowerCase() == username.toLowerCase();
  if (isMine) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const ProfileScreen()),
    );
    return;
  }
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => PublicProfileScreen(
        user: AppUser(
          id: 0,
          fullName: post.authorName ?? username,
          username: username,
          email: '',
        ),
      ),
    ),
  );
}

void openPostCommunity(BuildContext context, int communityId) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => CommunityDetailScreen(identifier: communityId.toString()),
    ),
  );
}

/// "publicó en &lt;comunidad&gt; · Hace 2 min" — toque independiente del
/// autor (que ya navega al perfil desde el widget padre). El nombre real de
/// la comunidad no viene en `PostResponse` (sólo `communityId`, confirmado
/// por lectura del DTO real del backend), así que se resuelve/cachea vía
/// `CommunityController.ensureCommunityName`.
class _CommunityPostLine extends StatefulWidget {
  const _CommunityPostLine({required this.communityId, required this.timeAgo});

  final int communityId;
  final String timeAgo;

  @override
  State<_CommunityPostLine> createState() => _CommunityPostLineState();
}

class _CommunityPostLineState extends State<_CommunityPostLine> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<CommunityController>().ensureCommunityName(
        widget.communityId,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final name = context.select<CommunityController, String?>(
      (c) => c.communityNameFor(widget.communityId),
    );
    final onSurface = Theme.of(context).colorScheme.onSurface;
    return GestureDetector(
      onTap: () => openPostCommunity(context, widget.communityId),
      behavior: HitTestBehavior.opaque,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            name != null
                ? l10n.backendFeedPostedInCommunity(name)
                : l10n.backendFeedPostedInCommunityUnknown,
            style: TextStyle(
              color: onSurface.withValues(alpha: .75),
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          if (widget.timeAgo.isNotEmpty)
            Text(
              widget.timeAgo,
              style: TextStyle(
                color: onSurface.withValues(alpha: .6),
                fontSize: 12,
              ),
            ),
        ],
      ),
    );
  }
}

/// Formatea una fecha del backend a texto relativo ("Hace 5 min").
String backendTimeAgo(AppLocalizations l10n, DateTime? date) {
  if (date == null) return '';
  final diff = DateTime.now().difference(date);
  if (diff.inMinutes < 1) return l10n.backendFeedTimeAgoNow;
  if (diff.inMinutes < 60) {
    return l10n.backendFeedTimeAgoMinutes(diff.inMinutes);
  }
  if (diff.inHours < 24) return l10n.backendFeedTimeAgoHours(diff.inHours);
  if (diff.inDays < 7) return l10n.backendFeedTimeAgoDays(diff.inDays);
  return '${date.day}/${date.month}/${date.year}';
}

/// Tarjeta de publicación del feed real (backend). Replica el diseño de la
/// tarjeta local del Home pero se alimenta de un [PostResponse].
class BackendPostCard extends StatelessWidget {
  const BackendPostCard({super.key, required this.post});

  final PostResponse post;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
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
    final galleryUrls = post.mediaUrlsAbsolute;
    final timeAgo = backendTimeAgo(l10n, post.createdAt);
    final subline = [
      if ((post.authorDiscipline ?? '').isNotEmpty) post.authorDiscipline,
      if (timeAgo.isNotEmpty) timeAgo,
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
              GestureDetector(
                onTap: () => openAuthorProfile(context, post),
                child: ZentryAvatar(
                  radius: 22,
                  backgroundColor: Colors.white10,
                  networkUrl: avatarUrl,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: GestureDetector(
                  onTap: () => openAuthorProfile(context, post),
                  behavior: HitTestBehavior.opaque,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        post.authorName ??
                            post.authorUsername ??
                            l10n.backendFeedDefaultUsername,
                        style: TextStyle(
                          color: onSurface,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      // Distingue un post de comunidad de uno normal (autor y
                      // comunidad son destinos de navegación independientes,
                      // no toda la tarjeta es un único enlace).
                      if (post.communityId != null)
                        _CommunityPostLine(
                          communityId: post.communityId!,
                          timeAgo: timeAgo,
                        )
                      else if (subline.isNotEmpty)
                        Text(
                          subline,
                          style: TextStyle(
                            color: onSurface.withValues(alpha: .6),
                            fontSize: 12,
                          ),
                        ),
                    ],
                  ),
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
          if (post.isVideoContent &&
              imageUrl != null &&
              imageUrl.isNotEmpty) ...[
            const SizedBox(height: 14),
            ClipRRect(
              borderRadius: BorderRadius.circular(22),
              child: _InlineFeedVideo(
                key: ValueKey('inline_video_${post.id}'),
                postId: post.id,
                url: imageUrl,
              ),
            ),
          ] else if (!post.isVideoContent && galleryUrls.isNotEmpty) ...[
            const SizedBox(height: 14),
            _FeedImageGallery(imageUrls: galleryUrls),
          ] else if (!post.isVideoContent &&
              imageUrl != null &&
              imageUrl.isNotEmpty) ...[
            const SizedBox(height: 14),
            _FeedImageGallery(imageUrls: [imageUrl]),
          ],
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              ReactionButton(
                key: ValueKey(
                  'like_${post.id}_${post.liked}_${post.likesCount}',
                ),
                likes: post.likesCount,
                initialLiked: post.liked,
                onToggle: (_) async {
                  try {
                    await postsController.toggleLikeBackend(post.id);
                    // Corrección racha: el like es actividad real para el
                    // backend (`StreakService.recordActivity`) — sin este
                    // refresco la racha se quedaba desactualizada hasta
                    // reabrir la app (ver comentario igual en create_screen).
                    unawaited(context.read<StreakController>().load());
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
    final l10n = AppLocalizations.of(context)!;
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
              title: Text(l10n.backendFeedDeletePostTitle),
              onTap: () => Navigator.pop(ctx, true),
            ),
            ListTile(
              leading: const Icon(Icons.close),
              title: Text(l10n.commonCancel),
              onTap: () => Navigator.pop(ctx, false),
            ),
          ],
        ),
      ),
    );
    if (ok != true || !context.mounted) return;
    try {
      await controller.deleteBackendPost(post.id);
      _snack(context, l10n.backendFeedPostDeletedMessage);
    } on ApiException catch (e) {
      _snack(context, e.message);
    }
  }
}

/// Coordina que sólo un video del feed reproduzca a la vez. El umbral de
/// visibilidad (>=60%) por sí solo no lo garantiza cuando dos tarjetas caben
/// parcialmente en pantalla a la vez (pantallas grandes/tablets), así que
/// cualquier video que empieza a reproducirse pausa aquí al que estuviera
/// activo antes.
class _FeedVideoCoordinator {
  _FeedVideoCoordinator._();
  static final instance = _FeedVideoCoordinator._();

  _InlineFeedVideoState? _active;

  void requestPlay(_InlineFeedVideoState state) {
    if (_active != null && !identical(_active, state)) {
      _active!._pause();
    }
    _active = state;
  }

  void release(_InlineFeedVideoState state) {
    if (identical(_active, state)) _active = null;
  }
}

/// Video inline del feed: mudo por defecto, sólo reproduce mientras está
/// suficientemente visible en pantalla (>=60%) y se pausa al salir de vista.
/// Toca para abrir a pantalla completa con controles (usa [FullScreenVideo],
/// el mismo reproductor reutilizado por el chat).
///
/// CORRECCIÓN (investigación en Huawei MatePad SLG-W09 real, Kirin T92C):
/// logcat capturado por ADB mostró DOS videos del feed llamando a
/// `VideoPlayerController.initialize()` con ~17 ms de diferencia, y AMBOS
/// decoders (`OMX.hisi.video.decoder.avc`) fallando de forma idéntica
/// (`DecoderInitializationException` / `IllegalStateException` en
/// `MediaCodec.native_stop`) — con formatos H.264 totalmente distintos
/// (uno Baseline 1280x840, otro High Profile 576x768), o sea NO es un
/// problema de códec/perfil específico: este SoC de gama tablet sólo
/// soporta de forma fiable UN decoder de video activo a la vez (a
/// diferencia de un teléfono, donde dos videos inicializándose casi a la
/// vez simplemente funcionan). Antes, cada `_InlineFeedVideo` llamaba a
/// `initialize()` de inmediato en `initState()`, sin importar si el video
/// realmente estaba a la vista — en una tablet, donde caben más
/// publicaciones por pantalla que en un teléfono, eso dispara varios
/// decoders a la vez. Ahora:
///   1. Sólo se inicializa cuando [VisibilityDetector] confirma que el
///      video entró en pantalla (antes no había ninguna carga perezosa).
///   2. Se libera (dispose completo, no sólo pausa) al salir totalmente de
///      vista, para no retener un decoder mientras no se ve.
///   3. Toda inicialización pasa por [ZentryVideoDecoderCoordinator], que
///      garantiza que nunca se pidan dos decoders al sistema operativo al
///      mismo tiempo (la causa real confirmada arriba).
///   4. Si falla, reintenta (hasta 2 veces con backoff corto) antes de
///      mostrar el estado de error — muchos fallos de este tipo son
///      transitorios (dependen de qué otro decoder estaba ocupado en ese
///      instante).
class _InlineFeedVideo extends StatefulWidget {
  const _InlineFeedVideo({super.key, required this.postId, required this.url});

  final int postId;
  final String url;

  @override
  State<_InlineFeedVideo> createState() => _InlineFeedVideoState();
}

class _InlineFeedVideoState extends State<_InlineFeedVideo> {
  static const _maxAttempts = 3; // intento inicial + 2 reintentos

  VideoPlayerController? _controller;
  bool _error = false;
  bool _initializing = false;
  int _attempt = 0;

  @override
  void dispose() {
    _FeedVideoCoordinator.instance.release(this);
    _controller?.dispose();
    super.dispose();
  }

  void _initIfNeeded() {
    if (_controller != null || _initializing) return;
    _attempt = 0;
    _error = false;
    unawaited(_attemptInit());
  }

  Future<void> _attemptInit() async {
    if (!mounted) return;
    _attempt++;
    setState(() => _initializing = true);
    final c = VideoPlayerController.networkUrl(Uri.parse(widget.url));
    try {
      // Serializado app-wide: nunca dos `initialize()` de video al mismo
      // tiempo (ver doc-comment de la clase).
      await ZentryVideoDecoderCoordinator.instance.runExclusive(c.initialize);
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
    } catch (e) {
      c.dispose();
      debugPrint(
        '[Zentry][video] falló inicialización (intento $_attempt/$_maxAttempts) '
        'post ${widget.postId}: $e',
      );
      if (!mounted) return;
      if (_attempt < _maxAttempts) {
        await Future.delayed(Duration(milliseconds: 350 * _attempt));
        if (!mounted) return;
        await _attemptInit();
        return;
      }
      setState(() {
        _error = true;
        _initializing = false;
      });
    }
  }

  /// Sólo pausa (mantiene el decoder inicializado) — usado cuando otro video
  /// del feed pasa a ser el "activo" pero éste sigue parcialmente visible;
  /// distinto de [_release], que libera el decoder por completo.
  void _pause() {
    final c = _controller;
    if (c != null && c.value.isPlaying) c.pause();
    if (mounted) setState(() {});
  }

  /// Libera el controller (no sólo lo pausa): usado al salir totalmente de
  /// vista y al abrir el fullscreen, para que en cada momento haya como
  /// máximo un decoder de video activo entre el feed y el visor fullscreen.
  void _release() {
    _FeedVideoCoordinator.instance.release(this);
    final c = _controller;
    _controller = null;
    c?.dispose();
    if (mounted) setState(() {});
  }

  void _onVisibilityChanged(VisibilityInfo info) {
    if (info.visibleFraction <= 0) {
      if (_controller != null) _release();
      return;
    }
    if (_controller == null) {
      _initIfNeeded();
      return;
    }
    final c = _controller!;
    if (!c.value.isInitialized) return;
    if (info.visibleFraction >= 0.6) {
      if (!c.value.isPlaying) {
        _FeedVideoCoordinator.instance.requestPlay(this);
        c.play();
      }
    } else {
      if (c.value.isPlaying) c.pause();
      _FeedVideoCoordinator.instance.release(this);
    }
  }

  Future<void> _openFullscreen() async {
    // Libera el decoder inline ANTES de abrir el fullscreen: en el hardware
    // documentado arriba, tener dos decoders activos a la vez (el inline en
    // pausa + el fullscreen iniciando) puede fallar igual que dos en
    // reproducción simultánea.
    _release();
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0),
          body: Center(child: FullScreenVideo(networkUrl: widget.url)),
        ),
      ),
    );
    // Al volver, si el widget sigue vivo, se reinicializa (se liberó antes
    // a propósito). Si mientras tanto salió de pantalla, el próximo
    // callback de visibilidad lo libera de nuevo sin problema.
    if (mounted) _initIfNeeded();
  }

  @override
  Widget build(BuildContext context) {
    Widget content;
    if (_error) {
      content = Container(
        color: Colors.white10,
        alignment: Alignment.center,
        child: const Icon(Icons.error_outline, color: Colors.white30, size: 32),
      );
    } else if (_controller == null || !_controller!.value.isInitialized) {
      content = Container(
        color: Colors.white10,
        alignment: Alignment.center,
        child: _initializing
            ? const CircularProgressIndicator()
            : const SizedBox.shrink(),
      );
    } else {
      final c = _controller!;
      content = GestureDetector(
        onTap: _openFullscreen,
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
                color: Colors.white.withValues(alpha: 0.8),
                size: 18,
              ),
            ),
          ],
        ),
      );
    }

    // Proporción real cuando ya se conoce (video inicializado); mientras
    // tanto se reserva 1:1 para no saltar el layout. Acotada a los mismos
    // límites que las imágenes para que un video extremadamente vertical/
    // panorámico no ocupe varias pantallas, sobre todo en tablets donde la
    // tarjeta es mucho más ancha.
    final rawRatio = (_controller?.value.isInitialized ?? false)
        ? _controller!.value.aspectRatio
        : 1.0;
    final aspectRatio = rawRatio.clamp(
      kZentryMediaMinAspectRatio,
      kZentryMediaMaxAspectRatio,
    );

    return VisibilityDetector(
      key: ValueKey('feed_video_${widget.postId}'),
      onVisibilityChanged: _onVisibilityChanged,
      child: AspectRatio(aspectRatio: aspectRatio, child: content),
    );
  }
}

/// Imagen(es) de un post: 1 imagen se muestra sola respetando su proporción
/// real; 2+ se muestran en un carrusel horizontal con indicador de página
/// (cada imagen puede tener una proporción distinta, no se asume uniformidad).
/// Tocar cualquiera abre [FeedImageViewer] a pantalla completa con zoom.
class _FeedImageGallery extends StatefulWidget {
  const _FeedImageGallery({required this.imageUrls});
  final List<String> imageUrls;

  @override
  State<_FeedImageGallery> createState() => _FeedImageGalleryState();
}

class _FeedImageGalleryState extends State<_FeedImageGallery> {
  int _index = 0;

  void _openViewer(int initialIndex) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => FeedImageViewer(
          imageUrls: widget.imageUrls,
          initialIndex: initialIndex,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.imageUrls.length == 1) {
      return ZentryAspectRatioImage(
        imageUrl: widget.imageUrls.first,
        borderRadius: BorderRadius.circular(22),
        onTap: () => _openViewer(0),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(22),
      child: AspectRatio(
        aspectRatio: 1,
        child: Stack(
          children: [
            PageView.builder(
              itemCount: widget.imageUrls.length,
              onPageChanged: (i) => setState(() => _index = i),
              itemBuilder: (_, i) {
                final url = widget.imageUrls[i];
                return GestureDetector(
                  onTap: () => _openViewer(i),
                  child: ZentryNetworkImage(imageUrl: url, fit: BoxFit.cover),
                );
              },
            ),
            Positioned(
              bottom: 10,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(widget.imageUrls.length, (i) {
                  final active = i == _index;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    width: active ? 8 : 6,
                    height: active ? 8 : 6,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: active
                          ? Colors.white
                          : Colors.white.withValues(alpha: 0.5),
                    ),
                  );
                }),
              ),
            ),
            Positioned(
              top: 10,
              right: 10,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.black45,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '${_index + 1}/${widget.imageUrls.length}',
                  style: const TextStyle(color: Colors.white, fontSize: 11),
                ),
              ),
            ),
          ],
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
    // Se captura antes del await: si la sesión cambia mientras el comentario
    // está en vuelo, no se le cuenta a la cuenta que entró después.
    final authorId = context.read<AuthController>().currentUser?.id;
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
      context.read<EngagementController>().registerComment(
        forUserId: authorId,
      );
      // Corrección racha: ver comentario equivalente junto al like más
      // arriba en este mismo archivo.
      unawaited(context.read<StreakController>().load());
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
    final l10n = AppLocalizations.of(context)!;
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
                    hintText: l10n.backendFeedCommentHint,
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
    final l10n = AppLocalizations.of(context)!;
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
            OutlinedButton(onPressed: _load, child: Text(l10n.commonRetry)),
          ],
        ),
      );
    }
    if (_comments.isEmpty) {
      return Center(
        child: Text(
          l10n.backendFeedNoCommentsYet,
          style: const TextStyle(color: Colors.white54),
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
            ZentryAvatar(radius: 16, networkUrl: avatar),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    c.authorUsername ?? l10n.backendFeedDefaultUsername,
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
