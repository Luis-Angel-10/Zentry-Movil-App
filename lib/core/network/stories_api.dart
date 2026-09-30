import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:http_parser/http_parser.dart' show MediaType;

import 'package:Zentry/core/models/backend/story_response.dart';
import 'package:Zentry/core/network/api_client.dart';

/// Endpoints de historias (`/api/core/stories`, alias `/api/v1/stories`).
/// TODOS requieren JWT (no hay ninguna regla `permitAll` para este path en
/// SecurityConfig, ni siquiera los GET).
class StoriesApi {
  StoriesApi._();
  static final StoriesApi instance = StoriesApi._();

  ApiClient get _c => ApiClient.instance;

  /// `GET /api/core/stories/feed` — historias activas (no expiradas, no
  /// archivadas) agrupadas por autor. Fuente única de verdad multi-
  /// dispositivo: el backend calcula expiración/vistas/likes server-side.
  Future<List<StoryGroupResponse>> getFeed() {
    return _c.guard(() => _c.dio.get('/api/core/stories/feed'), (data) {
      if (data is! List) return const <StoryGroupResponse>[];
      return data
          .whereType<Map>()
          .map((e) => StoryGroupResponse.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    });
  }

  /// `GET /api/core/stories/user/{userId}`.
  Future<List<StoryResponse>> getUserStories(int userId) {
    return _c.guard(() => _c.dio.get('/api/core/stories/user/$userId'), (data) {
      if (data is! List) return const <StoryResponse>[];
      return data
          .whereType<Map>()
          .map((e) => StoryResponse.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    });
  }

  /// `POST /api/core/stories` — JSON (sin archivo) o multipart (con
  /// `filePath`). `userId`/`expiresAt` los fija siempre el backend según el
  /// JWT — nunca se envían ni se pueden forzar desde el cliente.
  Future<StoryResponse> createStory({
    String? textContent,
    String? textColor,
    String? background,
    String? fontStyle,
    String? caption,
    int duration = 5000,
    String? filePath,
  }) {
    if (filePath == null || filePath.isEmpty) {
      final body = <String, dynamic>{
        'mediaType': 'TEXT',
        if (textContent != null) 'textContent': textContent,
        if (textColor != null) 'textColor': textColor,
        if (background != null) 'background': background,
        if (fontStyle != null) 'fontStyle': fontStyle,
        if (caption != null) 'caption': caption,
        'duration': duration,
      };
      return _c.guard(
        () => _c.dio.post('/api/core/stories', data: body),
        (data) =>
            StoryResponse.fromJson(Map<String, dynamic>.from(data as Map)),
      );
    }

    final storyJson = <String, dynamic>{
      if (caption != null) 'caption': caption,
      'duration': duration,
    };
    final form = FormData.fromMap({
      'story': MultipartFile.fromString(
        jsonEncode(storyJson),
        filename: 'story.json',
        contentType: MediaType('application', 'json'),
      ),
      'file': MultipartFile.fromFileSync(
        filePath,
        filename: filePath.split(RegExp(r'[/\\]')).last,
      ),
    });
    return _c.guard(
      // `sendTimeout`/`receiveTimeout` extendidos SÓLO para esta subida:
      // los 20s globales de `ApiClient` (pensados para peticiones JSON
      // livianas) se agotan fácilmente con un archivo de VIDEO real,
      // provocando que "subir historia de video" fallara por timeout aun
      // cuando el archivo y el endpoint eran correctos.
      () => _c.dio.post(
        '/api/core/stories',
        data: form,
        options: Options(
          sendTimeout: const Duration(seconds: 120),
          receiveTimeout: const Duration(seconds: 60),
        ),
      ),
      (data) => StoryResponse.fromJson(Map<String, dynamic>.from(data as Map)),
    );
  }

  /// `POST /api/core/stories/{id}/view`.
  Future<void> markViewed(int id) {
    return _c.guard(() => _c.dio.post('/api/core/stories/$id/view'), (_) {});
  }

  /// `POST /api/core/stories/{id}/like` — toggle. Devuelve `is_liked` real.
  Future<bool> toggleLike(int id) {
    return _c.guard(
      () => _c.dio.post('/api/core/stories/$id/like'),
      (data) => data is Map && data['is_liked'] == true,
    );
  }

  /// `POST /api/core/stories/{id}/reply` — se convierte en un DM real.
  Future<void> reply(int id, String content) {
    return _c.guard(
      () => _c.dio.post(
        '/api/core/stories/$id/reply',
        data: {'content': content},
      ),
      (_) {},
    );
  }

  /// `DELETE /api/core/stories/{id}` — soft-delete (archiva), sólo el autor.
  Future<void> deleteStory(int id) {
    return _c.guard(() => _c.dio.delete('/api/core/stories/$id'), (_) {});
  }
}
