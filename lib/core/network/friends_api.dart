import 'package:Zentry/core/models/backend/friend_user_response.dart';
import 'package:Zentry/core/models/backend/user_stats_response.dart';
import 'package:Zentry/core/network/api_client.dart';

/// Endpoints de amistad y red social (`/api/core/friends`, alias
/// `/api/v1/friends`). Todos requieren JWT.
///
/// Este es el sistema REAL de amistades (username/Principal-based, con
/// notificaciones y reglas de negocio). `FriendRequestController` y
/// `FriendshipController` (`/api/core/friend-requests`,
/// `/api/core/friendships`) también existen en el backend pero son CRUD
/// genérico sin autenticación por Principal — no se usan aquí.
class FriendsApi {
  FriendsApi._();
  static final FriendsApi instance = FriendsApi._();

  ApiClient get _c => ApiClient.instance;

  List<FriendUserResponse> _parseList(dynamic data) => data is List
      ? data
            .whereType<Map>()
            .map(
              (e) => FriendUserResponse.fromJson(Map<String, dynamic>.from(e)),
            )
            .toList()
      : const <FriendUserResponse>[];

  /// `GET /api/core/friends?onlineOnly=`.
  Future<List<FriendUserResponse>> getFriends({bool onlineOnly = false}) {
    return _c.guard(
      () => _c.dio.get(
        '/api/core/friends',
        queryParameters: {'onlineOnly': onlineOnly},
      ),
      _parseList,
    );
  }

  /// `GET /api/core/friends/requests/pending` — solicitudes RECIBIDAS.
  Future<List<FriendUserResponse>> getPendingRequests() {
    return _c.guard(
      () => _c.dio.get('/api/core/friends/requests/pending'),
      _parseList,
    );
  }

  /// `GET /api/core/friends/requests/sent` — solicitudes ENVIADAS.
  Future<List<FriendUserResponse>> getSentRequests() {
    return _c.guard(
      () => _c.dio.get('/api/core/friends/requests/sent'),
      _parseList,
    );
  }

  /// `GET /api/core/friends/suggestions?limit=`.
  Future<List<FriendUserResponse>> getSuggestions({int limit = 12}) {
    return _c.guard(
      () => _c.dio.get(
        '/api/core/friends/suggestions',
        queryParameters: {'limit': limit},
      ),
      _parseList,
    );
  }

  /// `POST /api/core/friends/requests/send` — body `{target_user_id}` o
  /// `{target_username}`. El backend responde 400 si ya son amigos o si ya
  /// existe una solicitud enviada; auto-acepta si el destino ya te había
  /// enviado una solicitud recíproca.
  Future<void> sendRequest({int? targetUserId, String? targetUsername}) {
    final body = <String, dynamic>{};
    if (targetUserId != null) body['target_user_id'] = targetUserId;
    if (targetUsername != null) body['target_username'] = targetUsername;
    return _c.guard(
      () => _c.dio.post('/api/core/friends/requests/send', data: body),
      (_) {},
    );
  }

  /// `POST /api/core/friends/requests/{id}/accept`.
  Future<void> acceptRequest(int requestId) {
    return _c.guard(
      () => _c.dio.post('/api/core/friends/requests/$requestId/accept'),
      (_) {},
    );
  }

  /// `POST /api/core/friends/requests/{id}/reject` — también sirve para que
  /// el remitente cancele su propia solicitud enviada (el backend permite a
  /// cualquiera de los dos usuarios de la solicitud rechazarla).
  Future<void> rejectRequest(int requestId) {
    return _c.guard(
      () => _c.dio.post('/api/core/friends/requests/$requestId/reject'),
      (_) {},
    );
  }

  /// `DELETE /api/core/friends/{friendId}`.
  Future<void> removeFriend(int friendId) {
    return _c.guard(() => _c.dio.delete('/api/core/friends/$friendId'), (_) {});
  }

  /// `POST /api/core/friends/presence/ping?status=`.
  Future<void> pingPresence({String status = 'online'}) {
    return _c.guard(
      () => _c.dio.post(
        '/api/core/friends/presence/ping',
        queryParameters: {'status': status},
      ),
      (_) {},
    );
  }

  /// `GET /api/core/friends/stats`.
  Future<UserStatsResponse> getStats() {
    return _c.guard(
      () => _c.dio.get('/api/core/friends/stats'),
      (data) => UserStatsResponse.fromJson(
        data is Map ? Map<String, dynamic>.from(data) : <String, dynamic>{},
      ),
    );
  }
}
