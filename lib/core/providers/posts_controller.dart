import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:Zentry/core/models/backend/comment_response.dart';
import 'package:Zentry/core/models/backend/post_response.dart';
import 'package:Zentry/core/models/backend/story_response.dart';
import 'package:Zentry/core/network/api_exception.dart';
import 'package:Zentry/core/network/comments_api.dart';
import 'package:Zentry/core/network/posts_api.dart';
import 'package:Zentry/core/network/stories_api.dart';
import 'package:Zentry/core/providers/notifications_controller.dart';

class PostsController extends ChangeNotifier {
  static const _postsKey = 'posts_feed_data';
  static const _storiesKey = 'stories_feed_data';
  static const _feedPageSize = 20;

  NotificationsController? notifications;

  // ══════════════════════════════════════════════════════════════════════════
  //  FEED REAL DEL BACKEND  (GET /api/core/posts)  — Fase 2
  //  El Home consume `backendPosts`. La lista local `posts` de más abajo se
  //  mantiene SÓLO para comunidades / retos / historias (aún no integrados).
  // ══════════════════════════════════════════════════════════════════════════
  final List<PostResponse> backendPosts = [];
  bool feedLoading = false; // primera carga / refresh
  bool feedLoadingMore = false; // paginación
  String? feedError;
  bool feedLoaded = false;
  int _feedPage = 0;
  bool feedHasMore = true;

  final Set<int> _likeInFlight = {};
  final Set<int> _bookmarkInFlight = {};

  /// Primera carga o recarga completa (pull-to-refresh).
  Future<void> refreshFeed() => syncFromBackend();

  Future<void> syncFromBackend({int size = _feedPageSize}) async {
    feedLoading = true;
    feedError = null;
    notifyListeners();
    try {
      final result = await PostsApi.instance.getFeed(page: 0, size: size);
      backendPosts
        ..clear()
        ..addAll(result.items);
      _feedPage = 0;
      feedHasMore = !result.last && result.items.isNotEmpty;
      feedLoaded = true;
    } on ApiException catch (e) {
      feedError = e.message;
    } finally {
      feedLoading = false;
      notifyListeners();
    }
  }

  /// Página siguiente del feed (append). No-op si ya se está cargando o no hay más.
  Future<void> loadMoreFeed() async {
    if (feedLoadingMore || feedLoading || !feedHasMore) return;
    feedLoadingMore = true;
    notifyListeners();
    try {
      final next = _feedPage + 1;
      final result = await PostsApi.instance.getFeed(
        page: next,
        size: _feedPageSize,
      );
      final existing = backendPosts.map((p) => p.id).toSet();
      backendPosts.addAll(result.items.where((p) => !existing.contains(p.id)));
      _feedPage = next;
      feedHasMore = !result.last && result.items.isNotEmpty;
    } on ApiException catch (e) {
      feedError = e.message;
    } finally {
      feedLoadingMore = false;
      notifyListeners();
    }
  }

  // ─── Mis publicaciones (backend) ───────────────────────────────────────
  final List<PostResponse> myBackendPosts = [];
  bool myPostsLoading = false;
  String? myPostsError;
  bool myPostsLoaded = false;

  Future<void> loadMyBackendPosts() async {
    myPostsLoading = true;
    myPostsError = null;
    notifyListeners();
    try {
      final list = await PostsApi.instance.getMyPosts();
      myBackendPosts
        ..clear()
        ..addAll(list);
      myPostsLoaded = true;
    } on ApiException catch (e) {
      myPostsError = e.message;
    } finally {
      myPostsLoading = false;
      notifyListeners();
    }
  }

  // ─── Posts de una comunidad (backend) ──────────────────────────────────
  //
  // Lista separada de `backendPosts` (el feed general) para no mezclar
  // ambos — pero comparte exactamente el mismo `PostResponse` y los mismos
  // métodos de mutación (like/bookmark/comentar/borrar) de abajo, que
  // reflejan el cambio en AMBAS listas si el post está presente en ellas.
  // ══════════════════════════════════════════════════════════════════════════
  //  LIKES / GUARDADOS REALES (`GET /api/core/posts/liked|saved/{username}`)
  //
  //  CORRECCIÓN: `LikesScreen`/`SavedScreen` mostraban tarjetas 100%
  //  inventadas ("Paisaje", "Logo Moderno"...) sin relación con el backend.
  //  Estas listas y sus mutaciones pasan siempre por `toggleLikeBackend`/
  //  `toggleBookmarkBackend` (vía `_mirrorToLikedAndSaved`), así que dar/
  //  quitar like o guardado desde CUALQUIER pantalla (feed, comunidad,
  //  Likes, Guardados) mantiene las 5 listas (`backendPosts`,
  //  `myBackendPosts`, `communityPosts`, `likedBackendPosts`,
  //  `savedBackendPosts`) consistentes entre sí sin recargar nada.
  // ══════════════════════════════════════════════════════════════════════════
  final List<PostResponse> likedBackendPosts = [];
  bool likedPostsLoading = false;
  String? likedPostsError;
  bool likedPostsLoaded = false;

  final List<PostResponse> savedBackendPosts = [];
  bool savedPostsLoading = false;
  String? savedPostsError;
  bool savedPostsLoaded = false;

  Future<void> loadLikedPosts(String username) async {
    likedPostsLoading = true;
    likedPostsError = null;
    notifyListeners();
    try {
      final list = await PostsApi.instance.getLikedPosts(username);
      likedBackendPosts
        ..clear()
        ..addAll(list);
      likedPostsLoaded = true;
    } on ApiException catch (e) {
      likedPostsError = e.message;
    } finally {
      likedPostsLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadSavedPosts(String username) async {
    savedPostsLoading = true;
    savedPostsError = null;
    notifyListeners();
    try {
      final list = await PostsApi.instance.getSavedPosts(username);
      savedBackendPosts
        ..clear()
        ..addAll(list);
      savedPostsLoaded = true;
    } on ApiException catch (e) {
      savedPostsError = e.message;
    } finally {
      savedPostsLoading = false;
      notifyListeners();
    }
  }

  final List<PostResponse> communityPosts = [];
  bool communityPostsLoading = false;
  String? communityPostsError;
  String? _loadedCommunityIdentifier;

  Future<void> loadCommunityPosts(String identifier) async {
    communityPostsLoading = true;
    communityPostsError = null;
    _loadedCommunityIdentifier = identifier;
    notifyListeners();
    try {
      final result = await PostsApi.instance.getCommunityPosts(identifier);
      // El usuario pudo navegar a otra comunidad mientras esta petición
      // estaba en vuelo; no pisar sus posts con una respuesta obsoleta.
      if (_loadedCommunityIdentifier != identifier) return;
      communityPosts
        ..clear()
        ..addAll(result.items);
    } on ApiException catch (e) {
      if (_loadedCommunityIdentifier == identifier) {
        communityPostsError = e.message;
      }
    } finally {
      if (_loadedCommunityIdentifier == identifier) {
        communityPostsLoading = false;
        notifyListeners();
      }
    }
  }

  Future<PostResponse> createCommunityPostBackend(
    String identifier, {
    required String title,
    String? content,
    String? contentType,
    String? visibility,
    String? tools,
    String? imagePath,
  }) async {
    final created = await PostsApi.instance.createCommunityPost(
      identifier,
      title: title,
      content: content,
      contentType: contentType,
      visibility: visibility,
      tools: tools,
      imagePath: imagePath,
    );
    communityPosts.insert(0, created);
    notifyListeners();
    return created;
  }

  // ─── Crear / editar / borrar (backend) ────────────────────────────────

  /// Crea una publicación real. Devuelve el post creado o lanza [ApiException].
  Future<PostResponse> createBackendPost({
    required String title,
    String? content,
    String? contentType,
    String? visibility,
    String? tools,
    String? imagePath,
  }) async {
    final created = await PostsApi.instance.createPost(
      title: title,
      content: content,
      contentType: contentType,
      visibility: visibility,
      tools: tools,
      imagePath: imagePath,
    );
    backendPosts.insert(0, created);
    myBackendPosts.insert(0, created);
    notifyListeners();
    return created;
  }

  Future<PostResponse> updateBackendPost(
    int id, {
    String? title,
    String? content,
    String? contentType,
    String? visibility,
    String? tools,
  }) async {
    final updated = await PostsApi.instance.updatePost(
      id,
      title: title,
      content: content,
      contentType: contentType,
      visibility: visibility,
      tools: tools,
    );
    _replaceBackendPost(updated);
    notifyListeners();
    return updated;
  }

  Future<void> deleteBackendPost(int id) async {
    await PostsApi.instance.deletePost(id);
    backendPosts.removeWhere((p) => p.id == id);
    myBackendPosts.removeWhere((p) => p.id == id);
    communityPosts.removeWhere((p) => p.id == id);
    notifyListeners();
  }

  // ─── Like / guardado (optimista, con reversión y anti doble-tap) ──────

  /// Busca el post en CUALQUIERA de las 5 listas que puede mostrarlo (no
  /// sólo feed/comunidad): togglear like/guardado desde `LikesScreen` o
  /// `SavedScreen` parte de un post que puede no estar en `backendPosts`.
  PostResponse? _findAnywhere(int postId) {
    for (final list in [
      backendPosts,
      myBackendPosts,
      communityPosts,
      likedBackendPosts,
      savedBackendPosts,
    ]) {
      for (final p in list) {
        if (p.id == postId) return p;
      }
    }
    return null;
  }

  /// Aplica [post] a las 5 listas donde exista (optimista o definitivo).
  void _applyEverywhere(PostResponse post) {
    void replaceIn(List<PostResponse> list) {
      final i = list.indexWhere((p) => p.id == post.id);
      if (i != -1) list[i] = post;
    }

    replaceIn(backendPosts);
    replaceIn(myBackendPosts);
    replaceIn(communityPosts);
    replaceIn(likedBackendPosts);
    replaceIn(savedBackendPosts);
  }

  Future<void> toggleLikeBackend(int postId) async {
    if (_likeInFlight.contains(postId)) return;
    _likeInFlight.add(postId);

    final original = _findAnywhere(postId);
    if (original != null) {
      final optimistic = original.copyWith(
        liked: !original.liked,
        likesCount: original.liked
            ? (original.likesCount - 1).clamp(0, 1 << 31)
            : original.likesCount + 1,
      );
      _applyEverywhere(optimistic);
      notifyListeners();
    }

    try {
      final result = await PostsApi.instance.toggleLike(postId);
      // `_replaceBackendPost` ya actualiza backendPosts/communityPosts/
      // myBackendPosts Y agrega-o-quita en likedBackendPosts/savedBackendPosts
      // según corresponda (ver `_mirrorToLikedAndSaved`) — no hace falta
      // duplicar con `_applyEverywhere` aquí.
      _replaceBackendPost(result);
      notifyListeners();
    } on ApiException {
      if (original != null) {
        _applyEverywhere(original);
        notifyListeners();
      }
      rethrow;
    } finally {
      _likeInFlight.remove(postId);
    }
  }

  Future<void> toggleBookmarkBackend(int postId) async {
    if (_bookmarkInFlight.contains(postId)) return;
    _bookmarkInFlight.add(postId);

    final original = _findAnywhere(postId);
    if (original != null) {
      final optimistic = original.copyWith(saved: !original.saved);
      _applyEverywhere(optimistic);
      notifyListeners();
    }

    try {
      final saved = await PostsApi.instance.toggleBookmark(postId);
      if (original != null) {
        final updated = original.copyWith(saved: saved);
        _replaceBackendPost(updated);
        notifyListeners();
      }
    } on ApiException {
      if (original != null) {
        _applyEverywhere(original);
        notifyListeners();
      }
      rethrow;
    } finally {
      _bookmarkInFlight.remove(postId);
    }
  }

  void _replaceBackendPost(PostResponse post) {
    final i = backendPosts.indexWhere((p) => p.id == post.id);
    if (i != -1) backendPosts[i] = post;
    final j = communityPosts.indexWhere((p) => p.id == post.id);
    if (j != -1) communityPosts[j] = post;
    _mirrorToMine(post);
    _mirrorToLikedAndSaved(post);
  }

  void _mirrorToMine(PostResponse post) {
    final j = myBackendPosts.indexWhere((p) => p.id == post.id);
    if (j != -1) myBackendPosts[j] = post;
  }

  /// Mantiene `likedBackendPosts`/`savedBackendPosts` coherentes con
  /// cualquier toggle real hecho desde OTRA pantalla (Sección 12 — evitar
  /// "Feed: ❤️ liked / Likes: no aparece"). Si el post pasa a `liked`/
  /// `saved` y todavía no estaba en la lista correspondiente, se inserta al
  /// frente (igual que lo haría un refresh real); si deja de estarlo, se
  /// quita de inmediato en vez de esperar la siguiente recarga.
  void _mirrorToLikedAndSaved(PostResponse post) {
    final li = likedBackendPosts.indexWhere((p) => p.id == post.id);
    if (post.liked) {
      if (li != -1) {
        likedBackendPosts[li] = post;
      } else if (likedPostsLoaded) {
        likedBackendPosts.insert(0, post);
      }
    } else if (li != -1) {
      likedBackendPosts.removeAt(li);
    }

    final si = savedBackendPosts.indexWhere((p) => p.id == post.id);
    if (post.saved) {
      if (si != -1) {
        savedBackendPosts[si] = post;
      } else if (savedPostsLoaded) {
        savedBackendPosts.insert(0, post);
      }
    } else if (si != -1) {
      savedBackendPosts.removeAt(si);
    }
  }

  // ─── Comentarios (backend) ────────────────────────────────────────────

  Future<List<CommentResponse>> loadComments(int postId) =>
      CommentsApi.instance.listByPost(postId);

  Future<CommentResponse> addBackendComment(int postId, String content) async {
    final created = await CommentsApi.instance.create(postId, content);
    final i = backendPosts.indexWhere((p) => p.id == postId);
    final j = communityPosts.indexWhere((p) => p.id == postId);
    if (i != -1 || j != -1) {
      final base = i != -1 ? backendPosts[i] : communityPosts[j];
      final updated = base.copyWith(commentsCount: base.commentsCount + 1);
      if (i != -1) backendPosts[i] = updated;
      if (j != -1) communityPosts[j] = updated;
      _mirrorToMine(updated);
      notifyListeners();
    }
    return created;
  }

  final List<Map<String, dynamic>> posts = [
    {
      "id": "mock_0",
      "user": "Luis Martínez",
      "category": "Programación",
      "time": "Hace 5 min",
      "image": "https://images.unsplash.com/photo-1515879218367-8466d910aaa4",
      "imageFile": null,
      "content": "Desarrollando nuevas funciones para Zentry 🚀",
      "likes": 124,
      "comments": <String>[],
    },
    {
      "id": "mock_1",
      "user": "Ana Torres",
      "category": "Arte Digital",
      "time": "Hace 12 min",
      "image": "https://images.unsplash.com/photo-1513364776144-60967b0f800f",
      "imageFile": null,
      "content": "Nueva ilustración inspirada en cyberpunk ✨",
      "likes": 312,
      "comments": <String>[],
    },
    {
      "id": "mock_2",
      "user": "Carlos Ruiz",
      "category": "GameDev",
      "time": "Hace 18 min",
      "image": "https://images.unsplash.com/photo-1493711662062-fa541adb3fc8",
      "imageFile": null,
      "content": "Probando físicas nuevas en Unity 🎮",
      "likes": 220,
      "comments": <String>[],
    },
    {
      "id": "mock_3",
      "user": "María López",
      "category": "Fotografía",
      "time": "Hace 30 min",
      "image": "https://images.unsplash.com/photo-1492691527719-9d1e07e534b4",
      "imageFile": null,
      "content": "Capturando momentos urbanos 📸",
      "likes": 98,
      "comments": <String>[],
    },
    {
      "id": "mock_4",
      "user": "Alex Rivera",
      "category": "Música",
      "time": "Hace 1 hora",
      "image": "https://images.unsplash.com/photo-1511379938547-c1f69419868d",
      "imageFile": null,
      "content": "Trabajando en un nuevo beat 🎧",
      "likes": 441,
      "comments": <String>[],
    },
    {
      "id": "mock_5",
      "user": "Fernanda",
      "category": "Diseño UI",
      "time": "Hace 2 horas",
      "image": "https://images.unsplash.com/photo-1558655146-d09347e92766",
      "imageFile": null,
      "content": "Experimentando nuevos estilos minimalistas.",
      "likes": 189,
      "comments": <String>[],
    },
    {
      "id": "mock_6",
      "user": "Daniel Vega",
      "category": "Animación",
      "time": "Hace 3 horas",
      "image": "https://images.unsplash.com/photo-1574717024653-61fd2cf4d44d",
      "imageFile": null,
      "content": "Render final listo 🔥",
      "likes": 274,
      "comments": <String>[],
    },
    {
      "id": "mock_7",
      "user": "Valeria Cruz",
      "category": "PixelArt",
      "time": "Hace 4 horas",
      "image": "https://images.unsplash.com/photo-1545239351-1141bd82e8a6",
      "imageFile": null,
      "content": "Diseñando escenarios retro 👾",
      "likes": 165,
      "comments": <String>[],
    },
    {
      "id": "mock_8",
      "user": "Diego León",
      "category": "Escritura",
      "time": "Hace 5 horas",
      "image": "https://images.unsplash.com/photo-1455390582262-044cdead277a",
      "imageFile": null,
      "content": "Nuevo capítulo terminado ✍️",
      "likes": 76,
      "comments": <String>[],
    },
    {
      "id": "mock_9",
      "user": "Sofía Morales",
      "category": "Video",
      "time": "Hace 6 horas",
      "image": "https://images.unsplash.com/photo-1492619375914-88005aa9e8fb",
      "imageFile": null,
      "content": "Editando cinematicas para un corto 🎬",
      "likes": 530,
      "comments": <String>[],
    },
  ];

  final List<Map<String, dynamic>> stories = [];

  // ══════════════════════════════════════════════════════════════════════
  //  HISTORIAS REALES DEL BACKEND (`/api/core/stories`) — Fase 3B
  //
  //  `stories`/`addStory`/`groupedVisibleStories` de arriba son 100% locales
  //  (SharedPreferences, `File` locales) — por eso una historia publicada en
  //  un teléfono nunca aparecía en otro dispositivo: no sólo faltaba la
  //  llamada al backend, el propio `StoryViewerScreen` sólo sabía reproducir
  //  `File` locales, nunca una URL de red. Esta sección es la fuente de
  //  verdad real: sobrevive cierre de app y cambia de dispositivo porque
  //  vive en Postgres, con expiración de 24h calculada server-side.
  //
  //  El código local de arriba se conserva (no se borró) por si algo lo usa
  //  todavía (p. ej. destacados de perfil, que no tienen equivalente
  //  backend), pero el feed de historias visible ya no lo alimenta.
  // ══════════════════════════════════════════════════════════════════════
  final List<StoryGroupResponse> backendStoryGroups = [];
  bool storiesLoading = false;
  String? storiesError;
  bool storiesLoaded = false;

  Future<void> loadBackendStories() async {
    storiesLoading = true;
    storiesError = null;
    notifyListeners();
    try {
      final groups = await StoriesApi.instance.getFeed();
      backendStoryGroups
        ..clear()
        ..addAll(groups);
      storiesLoaded = true;
    } on ApiException catch (e) {
      storiesError = e.message;
    } finally {
      storiesLoading = false;
      notifyListeners();
    }
  }

  /// Publica una historia real. `filePath` es la foto/video recién elegido
  /// (local, sin subir todavía); el backend lo sube y devuelve la URL real.
  /// Refresca el feed de historias al terminar para reflejar el cambio de
  /// inmediato (mismo patrón que pull-to-refresh).
  Future<StoryResponse> createBackendStory({
    String? textContent,
    String? textColor,
    String? background,
    String? caption,
    String? filePath,
  }) async {
    final created = await StoriesApi.instance.createStory(
      textContent: textContent,
      textColor: textColor,
      background: background,
      caption: caption,
      filePath: filePath,
    );
    await loadBackendStories();
    return created;
  }

  Future<void> viewBackendStory(int storyId) async {
    try {
      await StoriesApi.instance.markViewed(storyId);
    } on ApiException {
      // Vista no crítica: si falla, la historia sigue mostrándose bien; no
      // hay UI que dependa de que esta llamada específica tenga éxito.
    }
  }

  /// Responde una historia REAL (`POST /api/core/stories/{id}/reply`).
  ///
  /// CORRECCIÓN: antes "Responder a la historia" sólo abría un chat local
  /// vacío (`ChatScreen(initialContactName:, initialMessage:)`, un mock sin
  /// backend) — la respuesta nunca se enviaba de verdad. Confirmado por
  /// lectura de `StoryService.replyToStory` (backend, sin modificar): esta
  /// llamada SÍ crea/reutiliza la conversación 1 a 1 real entre ambos
  /// usuarios (`ConversationService.startDirect`) y guarda un `Message` real
  /// con `type:"story"` y el contenido `↩️ "<preview de la historia>": <tu
  /// respuesta>`. El propio endpoint no devuelve el mensaje ni el id de la
  /// conversación (`Map.of("success", true)` únicamente) — por eso quien
  /// llama a este método debe además navegar a
  /// `ConversationScreen(otherUserId: ...)`, que obtiene/crea esa misma
  /// conversación por su cuenta (`POST /direct/{otherUserId}`, idempotente).
  Future<void> replyToBackendStory(int storyId, String content) {
    return StoriesApi.instance.reply(storyId, content);
  }

  Future<void> toggleBackendStoryLike(int storyId) async {
    StoryResponse? original;
    for (final group in backendStoryGroups) {
      final idx = group.items.indexWhere((s) => s.id == storyId);
      if (idx == -1) continue;
      original = group.items[idx];
      final optimistic = original.copyWith(
        isLiked: !original.isLiked,
        likesCount: original.isLiked
            ? (original.likesCount - 1).clamp(0, 1 << 31)
            : original.likesCount + 1,
      );
      group.items[idx] = optimistic;
      break;
    }
    notifyListeners();

    try {
      final isLiked = await StoriesApi.instance.toggleLike(storyId);
      for (final group in backendStoryGroups) {
        final idx = group.items.indexWhere((s) => s.id == storyId);
        if (idx == -1) continue;
        group.items[idx] = group.items[idx].copyWith(isLiked: isLiked);
        break;
      }
      notifyListeners();
    } on ApiException {
      if (original == null) return;
      for (final group in backendStoryGroups) {
        final idx = group.items.indexWhere((s) => s.id == storyId);
        if (idx == -1) continue;
        group.items[idx] = original;
        break;
      }
      notifyListeners();
    }
  }

  Future<void> deleteBackendStory(int storyId) async {
    await StoriesApi.instance.deleteStory(storyId);
    for (final group in backendStoryGroups) {
      group.items.removeWhere((s) => s.id == storyId);
    }
    backendStoryGroups.removeWhere((g) => g.items.isEmpty);
    notifyListeners();
  }

  /// Adapta `StoryGroupResponse` real al mismo `StoryGroup`/shape de Map que
  /// ya consumía `story_viewer_screen.dart`, agregando las claves nuevas
  /// `mediaUrl`/`mediaIsVideo`/`storyIntId` que ese visor ahora entiende
  /// además de `imageFile`/`videoFile` (locales). No se tocó el resto del
  /// contrato de esa pantalla.
  ///
  /// [viewerDisplayName] sólo se usa para reconstruir la clave `viewedBy`
  /// que ya esperaban `StoryGroup.allSeenBy`/`firstUnseenIndexFor` — el
  /// dato real de "¿lo vi?" es `is_viewed`, calculado por el backend para
  /// el usuario autenticado; aquí sólo se traduce a la forma que ya
  /// entendía la UI existente, sin inventar nada.
  ///
  /// CAUSA RAÍZ del crash "Bad state: No element" (Fase 3B — corrección):
  /// `GET /api/core/stories/feed` devuelve, A PROPÓSITO, un grupo con
  /// `items: []` para el usuario autenticado cuando éste todavía no tiene
  /// ninguna historia activa (`StoryService.buildEmptyGroupForUser` en el
  /// backend — confirmado por lectura del código real, no se modificó).
  /// Ese grupo vacío existe para que el backend confirme el `userId` del
  /// dueño de sesión, pero Flutter ya tiene su PROPIO tile fijo de "Tu
  /// historia" (primer elemento de la lista horizontal en `home_screen`),
  /// así que ese grupo vacío no debe llegar nunca a la UI: `StoryGroup
  /// .latest` hace `items.last`, que lanza `StateError: Bad state: No
  /// element` sobre una lista vacía. Se filtra aquí, en el único punto de
  /// transformación hacia la UI, para cubrir todos los casos (carga
  /// inicial, refresh, y cualquier mutación futura), en vez de parchear
  /// cada sitio que llama a `.latest` con un try/catch que escondería el
  /// problema real.
  List<StoryGroup> backendGroupedStories({String viewerDisplayName = ''}) {
    return backendStoryGroups.where((group) => group.items.isNotEmpty).map((
      group,
    ) {
      final items = group.items
          .map(
            (s) => _adaptStoryItem(
              s,
              displayName: group.displayName,
              username: group.username,
              userId: group.userId,
              avatarUrl: group.avatarUrlAbsolute,
              viewerDisplayName: viewerDisplayName,
            ),
          )
          .toList();
      return StoryGroup(
        user: group.displayName,
        userId: group.userId,
        items: items,
      );
    }).toList();
  }

  String _relativeTime(DateTime? date) {
    if (date == null) return '';
    final diff = DateTime.now().difference(date);
    if (diff.inMinutes < 1) return 'Ahora';
    if (diff.inMinutes < 60) return 'Hace ${diff.inMinutes} min';
    if (diff.inHours < 24) return 'Hace ${diff.inHours} h';
    return 'Hace ${diff.inDays} d';
  }

  Map<String, dynamic> _adaptStoryItem(
    StoryResponse s, {
    required String displayName,
    required String username,
    required int userId,
    String? avatarUrl,
    String viewerDisplayName = '',
  }) {
    return <String, dynamic>{
      'id': 's${s.id}',
      'storyIntId': s.id,
      'user': displayName,
      'userId': userId,
      // Username real (login), distinto del display name — necesario para
      // abrir la conversación REAL con
      // `ConversationScreen(otherUserId:, otherUsername:)` al responder.
      'username': username,
      'category': 'Historia',
      'time': _relativeTime(s.createdAt),
      'image': null,
      'imageFile': null,
      'videoFile': null,
      'mediaUrl': s.mediaUrlAbsolute,
      'mediaIsVideo': s.isVideo,
      'avatarUrl': avatarUrl,
      'content': s.caption ?? s.textContent ?? '',
      'likes': s.likesCount,
      'likedByMe': s.isLiked,
      'viewCount': s.viewCount,
      'comments': const <String>[],
      'viewedBy': s.isViewed && viewerDisplayName.isNotEmpty
          ? [viewerDisplayName]
          : const <String>[],
      'highlighted': false,
    };
  }

  /// Historias ACTIVAS de un usuario específico (Sección 7: verlas desde su
  /// avatar en el perfil, propio o ajeno). Usa
  /// `GET /api/core/stories/user/{userId}` (confirmado: filtra por
  /// `expiresAt > now && !isArchived` server-side — "activa" real, no una
  /// suposición de Flutter), adaptado al mismo formato de Map que ya
  /// entiende `StoryViewerScreen`.
  Future<List<Map<String, dynamic>>> loadUserActiveStories(
    int userId, {
    required String displayName,
    required String username,
    String? avatarUrl,
    String viewerDisplayName = '',
  }) async {
    final stories = await StoriesApi.instance.getUserStories(userId);
    return stories
        .map(
          (s) => _adaptStoryItem(
            s,
            displayName: displayName,
            username: username,
            userId: userId,
            avatarUrl: avatarUrl,
            viewerDisplayName: viewerDisplayName,
          ),
        )
        .toList();
  }

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();

    final rawPosts = prefs.getString(_postsKey);
    if (rawPosts != null) {
      try {
        final decoded = jsonDecode(rawPosts) as List<dynamic>;
        posts
          ..clear()
          ..addAll(decoded.map((e) => _decodePost(e as Map<String, dynamic>)));
      } catch (_) {}
    }

    final rawStories = prefs.getString(_storiesKey);
    if (rawStories != null) {
      try {
        final decoded = jsonDecode(rawStories) as List<dynamic>;
        stories
          ..clear()
          ..addAll(decoded.map((e) => _decodePost(e as Map<String, dynamic>)));
      } catch (_) {}
    }

    notifyListeners();
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _postsKey,
      jsonEncode(posts.map(_encodePost).toList()),
    );
  }

  Future<void> _persistStories() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _storiesKey,
      jsonEncode(stories.map(_encodePost).toList()),
    );
  }

  Map<String, dynamic> _encodePost(Map<String, dynamic> post) {
    final encoded = Map<String, dynamic>.from(post);
    encoded.remove("imageFile");
    encoded.remove("videoFile");
    encoded["imagePath"] = (post["imageFile"] as File?)?.path;
    encoded["videoPath"] = (post["videoFile"] as File?)?.path;
    return encoded;
  }

  Map<String, dynamic> _decodePost(Map<String, dynamic> raw) {
    final decoded = Map<String, dynamic>.from(raw);
    final imagePath = decoded.remove("imagePath") as String?;
    final videoPath = decoded.remove("videoPath") as String?;

    decoded["imageFile"] = imagePath != null ? File(imagePath) : null;
    decoded["videoFile"] = videoPath != null ? File(videoPath) : null;
    decoded["comments"] = List<String>.from(
      (raw["comments"] as List?) ?? const [],
    );
    decoded["roles"] = raw["roles"] != null
        ? List<String>.from(raw["roles"] as List)
        : null;
    decoded["tags"] = raw["tags"] != null
        ? List<String>.from(raw["tags"] as List)
        : null;
    decoded["id"] ??= _generateId();
    if (raw.containsKey("viewedBy") || raw.containsKey("highlighted")) {
      decoded["viewedBy"] = List<String>.from(
        (raw["viewedBy"] as List?) ?? const [],
      );
      decoded["highlighted"] = raw["highlighted"] == true;
    }

    return decoded;
  }

  String _generateId() => DateTime.now().microsecondsSinceEpoch.toString();

  Map<String, dynamic>? findPostById(String id) {
    for (final post in posts) {
      if (post["id"] == id) return post;
    }
    return null;
  }

  int indexOfPostId(String id) {
    for (var i = 0; i < posts.length; i++) {
      if (posts[i]["id"] == id) return i;
    }
    return -1;
  }

  List<Map<String, dynamic>> postsByUser(String userDisplayName) {
    return posts.where((p) => p["user"] == userDisplayName).toList();
  }

  List<Map<String, dynamic>> postsForChallenge(String challengeId) {
    return posts.where((p) => p["challengeId"] == challengeId).toList();
  }

  String _preview(String text, {int maxLength = 42}) {
    final trimmed = text.trim();
    if (trimmed.length <= maxLength) return trimmed;
    return '${trimmed.substring(0, maxLength).trim()}…';
  }

  String addPost({
    required String content,
    required String category,
    required String user,
    String? title,
    File? imageFile,
    File? videoFile,
    String? fileName,
    int? fileSizeBytes,
    double? progress,
    List<String>? roles,
    List<String>? tags,
    bool? isPublicCollab,
    String? communityId,
    String? communityName,
    String? challengeId,
    double? videoTrimStart,
    double? videoTrimEnd,
  }) {
    final id = _generateId();
    posts.insert(0, {
      "id": id,
      "user": user,
      "category": category,
      "time": "Ahora",
      "image": null,
      "imageFile": imageFile,
      "videoFile": videoFile,
      "videoTrimStart": videoTrimStart,
      "videoTrimEnd": videoTrimEnd,
      "fileName": fileName,
      "fileSizeBytes": fileSizeBytes,
      "title": title,
      "progress": progress,
      "roles": roles,
      "tags": tags,
      "isPublicCollab": isPublicCollab,
      "content": content,
      "likes": 0,
      "likedByMe": false,
      "comments": <String>[],
      "saved": false,
      "communityId": communityId,
      "challengeId": challengeId,
    });

    notifyListeners();
    _persist();

    if (communityId != null && communityName != null) {
      notifications?.push(AppNotificationType.communityNewPost, {
        'communityId': communityId,
        'communityName': communityName,
      });
    }

    return id;
  }

  void toggleLike(int index) {
    if (index < 0 || index >= posts.length) return;

    final likedByMe = posts[index]["likedByMe"] == true;
    final likes = (posts[index]["likes"] as int?) ?? 0;
    final becameLiked = !likedByMe;

    posts[index]["likedByMe"] = becameLiked;
    posts[index]["likes"] = likedByMe
        ? (likes - 1).clamp(0, 1 << 31)
        : likes + 1;

    notifyListeners();
    _persist();

    if (becameLiked) {
      notifications?.push(AppNotificationType.like, {
        'postPreview': _preview(posts[index]["content"] as String? ?? ''),
        'postId': posts[index]["id"],
      });
    }
  }

  List<Map<String, dynamic>> postsForCommunity(String communityId) {
    return posts.where((p) => p["communityId"] == communityId).toList();
  }

  void setSaved(int index, bool value) {
    if (index < 0 || index >= posts.length) return;

    posts[index]["saved"] = value;
    notifyListeners();
    _persist();
  }

  String addStory({
    required String content,
    required String user,
    required int userId,
    String visibility = 'public',
    File? imageFile,
    File? videoFile,
    double? videoTrimStart,
    double? videoTrimEnd,
  }) {
    final id = _generateId();
    stories.insert(0, {
      "id": id,
      "user": user,
      "userId": userId,
      "visibility": visibility,
      "category": "Historia",
      "time": "Ahora",
      "image": null,
      "imageFile": imageFile,
      "videoFile": videoFile,
      "videoTrimStart": videoTrimStart,
      "videoTrimEnd": videoTrimEnd,
      "content": content,
      "likes": 0,
      "comments": <String>[],
      "viewedBy": <String>[],
      "highlighted": false,
    });

    notifyListeners();
    _persistStories();
    return id;
  }

  Map<String, dynamic>? findStoryById(String id) {
    for (final story in stories) {
      if (story["id"] == id) return story;
    }
    return null;
  }

  void deleteStory(String storyId) {
    final before = stories.length;
    stories.removeWhere((s) => s["id"] == storyId);
    if (stories.length == before) return;

    notifyListeners();
    _persistStories();
  }

  void registerStoryView(String storyId, String viewerName) {
    final story = findStoryById(storyId);
    if (story == null || story["user"] == viewerName) return;

    final viewedBy = List<String>.from(story["viewedBy"] as List? ?? const []);
    if (viewedBy.contains(viewerName)) return;

    viewedBy.add(viewerName);
    story["viewedBy"] = viewedBy;
    notifyListeners();
    _persistStories();
  }

  List<String> storyViewers(String storyId) {
    final story = findStoryById(storyId);
    return List<String>.from(story?["viewedBy"] as List? ?? const []);
  }

  List<Map<String, dynamic>> highlightedStoriesOf(String userDisplayName) {
    return stories
        .where((s) => s["user"] == userDisplayName && s["highlighted"] == true)
        .toList();
  }

  void toggleStoryHighlight(String storyId) {
    final story = findStoryById(storyId);
    if (story == null) return;

    story["highlighted"] = !(story["highlighted"] == true);
    notifyListeners();
    _persistStories();
  }

  List<Map<String, dynamic>> visibleStories({
    required String viewerName,
    required bool Function(int authorUserId) isFollowing,
  }) {
    return stories.where((s) {
      if (s["visibility"] != 'followers') return true;
      if (s["user"] == viewerName) return true;
      final authorId = s["userId"] as int?;
      return authorId != null && isFollowing(authorId);
    }).toList();
  }

  List<StoryGroup> groupedVisibleStories({
    required String viewerName,
    required bool Function(int authorUserId) isFollowing,
  }) {
    final visible = visibleStories(
      viewerName: viewerName,
      isFollowing: isFollowing,
    );

    final order = <String>[];
    final byUser = <String, List<Map<String, dynamic>>>{};
    for (final s in visible) {
      final user = s["user"] as String;
      final bucket = byUser.putIfAbsent(user, () {
        order.add(user);
        return [];
      });
      bucket.add(s);
    }

    return [
      for (final user in order)
        StoryGroup(
          user: user,
          userId: byUser[user]!.first["userId"] as int?,
          items: byUser[user]!.reversed.toList(),
        ),
    ];
  }

  void addComment(int index, String text, {required String actorName}) {
    if (index < 0 || index >= posts.length) return;

    (posts[index]["comments"] as List<String>).add(text);
    notifyListeners();
    _persist();

    notifications?.push(AppNotificationType.comment, {
      'actorName': actorName,
      'commentText': _preview(text, maxLength: 60),
      'postId': posts[index]["id"],
    });
  }
}

class StoryGroup {
  final String user;
  final int? userId;
  final List<Map<String, dynamic>> items;

  const StoryGroup({
    required this.user,
    required this.userId,
    required this.items,
  });

  Map<String, dynamic> get latest => items.last;

  bool allSeenBy(String viewerName) {
    return items.every((s) {
      if (s["user"] == viewerName) return true;
      final viewedBy = List<String>.from(s["viewedBy"] as List? ?? const []);
      return viewedBy.contains(viewerName);
    });
  }

  int firstUnseenIndexFor(String viewerName) {
    for (var i = 0; i < items.length; i++) {
      final s = items[i];
      if (s["user"] == viewerName) continue;
      final viewedBy = List<String>.from(s["viewedBy"] as List? ?? const []);
      if (!viewedBy.contains(viewerName)) return i;
    }
    return 0;
  }
}
