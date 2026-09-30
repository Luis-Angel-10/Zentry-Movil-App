/// Espejo de `StreakResponse` del backend (`core/dtos/StreakResponse.java`).
///
/// ```json
/// { "userId": 12, "currentStreak": 5, "longestStreak": 9,
///   "lastActivityDate": "2026-09-17", "activeToday": true }
/// ```
///
/// El backend calcula la racha automáticamente (cualquier acción de misión
/// la avanza server-side) — no existe endpoint para marcarla manualmente.
class StreakResponse {
  const StreakResponse({
    required this.userId,
    required this.currentStreak,
    required this.longestStreak,
    required this.activeToday,
    this.lastActivityDate,
  });

  final int userId;
  final int currentStreak;
  final int longestStreak;
  final DateTime? lastActivityDate;
  final bool activeToday;

  factory StreakResponse.fromJson(Map<String, dynamic> json) {
    return StreakResponse(
      userId: (json['userId'] as num?)?.toInt() ?? 0,
      currentStreak: (json['currentStreak'] as num?)?.toInt() ?? 0,
      longestStreak: (json['longestStreak'] as num?)?.toInt() ?? 0,
      activeToday: json['activeToday'] == true,
      lastActivityDate: json['lastActivityDate'] is String
          ? DateTime.tryParse(json['lastActivityDate'] as String)
          : null,
    );
  }
}
