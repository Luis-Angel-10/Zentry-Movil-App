import 'package:Zentry/core/config/api_config.dart';

/// Espejo de `StoryResponse` del backend (core/dtos/StoryResponse.java).
/// El backend serializa en snake_case (`@JsonProperty`).
class StoryResponse {
  const StoryResponse({
    required this.id,
    required this.userId,
    this.username,
    this.userName,
    this.userAvatar,
    this.mediaUrl,
    this.mediaType = 'IMAGE',
    this.textContent,
    this.textColor,
    this.background,
    this.fontStyle,
    this.caption,
    this.duration = 5000,
    this.createdAt,
    this.expiresAt,
    this.viewCount = 0,
    this.likesCount = 0,
    this.isViewed = false,
    this.isLiked = false,
    this.isArchived = false,
  });

  final int id;
  final int userId;
  final String? username;
  final String? userName;
  final String? userAvatar;
  final String? mediaUrl;
  final String mediaType; // IMAGE | VIDEO | TEXT
  final String? textContent;
  final String? textColor;
  final String? background;
  final String? fontStyle;
  final String? caption;
  final int duration;
  final DateTime? createdAt;
  final DateTime? expiresAt;
  final int viewCount;
  final int likesCount;
  final bool isViewed;
  final bool isLiked;
  final bool isArchived;

  bool get isVideo => mediaType.toUpperCase() == 'VIDEO';
  bool get isTextOnly => mediaType.toUpperCase() == 'TEXT' || mediaUrl == null;

  String? get mediaUrlAbsolute => (mediaUrl == null || mediaUrl!.isEmpty)
      ? null
      : ApiConfig.resolveMediaUrl(mediaUrl);

  String? get userAvatarAbsolute =>
      (userAvatar == null || userAvatar!.isEmpty)
      ? null
      : ApiConfig.resolveMediaUrl(userAvatar);

  StoryResponse copyWith({bool? isLiked, int? likesCount, bool? isViewed}) {
    return StoryResponse(
      id: id,
      userId: userId,
      username: username,
      userName: userName,
      userAvatar: userAvatar,
      mediaUrl: mediaUrl,
      mediaType: mediaType,
      textContent: textContent,
      textColor: textColor,
      background: background,
      fontStyle: fontStyle,
      caption: caption,
      duration: duration,
      createdAt: createdAt,
      expiresAt: expiresAt,
      viewCount: viewCount,
      likesCount: likesCount ?? this.likesCount,
      isViewed: isViewed ?? this.isViewed,
      isLiked: isLiked ?? this.isLiked,
      isArchived: isArchived,
    );
  }

  factory StoryResponse.fromJson(Map<String, dynamic> json) {
    DateTime? parseDate(dynamic v) =>
        v is String ? DateTime.tryParse(v) : null;
    return StoryResponse(
      id: (json['id'] as num?)?.toInt() ?? 0,
      userId: (json['user_id'] as num?)?.toInt() ?? 0,
      username: json['username'] as String?,
      userName: json['user_name'] as String?,
      userAvatar: json['user_avatar'] as String?,
      mediaUrl: json['media_url'] as String?,
      mediaType: (json['media_type'] as String?) ?? 'IMAGE',
      textContent: json['text_content'] as String?,
      textColor: json['text_color'] as String?,
      background: json['background'] as String?,
      fontStyle: json['font_style'] as String?,
      caption: json['caption'] as String?,
      duration: (json['duration'] as num?)?.toInt() ?? 5000,
      createdAt: parseDate(json['created_at']),
      expiresAt: parseDate(json['expires_at']),
      viewCount: (json['view_count'] as num?)?.toInt() ?? 0,
      likesCount: (json['likes_count'] as num?)?.toInt() ?? 0,
      isViewed: json['is_viewed'] == true,
      isLiked: json['is_liked'] == true,
      isArchived: json['is_archived'] == true,
    );
  }
}

/// Espejo de `StoryGroupResponse` — historias activas agrupadas por autor,
/// tal como las entrega `GET /api/core/stories/feed`.
class StoryGroupResponse {
  const StoryGroupResponse({
    required this.userId,
    required this.username,
    this.name,
    this.avatarUrl,
    this.isUser = false,
    this.hasUnseen = false,
    this.items = const [],
  });

  final int userId;
  final String username;
  final String? name;
  final String? avatarUrl;
  final bool isUser;
  final bool hasUnseen;
  final List<StoryResponse> items;

  String get displayName =>
      (name != null && name!.trim().isNotEmpty) ? name! : username;

  String? get avatarUrlAbsolute => (avatarUrl == null || avatarUrl!.isEmpty)
      ? null
      : ApiConfig.resolveMediaUrl(avatarUrl);

  factory StoryGroupResponse.fromJson(Map<String, dynamic> json) {
    return StoryGroupResponse(
      userId: (json['user_id'] as num?)?.toInt() ?? 0,
      username: (json['username'] as String?) ?? '',
      name: json['name'] as String?,
      avatarUrl: (json['avatar_url'] as String?),
      isUser: json['is_user'] == true,
      hasUnseen: json['has_unseen'] == true,
      items: json['items'] is List
          ? (json['items'] as List)
                .whereType<Map>()
                .map((e) => StoryResponse.fromJson(Map<String, dynamic>.from(e)))
                .toList()
          : const [],
    );
  }
}
