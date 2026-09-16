import 'package:Zentry/core/config/api_config.dart';

/// Espejo de `CommentResponse` del backend (core/dtos/CommentResponse.java).
///
/// ```json
/// { "id": 3, "postId": 12, "userId": 5, "authorUsername": "luis",
///   "authorAvatarUrl": "/uploads/profiles/x.png",
///   "content": "gran trabajo", "createdAt": "2026-09-10T14:00:00" }
/// ```
class CommentResponse {
  const CommentResponse({
    required this.id,
    this.postId,
    this.userId,
    this.authorUsername,
    this.authorAvatarUrl,
    this.content,
    this.createdAt,
  });

  final int id;
  final int? postId;
  final int? userId;
  final String? authorUsername;
  final String? authorAvatarUrl;
  final String? content;
  final DateTime? createdAt;

  String? get authorAvatarUrlAbsolute =>
      (authorAvatarUrl == null || authorAvatarUrl!.isEmpty)
      ? null
      : ApiConfig.resolveMediaUrl(authorAvatarUrl);

  factory CommentResponse.fromJson(Map<String, dynamic> json) {
    return CommentResponse(
      id: (json['id'] as num).toInt(),
      postId: (json['postId'] as num?)?.toInt(),
      userId: (json['userId'] as num?)?.toInt(),
      authorUsername: json['authorUsername'] as String?,
      authorAvatarUrl: json['authorAvatarUrl'] as String?,
      content: json['content'] as String?,
      createdAt:
          (json['createdAt'] is String &&
              (json['createdAt'] as String).isNotEmpty)
          ? DateTime.tryParse(json['createdAt'] as String)
          : null,
    );
  }
}
