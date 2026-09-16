import 'package:Zentry/core/config/api_config.dart';

/// Espejo de `PostResponse` del backend (core/dtos/PostResponse.java).
///
/// El backend expone el contenido con varias claves por compatibilidad:
/// `contenido` + `content` (getter), `content_type` + `type` (getter).
class PostResponse {
  const PostResponse({
    required this.id,
    this.authorUsername,
    this.authorAvatar,
    this.authorName,
    this.authorDiscipline,
    this.title,
    this.content,
    this.contentType,
    this.thumbnailUrl,
    this.imageUrl,
    this.visibility,
    this.communityId,
    this.tools = const [],
    this.mediaUrls = const [],
    this.tags = const [],
    this.likesCount = 0,
    this.commentsCount = 0,
    this.liked = false,
    this.saved = false,
    this.createdAt,
    this.updatedAt,
  });

  final int id;
  final String? authorUsername;
  final String? authorAvatar;
  final String? authorName;
  final String? authorDiscipline;
  final String? title;
  final String? content;
  final String? contentType;
  final String? thumbnailUrl;
  final String? imageUrl;
  final String? visibility;
  final int? communityId;
  final List<String> tools;
  final List<String> mediaUrls;
  final List<String> tags;
  final int likesCount;
  final int commentsCount;
  final bool liked;
  final bool saved;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  String? get imageUrlAbsolute {
    final raw = (imageUrl?.isNotEmpty == true)
        ? imageUrl
        : (thumbnailUrl?.isNotEmpty == true ? thumbnailUrl : null);
    return raw == null ? null : ApiConfig.resolveMediaUrl(raw);
  }

  List<String> get mediaUrlsAbsolute =>
      mediaUrls.map(ApiConfig.resolveMediaUrl).toList();

  PostResponse copyWith({
    String? title,
    String? content,
    String? contentType,
    String? visibility,
    int? likesCount,
    int? commentsCount,
    bool? liked,
    bool? saved,
    DateTime? updatedAt,
  }) {
    return PostResponse(
      id: id,
      authorUsername: authorUsername,
      authorAvatar: authorAvatar,
      authorName: authorName,
      authorDiscipline: authorDiscipline,
      title: title ?? this.title,
      content: content ?? this.content,
      contentType: contentType ?? this.contentType,
      thumbnailUrl: thumbnailUrl,
      imageUrl: imageUrl,
      visibility: visibility ?? this.visibility,
      communityId: communityId,
      tools: tools,
      mediaUrls: mediaUrls,
      tags: tags,
      likesCount: likesCount ?? this.likesCount,
      commentsCount: commentsCount ?? this.commentsCount,
      liked: liked ?? this.liked,
      saved: saved ?? this.saved,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  factory PostResponse.fromJson(Map<String, dynamic> json) {
    List<String> strList(dynamic v) =>
        v is List ? v.map((e) => e.toString()).toList() : const <String>[];

    return PostResponse(
      id: (json['id'] as num).toInt(),
      authorUsername: json['authorUsername'] as String?,
      authorAvatar: json['authorAvatar'] as String?,
      authorName: json['authorName'] as String?,
      authorDiscipline: json['authorDiscipline'] as String?,
      title: json['title'] as String?,
      content: (json['content'] ?? json['contenido']) as String?,
      contentType:
          (json['content_type'] ?? json['contentType'] ?? json['type'])
              as String?,
      thumbnailUrl: (json['thumbnail_url'] ?? json['thumbnailUrl']) as String?,
      imageUrl: (json['image_url'] ?? json['imageUrl']) as String?,
      visibility: json['visibility'] as String?,
      communityId: (json['communityId'] as num?)?.toInt(),
      tools: strList(json['tools']),
      mediaUrls: strList(json['mediaUrls']),
      tags: strList(json['tags']),
      likesCount: (json['likesCount'] as num?)?.toInt() ?? 0,
      commentsCount: (json['commentsCount'] as num?)?.toInt() ?? 0,
      liked: json['liked'] == true,
      saved: json['saved'] == true,
      createdAt: _date(json['createdAt']),
      updatedAt: _date(json['updatedAt']),
    );
  }

  static DateTime? _date(dynamic v) =>
      (v is String && v.isNotEmpty) ? DateTime.tryParse(v) : null;
}
