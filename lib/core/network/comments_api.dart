import 'package:Zentry/core/models/backend/comment_response.dart';
import 'package:Zentry/core/network/api_client.dart';

/// Endpoints de comentarios (`/api/core/comments`).
///
/// Contrato real (CommentController):
///  * `GET  /post/{postId}`  -> lista de CommentResponse  (requiere JWT)
///  * `POST /post/{postId}`  -> 201 CommentResponse    body `{content}` (<=1000)
///  * `DELETE /{id}`         -> 204                     (sólo autor)
class CommentsApi {
  CommentsApi._();
  static final CommentsApi instance = CommentsApi._();

  ApiClient get _c => ApiClient.instance;

  Future<List<CommentResponse>> listByPost(int postId) {
    return _c.guard(
      () => _c.dio.get('/api/core/comments/post/$postId'),
      (data) => data is List
          ? data
                .whereType<Map>()
                .map(
                  (e) => CommentResponse.fromJson(Map<String, dynamic>.from(e)),
                )
                .toList()
          : const <CommentResponse>[],
    );
  }

  Future<CommentResponse> create(int postId, String content) {
    return _c.guard(
      () => _c.dio.post(
        '/api/core/comments/post/$postId',
        data: {'content': content},
      ),
      (data) =>
          CommentResponse.fromJson(Map<String, dynamic>.from(data as Map)),
    );
  }

  Future<void> delete(int commentId) {
    return _c.guard(
      () => _c.dio.delete('/api/core/comments/$commentId'),
      (_) {},
    );
  }
}
