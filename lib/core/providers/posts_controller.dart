import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:Zentry/core/models/backend/comment_response.dart';
import 'package:Zentry/core/models/backend/post_response.dart';
import 'package:Zentry/core/network/api_exception.dart';
import 'package:Zentry/core/network/comments_api.dart';
import 'package:Zentry/core/network/posts_api.dart';
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
    notifyListeners();
  }

  // ─── Like / guardado (optimista, con reversión y anti doble-tap) ──────

  Future<void> toggleLikeBackend(int postId) async {
    if (_likeInFlight.contains(postId)) return;
    _likeInFlight.add(postId);

    final idx = backendPosts.indexWhere((p) => p.id == postId);
    PostResponse? original;
    if (idx != -1) {
      original = backendPosts[idx];
      final optimistic = original.copyWith(
        liked: !original.liked,
        likesCount: original.liked
            ? (original.likesCount - 1).clamp(0, 1 << 31)
            : original.likesCount + 1,
      );
      backendPosts[idx] = optimistic;
      _mirrorToMine(optimistic);
      notifyListeners();
    }

    try {
      final result = await PostsApi.instance.toggleLike(postId);
      _replaceBackendPost(result);
      notifyListeners();
    } on ApiException {
      if (original != null && idx != -1) {
        backendPosts[idx] = original;
        _mirrorToMine(original);
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

    final idx = backendPosts.indexWhere((p) => p.id == postId);
    PostResponse? original;
    if (idx != -1) {
      original = backendPosts[idx];
      backendPosts[idx] = original.copyWith(saved: !original.saved);
      _mirrorToMine(backendPosts[idx]);
      notifyListeners();
    }

    try {
      final saved = await PostsApi.instance.toggleBookmark(postId);
      if (idx != -1) {
        backendPosts[idx] = backendPosts[idx].copyWith(saved: saved);
        _mirrorToMine(backendPosts[idx]);
        notifyListeners();
      }
    } on ApiException {
      if (original != null && idx != -1) {
        backendPosts[idx] = original;
        _mirrorToMine(original);
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
    _mirrorToMine(post);
  }

  void _mirrorToMine(PostResponse post) {
    final j = myBackendPosts.indexWhere((p) => p.id == post.id);
    if (j != -1) myBackendPosts[j] = post;
  }

  // ─── Comentarios (backend) ────────────────────────────────────────────

  Future<List<CommentResponse>> loadComments(int postId) =>
      CommentsApi.instance.listByPost(postId);

  Future<CommentResponse> addBackendComment(int postId, String content) async {
    final created = await CommentsApi.instance.create(postId, content);
    final i = backendPosts.indexWhere((p) => p.id == postId);
    if (i != -1) {
      backendPosts[i] = backendPosts[i].copyWith(
        commentsCount: backendPosts[i].commentsCount + 1,
      );
      _mirrorToMine(backendPosts[i]);
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
