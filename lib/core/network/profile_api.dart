import 'package:dio/dio.dart';

import 'package:Zentry/core/models/backend/profile_response.dart';
import 'package:Zentry/core/network/api_client.dart';

/// Endpoints de perfil (`/api/core/profiles`, alias `/api/v1/profiles`).
///
/// `GET /me` y `PUT /me` requieren JWT. `GET /{identifier}` es público.
class ProfileApi {
  ProfileApi._();
  static final ProfileApi instance = ProfileApi._();

  ApiClient get _c => ApiClient.instance;

  Map<String, dynamic> _asMap(dynamic data) =>
      data is Map ? Map<String, dynamic>.from(data) : <String, dynamic>{};

  /// `GET /api/core/profiles/me` — perfil del usuario autenticado.
  Future<ProfileResponse> getMyProfile() {
    return _c.guard(
      () => _c.dio.get('/api/core/profiles/me'),
      (data) => ProfileResponse.fromJson(_asMap(data)),
    );
  }

  /// `GET /api/core/profiles/search?q=` — búsqueda de perfiles por nombre.
  /// Público.
  Future<List<ProfileResponse>> searchProfiles(String query) {
    return _c.guard(
      () => _c.dio.get(
        '/api/core/profiles/search',
        queryParameters: {'q': query},
      ),
      (data) => data is List
          ? data
                .whereType<Map>()
                .map(
                  (e) => ProfileResponse.fromJson(Map<String, dynamic>.from(e)),
                )
                .toList()
          : const <ProfileResponse>[],
    );
  }

  /// `GET /api/core/profiles/by-user-id/{userId}` — perfil por ID numérico
  /// (útil para resolver el "otro usuario" de una conversación, ya que
  /// `ConversationSummaryResponse` sólo trae `otherUserId`, sin username ni
  /// avatar). Público.
  Future<ProfileResponse> getProfileByUserId(int userId) {
    return _c.guard(
      () => _c.dio.get('/api/core/profiles/by-user-id/$userId'),
      (data) => ProfileResponse.fromJson(_asMap(data)),
    );
  }

  /// `POST /api/core/profiles/{identifier}/follow` — alterna seguir/dejar de
  /// seguir (requiere JWT). Devuelve el nuevo estado y contador reales.
  Future<FollowToggleResult> toggleFollow(String identifier) {
    return _c.guard(
      () => _c.dio.post('/api/core/profiles/$identifier/follow'),
      (data) {
        final map = _asMap(data);
        return FollowToggleResult(
          following: map['following'] == true || map['isFollowing'] == true,
          followersCount: (map['followersCount'] as num?)?.toInt() ?? 0,
        );
      },
    );
  }

  /// `GET /api/core/follows/followers/{username}` — perfiles que siguen a
  /// [username]. Requiere JWT (no está en la lista pública de SecurityConfig).
  Future<List<ProfileResponse>> getFollowers(String username) {
    return _c.guard(
      () => _c.dio.get('/api/core/follows/followers/$username'),
      (data) => data is List
          ? data
                .whereType<Map>()
                .map(
                  (e) => ProfileResponse.fromJson(Map<String, dynamic>.from(e)),
                )
                .toList()
          : const <ProfileResponse>[],
    );
  }

  /// `GET /api/core/follows/following/{username}` — perfiles que sigue
  /// [username].
  Future<List<ProfileResponse>> getFollowing(String username) {
    return _c.guard(
      () => _c.dio.get('/api/core/follows/following/$username'),
      (data) => data is List
          ? data
                .whereType<Map>()
                .map(
                  (e) => ProfileResponse.fromJson(Map<String, dynamic>.from(e)),
                )
                .toList()
          : const <ProfileResponse>[],
    );
  }

  /// `GET /api/core/profiles/{identifier}` — perfil público (username o email).
  Future<ProfileResponse> getProfile(String identifier) {
    return _c.guard(
      () => _c.dio.get('/api/core/profiles/$identifier'),
      (data) => ProfileResponse.fromJson(_asMap(data)),
    );
  }

  /// `PUT /api/core/profiles/me` (JSON) — actualiza el perfil propio.
  ///
  /// El backend acepta, entre otros: `name`, `artisticName`, `discipline`,
  /// `location`, `bio`, `avatarUrl`, `bannerUrl`, `isPrivate`,
  /// `showSavedPosts`, `showLikedPosts`. Sólo se envían los campos no nulos.
  Future<ProfileResponse> updateMyProfile({
    String? name,
    String? artisticName,
    String? discipline,
    String? location,
    String? bio,
    String? experienceLevel,
    String? avatarUrl,
    String? bannerUrl,
    bool? isPrivate,
    bool? showSavedPosts,
    bool? showLikedPosts,
  }) {
    final body = <String, dynamic>{};
    void put(String k, dynamic v) {
      if (v != null) body[k] = v;
    }

    put('name', name);
    put('artisticName', artisticName);
    put('discipline', discipline);
    put('location', location);
    put('bio', bio);
    put('experienceLevel', experienceLevel);
    put('avatarUrl', avatarUrl);
    put('bannerUrl', bannerUrl);
    put('isPrivate', isPrivate);
    put('showSavedPosts', showSavedPosts);
    put('showLikedPosts', showLikedPosts);

    return _c.guard(
      () => _c.dio.put('/api/core/profiles/me', data: body),
      (data) => ProfileResponse.fromJson(_asMap(data)),
    );
  }

  /// `PUT /api/core/profiles/me` (multipart/form-data) — actualiza el perfil
  /// incluyendo avatar y/o banner. El backend guarda los archivos en
  /// `/uploads/profiles/**` (campos `avatar` y `banner` de `ProfileRequest`).
  ///
  /// Los nombres de campo son los reales del DTO (sin alias JSON): `name`,
  /// `artisticName`, `discipline`, `location`, `bio`, `experienceLevel`,
  /// `isPrivate`, `showSavedPosts`, `showLikedPosts`, `avatar`, `banner`.
  Future<ProfileResponse> updateMyProfileMultipart({
    String? name,
    String? artisticName,
    String? discipline,
    String? location,
    String? bio,
    String? experienceLevel,
    bool? isPrivate,
    bool? showSavedPosts,
    bool? showLikedPosts,
    String? avatarPath,
    String? bannerPath,
  }) {
    final map = <String, dynamic>{};
    void put(String k, dynamic v) {
      if (v != null) map[k] = v is bool ? v.toString() : v;
    }

    put('name', name);
    put('artisticName', artisticName);
    put('discipline', discipline);
    put('location', location);
    put('bio', bio);
    put('experienceLevel', experienceLevel);
    put('isPrivate', isPrivate);
    put('showSavedPosts', showSavedPosts);
    put('showLikedPosts', showLikedPosts);

    if (avatarPath != null && avatarPath.isNotEmpty) {
      map['avatar'] = MultipartFile.fromFileSync(
        avatarPath,
        filename: avatarPath.split(RegExp(r'[/\\]')).last,
      );
    }
    if (bannerPath != null && bannerPath.isNotEmpty) {
      map['banner'] = MultipartFile.fromFileSync(
        bannerPath,
        filename: bannerPath.split(RegExp(r'[/\\]')).last,
      );
    }

    return _c.guard(
      () => _c.dio.put('/api/core/profiles/me', data: FormData.fromMap(map)),
      (data) => ProfileResponse.fromJson(_asMap(data)),
    );
  }
}

/// Resultado real de `POST /{identifier}/follow` — nunca se incrementa el
/// contador optimísticamente sin que el backend lo confirme.
class FollowToggleResult {
  const FollowToggleResult({
    required this.following,
    required this.followersCount,
  });

  final bool following;
  final int followersCount;
}
