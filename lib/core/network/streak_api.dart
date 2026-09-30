import 'package:Zentry/core/models/backend/streak_response.dart';
import 'package:Zentry/core/network/api_client.dart';

/// Endpoint de racha (`/api/core/streaks`). Requiere JWT — el backend no
/// tiene ninguna regla `permitAll` para esta ruta.
class StreakApi {
  StreakApi._();
  static final StreakApi instance = StreakApi._();

  ApiClient get _c => ApiClient.instance;

  /// `GET /api/core/streaks/me`.
  Future<StreakResponse> getMyStreak() {
    return _c.guard(
      () => _c.dio.get('/api/core/streaks/me'),
      (data) => StreakResponse.fromJson(Map<String, dynamic>.from(data as Map)),
    );
  }
}
