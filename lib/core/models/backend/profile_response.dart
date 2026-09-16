import 'package:Zentry/core/config/api_config.dart';

/// Espejo de `ProfileResponse` del backend (core/dtos/ProfileResponse.java).
///
/// Nota: este DTO NO incluye `id` ni `email` del usuario. El backend serializa
/// además `isFollowing` y `following` (mismo valor, doble clave).
class ProfileResponse {
  const ProfileResponse({
    required this.username,
    this.name,
    this.artisticName,
    this.discipline,
    this.experienceLevel,
    this.rank,
    this.location,
    this.bio,
    this.avatarUrl,
    this.bannerUrl,
    this.isPrivate,
    this.showSavedPosts,
    this.showLikedPosts,
    this.followersCount,
    this.followingCount,
    this.isFollowing = false,
    this.createdAt,
  });

  final String username;
  final String? name;
  final String? artisticName;
  final String? discipline;
  final String? experienceLevel;
  final String? rank;
  final String? location;
  final String? bio;

  /// URL (posiblemente relativa `/uploads/...`) devuelta por el backend.
  final String? avatarUrl;
  final String? bannerUrl;

  final bool? isPrivate;
  final bool? showSavedPosts;
  final bool? showLikedPosts;
  final int? followersCount;
  final int? followingCount;
  final bool isFollowing;
  final DateTime? createdAt;

  /// URL absoluta del avatar, resuelta contra el host correcto.
  String? get avatarUrlAbsolute => (avatarUrl == null || avatarUrl!.isEmpty)
      ? null
      : ApiConfig.resolveMediaUrl(avatarUrl);

  String? get bannerUrlAbsolute => (bannerUrl == null || bannerUrl!.isEmpty)
      ? null
      : ApiConfig.resolveMediaUrl(bannerUrl);

  factory ProfileResponse.fromJson(Map<String, dynamic> json) {
    return ProfileResponse(
      username: (json['username'] ?? '') as String,
      name: json['name'] as String?,
      artisticName: json['artisticName'] as String?,
      discipline: json['discipline'] as String?,
      experienceLevel: json['experienceLevel'] as String?,
      rank: json['rank'] as String?,
      location: json['location'] as String?,
      bio: json['bio'] as String?,
      avatarUrl: json['avatarUrl'] as String?,
      bannerUrl: json['bannerUrl'] as String?,
      isPrivate: json['isPrivate'] as bool?,
      showSavedPosts: json['showSavedPosts'] as bool?,
      showLikedPosts: json['showLikedPosts'] as bool?,
      followersCount: (json['followersCount'] as num?)?.toInt(),
      followingCount: (json['followingCount'] as num?)?.toInt(),
      isFollowing: json['isFollowing'] == true || json['following'] == true,
      createdAt: _parseDate(json['createdAt']),
    );
  }

  /// El backend serializa `LocalDateTime` como ISO-8601 sin zona
  /// (`2026-09-10T14:32:05.123`). Se parsea como hora local.
  static DateTime? _parseDate(dynamic v) {
    if (v == null) return null;
    if (v is String && v.isNotEmpty) return DateTime.tryParse(v);
    return null;
  }
}
