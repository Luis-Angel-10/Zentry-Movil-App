import 'package:Zentry/core/config/api_config.dart';

/// Espejo de `CommunityResponse` del backend (core/dtos/CommunityResponse.java).
///
/// El backend NO tiene concepto de privacidad/aprobación de ingreso, ni de
/// subcategoría ni hashtags — esos campos existían sólo en el modelo local
/// (`lib/core/models/community.dart`, ahora legado) y no tienen equivalente
/// aquí. `isJoined`/`membersCount` se calculan server-side, no se persisten.
class CommunityResponse {
  const CommunityResponse({
    required this.id,
    required this.slug,
    required this.nombre,
    this.descripcion,
    this.imageUrl,
    this.avatarUrl,
    this.bannerUrl,
    this.categoria,
    this.creatorId,
    this.ownerUsername,
    this.rules = const [],
    this.membersCount = 0,
    this.isJoined = false,
    this.createdAt,
  });

  final int id;
  final String slug;
  final String nombre;
  final String? descripcion;
  final String? imageUrl;
  final String? avatarUrl;
  final String? bannerUrl;
  final String? categoria;
  final int? creatorId;
  final String? ownerUsername;
  final List<String> rules;
  final int membersCount;
  final bool isJoined;
  final DateTime? createdAt;

  String? get avatarUrlAbsolute => (avatarUrl == null || avatarUrl!.isEmpty)
      ? null
      : ApiConfig.resolveMediaUrl(avatarUrl);

  String? get bannerUrlAbsolute => (bannerUrl == null || bannerUrl!.isEmpty)
      ? null
      : ApiConfig.resolveMediaUrl(bannerUrl);

  /// El identificador que aceptan los endpoints (`{identifier}`) puede ser
  /// el id numérico o el slug; se usa el slug cuando existe por legibilidad
  /// en rutas/estado, con el id como respaldo.
  String get identifier => slug.isNotEmpty ? slug : id.toString();

  CommunityResponse copyWith({int? membersCount, bool? isJoined}) {
    return CommunityResponse(
      id: id,
      slug: slug,
      nombre: nombre,
      descripcion: descripcion,
      imageUrl: imageUrl,
      avatarUrl: avatarUrl,
      bannerUrl: bannerUrl,
      categoria: categoria,
      creatorId: creatorId,
      ownerUsername: ownerUsername,
      rules: rules,
      membersCount: membersCount ?? this.membersCount,
      isJoined: isJoined ?? this.isJoined,
      createdAt: createdAt,
    );
  }

  factory CommunityResponse.fromJson(Map<String, dynamic> json) {
    return CommunityResponse(
      id: (json['id'] as num?)?.toInt() ?? 0,
      slug: (json['slug'] as String?) ?? '',
      nombre: (json['nombre'] as String?) ?? '',
      descripcion: json['descripcion'] as String?,
      imageUrl: json['imageUrl'] as String?,
      avatarUrl: json['avatarUrl'] as String?,
      bannerUrl: json['bannerUrl'] as String?,
      categoria: json['categoria'] as String?,
      creatorId: (json['creatorId'] as num?)?.toInt(),
      ownerUsername: json['ownerUsername'] as String?,
      rules: json['rules'] is List
          ? List<String>.from(json['rules'] as List)
          : const [],
      membersCount: (json['membersCount'] as num?)?.toInt() ?? 0,
      isJoined: json['isJoined'] == true,
      createdAt: json['createdAt'] is String
          ? DateTime.tryParse(json['createdAt'] as String)
          : null,
    );
  }
}

/// Espejo de `ForumThreadResponse`. La API de foros queda lista aquí
/// (`CommunitiesApi.getForumThreads`/`createForumThread`), pero Flutter
/// todavía no tiene ninguna pantalla de foros — ver reporte final.
class ForumThreadResponse {
  const ForumThreadResponse({
    required this.id,
    required this.communityId,
    this.authorUserId,
    this.title,
    this.content,
    this.createdAt,
  });

  final int id;
  final int communityId;
  final int? authorUserId;
  final String? title;
  final String? content;
  final DateTime? createdAt;

  factory ForumThreadResponse.fromJson(Map<String, dynamic> json) {
    return ForumThreadResponse(
      id: (json['id'] as num?)?.toInt() ?? 0,
      communityId: (json['communityId'] as num?)?.toInt() ?? 0,
      authorUserId: (json['authorUserId'] as num?)?.toInt(),
      title: json['title'] as String?,
      content: json['content'] as String?,
      createdAt: json['createdAt'] is String
          ? DateTime.tryParse(json['createdAt'] as String)
          : null,
    );
  }
}
