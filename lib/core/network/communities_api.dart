import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:http_parser/http_parser.dart' show MediaType;

import 'package:Zentry/core/models/backend/community_response.dart';
import 'package:Zentry/core/network/api_client.dart';
import 'package:Zentry/core/network/posts_api.dart' show PagedResult;

/// Endpoints de comunidades (`/api/core/communities`, alias
/// `/api/v1/communities`).
///
/// Listar/detalle/posts/foro-anidado son PÚBLICOS; crear/unirse/salir/
/// postear/eliminar/notificaciones requieren JWT (ver SecurityConfig real).
class CommunitiesApi {
  CommunitiesApi._();
  static final CommunitiesApi instance = CommunitiesApi._();

  ApiClient get _c => ApiClient.instance;

  /// `GET /api/core/communities?search=&page=&size=`.
  Future<PagedResult<CommunityResponse>> getCommunities({
    String? search,
    int page = 0,
    int size = 20,
  }) {
    return _c.guard(
      () => _c.dio.get(
        '/api/core/communities',
        queryParameters: {
          if (search != null && search.trim().isNotEmpty)
            'search': search.trim(),
          'page': page,
          'size': size,
        },
      ),
      (data) => _parsePaged(data),
    );
  }

  /// `GET /api/core/communities/{identifier}` — id numérico o slug.
  Future<CommunityResponse> getCommunity(String identifier) {
    return _c.guard(
      () => _c.dio.get('/api/core/communities/$identifier'),
      (data) =>
          CommunityResponse.fromJson(Map<String, dynamic>.from(data as Map)),
    );
  }

  /// `POST /api/core/communities` — JSON. Campos reales de `CommunityRequest`
  /// (nombre/descripcion/categoria/rules) — sin privacidad/hashtags/
  /// subcategoría, que no existen en el backend.
  Future<CommunityResponse> createCommunity({
    required String nombre,
    String? descripcion,
    String? categoria,
    List<String> rules = const [],
  }) {
    return _c.guard(
      () => _c.dio.post(
        '/api/core/communities',
        data: {
          'nombre': nombre,
          if (descripcion != null) 'descripcion': descripcion,
          if (categoria != null) 'categoria': categoria,
          'rules': rules,
        },
      ),
      (data) =>
          CommunityResponse.fromJson(Map<String, dynamic>.from(data as Map)),
    );
  }

  /// `PUT /api/core/communities/{identifier}` — multipart si hay
  /// avatar/banner nuevos, JSON si no.
  Future<CommunityResponse> updateCommunity(
    String identifier, {
    String? nombre,
    String? descripcion,
    String? categoria,
    List<String>? rules,
    String? avatarPath,
    String? bannerPath,
  }) {
    final hasFiles =
        (avatarPath != null && avatarPath.isNotEmpty) ||
        (bannerPath != null && bannerPath.isNotEmpty);

    final fields = <String, dynamic>{
      if (nombre != null) 'nombre': nombre,
      if (descripcion != null) 'descripcion': descripcion,
      if (categoria != null) 'categoria': categoria,
      if (rules != null) 'rules': rules,
    };

    if (!hasFiles) {
      return _c.guard(
        () => _c.dio.put('/api/core/communities/$identifier', data: fields),
        (data) =>
            CommunityResponse.fromJson(Map<String, dynamic>.from(data as Map)),
      );
    }

    final form = FormData.fromMap({
      if (fields.isNotEmpty)
        'data': MultipartFile.fromString(
          jsonEncode(fields),
          contentType: MediaType('application', 'json'),
        ),
      if (avatarPath != null && avatarPath.isNotEmpty)
        'avatar': MultipartFile.fromFileSync(
          avatarPath,
          filename: avatarPath.split(RegExp(r'[/\\]')).last,
        ),
      if (bannerPath != null && bannerPath.isNotEmpty)
        'banner': MultipartFile.fromFileSync(
          bannerPath,
          filename: bannerPath.split(RegExp(r'[/\\]')).last,
        ),
    });
    return _c.guard(
      () => _c.dio.put('/api/core/communities/$identifier', data: form),
      (data) =>
          CommunityResponse.fromJson(Map<String, dynamic>.from(data as Map)),
    );
  }

  /// `POST /api/core/communities/{identifier}/join`.
  Future<CommunityResponse> joinCommunity(String identifier) {
    return _c.guard(
      () => _c.dio.post('/api/core/communities/$identifier/join'),
      (data) =>
          CommunityResponse.fromJson(Map<String, dynamic>.from(data as Map)),
    );
  }

  /// `POST /api/core/communities/{identifier}/leave`.
  Future<CommunityResponse> leaveCommunity(String identifier) {
    return _c.guard(
      () => _c.dio.post('/api/core/communities/$identifier/leave'),
      (data) =>
          CommunityResponse.fromJson(Map<String, dynamic>.from(data as Map)),
    );
  }

  /// `DELETE /api/core/communities/{id}` — el backend NO valida ownership en
  /// este endpoint (ver reporte de seguridad); úsalo sólo si tú mismo
  /// controlas en Flutter que quien borra es el creador.
  Future<void> deleteCommunity(int id) {
    return _c.guard(() => _c.dio.delete('/api/core/communities/$id'), (_) {});
  }

  /// `POST /api/core/communities/{identifier}/notifications/toggle`.
  Future<void> toggleNotifications(String identifier) {
    return _c.guard(
      () =>
          _c.dio.post('/api/core/communities/$identifier/notifications/toggle'),
      (_) {},
    );
  }

  // ─── Foro (API lista, sin UI todavía — ver reporte) ────────────────────

  /// `GET /api/core/communities/{identifier}/forum-threads?page=&size=` —
  /// público (ruta anidada).
  Future<PagedResult<ForumThreadResponse>> getForumThreads(
    String identifier, {
    int page = 0,
    int size = 20,
  }) {
    return _c.guard(
      () => _c.dio.get(
        '/api/core/communities/$identifier/forum-threads',
        queryParameters: {'page': page, 'size': size},
      ),
      (data) => _parsePagedThreads(data),
    );
  }

  /// `POST /api/core/communities/{identifier}/forum-threads` — JWT
  /// requerido. Body `{title, content}` (`communityId` lo fija el backend).
  Future<ForumThreadResponse> createForumThread(
    String identifier, {
    required String title,
    required String content,
  }) {
    return _c.guard(
      () => _c.dio.post(
        '/api/core/communities/$identifier/forum-threads',
        data: {'title': title, 'content': content},
      ),
      (data) =>
          ForumThreadResponse.fromJson(Map<String, dynamic>.from(data as Map)),
    );
  }

  // --- helpers de parseo ---

  static List<CommunityResponse> _parseList(dynamic data) {
    if (data is List) {
      return data
          .whereType<Map>()
          .map((e) => CommunityResponse.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    }
    if (data is Map && data['content'] is List) {
      return (data['content'] as List)
          .whereType<Map>()
          .map((e) => CommunityResponse.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    }
    return const [];
  }

  static PagedResult<CommunityResponse> _parsePaged(dynamic data) {
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

  static PagedResult<ForumThreadResponse> _parsePagedThreads(dynamic data) {
    List<ForumThreadResponse> parseList(dynamic raw) {
      if (raw is List) {
        return raw
            .whereType<Map>()
            .map(
              (e) => ForumThreadResponse.fromJson(Map<String, dynamic>.from(e)),
            )
            .toList();
      }
      return const [];
    }

    if (data is List) {
      final items = parseList(data);
      return PagedResult(items: items, totalElements: items.length);
    }
    if (data is Map) {
      final items = parseList(data['content']);
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
