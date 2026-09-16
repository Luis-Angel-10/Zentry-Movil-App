import 'package:dio/dio.dart';

import 'package:Zentry/core/models/backend/post_response.dart';
import 'package:Zentry/core/network/api_client.dart';

/// Página de resultados devuelta por Spring Data (`Page<T>`).
class PagedResult<T> {
  const PagedResult({
    required this.items,
    this.page = 0,
    this.totalPages = 1,
    this.totalElements = 0,
    this.last = true,
  });

  final List<T> items;
  final int page;
  final int totalPages;
  final int totalElements;
  final bool last;
}

/// Endpoints de publicaciones (`/api/core/posts`, alias `/api/v1/posts`).
///
/// `GET /api/core/posts` (feed) es PÚBLICO. El resto requiere JWT.
class PostsApi {
  PostsApi._();
  static final PostsApi instance = PostsApi._();

  ApiClient get _c => ApiClient.instance;

  /// `GET /api/core/posts?page=&size=` — feed general.
  ///
  /// El backend devuelve un `Page` (objeto con `content`) para el feed general
  /// y una `List` plana cuando `scope=my`. Se soportan ambas formas.
  Future<PagedResult<PostResponse>> getFeed({int page = 0, int size = 20}) {
    return _c.guard(
      () => _c.dio.get(
        '/api/core/posts',
        queryParameters: {'page': page, 'size': size},
      ),
      (data) => _parsePaged(data),
    );
  }

  /// `GET /api/core/posts?scope=my` — publicaciones del usuario autenticado.
  Future<List<PostResponse>> getMyPosts() {
    return _c.guard(
      () => _c.dio.get('/api/core/posts', queryParameters: {'scope': 'my'}),
      (data) => _parseList(data),
    );
  }

  /// `GET /api/core/posts/by-user/{username}`.
  Future<List<PostResponse>> getPostsByUsername(String username) {
    return _c.guard(
      () => _c.dio.get('/api/core/posts/by-user/$username'),
      (data) => _parseList(data),
    );
  }

  /// `GET /api/core/posts/{id}`.
  Future<PostResponse> getById(int id) {
    return _c.guard(
      () => _c.dio.get('/api/core/posts/$id'),
      (data) => PostResponse.fromJson(Map<String, dynamic>.from(data as Map)),
    );
  }

  // ─── Escritura (requiere JWT) ──────────────────────────────────────────

  /// `POST /api/core/posts`. Usa JSON si no hay imagen; multipart si `imagePath`.
  ///
  /// Contrato real (`PostRequest`): `title` es obligatorio; el resto opcional.
  /// El backend ignora `mediaUrls` y `tagIds`; `tools` es un String separado por
  /// comas. Para multipart se usan los nombres reales de campo (`contenido`,
  /// `contentType`, `image`) porque `@JsonAlias` no aplica al binding de forms.
  Future<PostResponse> createPost({
    required String title,
    String? content,
    String? contentType,
    String? visibility,
    String? tools,
    String? imagePath,
  }) {
    if (imagePath == null || imagePath.isEmpty) {
      final body = <String, dynamic>{'title': title};
      if (content != null) body['contenido'] = content;
      if (contentType != null) body['contentType'] = contentType;
      if (visibility != null) body['visibility'] = visibility;
      if (tools != null && tools.isNotEmpty) body['tools'] = tools;
      return _c.guard(
        () => _c.dio.post('/api/core/posts', data: body),
        (data) => PostResponse.fromJson(Map<String, dynamic>.from(data as Map)),
      );
    }

    final form = FormData.fromMap({
      'title': title,
      if (content != null) 'contenido': content,
      if (contentType != null) 'contentType': contentType,
      if (visibility != null) 'visibility': visibility,
      if (tools != null && tools.isNotEmpty) 'tools': tools,
      'image': MultipartFile.fromFileSync(
        imagePath,
        filename: imagePath.split(RegExp(r'[/\\]')).last,
      ),
    });
    return _c.guard(
      () => _c.dio.post('/api/core/posts', data: form),
      (data) => PostResponse.fromJson(Map<String, dynamic>.from(data as Map)),
    );
  }

  /// `PUT /api/core/posts/{id}` (JSON). Actualización parcial: sólo campos != null.
  Future<PostResponse> updatePost(
    int id, {
    String? title,
    String? content,
    String? contentType,
    String? visibility,
    String? tools,
  }) {
    final body = <String, dynamic>{};
    if (title != null) body['title'] = title;
    if (content != null) body['contenido'] = content;
    if (contentType != null) body['contentType'] = contentType;
    if (visibility != null) body['visibility'] = visibility;
    if (tools != null) body['tools'] = tools;
    return _c.guard(
      () => _c.dio.put('/api/core/posts/$id', data: body),
      (data) => PostResponse.fromJson(Map<String, dynamic>.from(data as Map)),
    );
  }

  /// `DELETE /api/core/posts/{id}` → 204.
  Future<void> deletePost(int id) {
    return _c.guard(() => _c.dio.delete('/api/core/posts/$id'), (_) {});
  }

  /// `POST /api/core/posts/{id}/like` — alterna me gusta. Devuelve el post.
  Future<PostResponse> toggleLike(int id) {
    return _c.guard(
      () => _c.dio.post('/api/core/posts/$id/like'),
      (data) => PostResponse.fromJson(Map<String, dynamic>.from(data as Map)),
    );
  }

  /// `POST /api/core/posts/{id}/bookmark` — alterna guardado.
  /// Devuelve `{"saved": bool}`.
  Future<bool> toggleBookmark(int id) {
    return _c.guard(
      () => _c.dio.post('/api/core/posts/$id/bookmark'),
      (data) => data is Map && data['saved'] == true,
    );
  }

  // --- helpers de parseo ---

  static List<PostResponse> _parseList(dynamic data) {
    if (data is List) {
      return data
          .whereType<Map>()
          .map((e) => PostResponse.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    }
    if (data is Map && data['content'] is List) {
      return (data['content'] as List)
          .whereType<Map>()
          .map((e) => PostResponse.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    }
    return const [];
  }

  static PagedResult<PostResponse> _parsePaged(dynamic data) {
    if (data is List) {
      final items = _parseList(data);
      return PagedResult(items: items, totalElements: items.length);
    }
    if (data is Map) {
      final items = _parseList(data['content']);
      return PagedResult(
        items: items,
        page: (data['number'] as num?)?.toInt() ?? 0,
        totalPages: (data['totalPages'] as num?)?.toInt() ?? 1,
        totalElements: (data['totalElements'] as num?)?.toInt() ?? items.length,
        last: data['last'] == true,
      );
    }
    return const PagedResult(items: []);
  }
}
