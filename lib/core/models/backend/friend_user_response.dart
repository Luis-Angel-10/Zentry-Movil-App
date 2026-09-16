import 'package:Zentry/core/config/api_config.dart';

/// Espejo de `FriendUserResponse` del backend
/// (core/dtos/FriendUserResponse.java). Se usa para: lista de amigos,
/// solicitudes pendientes/enviadas y sugerencias
/// (`/api/core/friends/**`).
class FriendUserResponse {
  const FriendUserResponse({
    required this.id,
    this.username,
    this.name,
    this.avatarUrl,
    this.discipline,
    this.bio,
    this.isOnline = false,
    this.status,
    this.lastSeen,
    this.requestId,
    this.mutualFriendsCount,
    this.projectTitle,
  });

  /// ID del OTRO usuario (amigo / remitente / destinatario según la lista).
  final int id;
  final String? username;
  final String? name;
  final String? avatarUrl;
  final String? discipline;
  final String? bio;
  final bool isOnline;
  final String? status;
  final DateTime? lastSeen;

  /// ID de la solicitud (`FriendRequest`), presente en pendientes/enviadas.
  /// Necesario para `POST /requests/{id}/accept` y `/reject`.
  final int? requestId;
  final int? mutualFriendsCount;
  final String? projectTitle;

  String get displayName =>
      (name != null && name!.trim().isNotEmpty) ? name! : (username ?? '');

  String? get avatarUrlAbsolute => (avatarUrl == null || avatarUrl!.isEmpty)
      ? null
      : ApiConfig.resolveMediaUrl(avatarUrl);

  factory FriendUserResponse.fromJson(Map<String, dynamic> json) {
    return FriendUserResponse(
      id: (json['id'] as num).toInt(),
      username: json['username'] as String?,
      name: json['name'] as String?,
      avatarUrl: (json['avatar_url'] ?? json['avatarUrl']) as String?,
      discipline: json['discipline'] as String?,
      bio: json['bio'] as String?,
      isOnline: json['is_online'] == true || json['isOnline'] == true,
      status: json['status'] as String?,
      lastSeen: _date(json['last_seen'] ?? json['lastSeen']),
      requestId: (json['request_id'] ?? json['requestId']) as int?,
      mutualFriendsCount:
          (json['mutual_friends_count'] ?? json['mutualFriendsCount']) as int?,
      projectTitle: (json['project_title'] ?? json['projectTitle']) as String?,
    );
  }

  static DateTime? _date(dynamic v) =>
      (v is String && v.isNotEmpty) ? DateTime.tryParse(v) : null;
}
