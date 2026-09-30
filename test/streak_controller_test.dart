// StreakController es la migración de la racha de local (SharedPreferences)
// a backend real. Estos tests verifican la lógica derivada puramente en
// Dart (weeklyActivity, todayReward) sin tocar red: se le asigna `data`
// directamente, como si `StreakApi.getMyStreak()` ya hubiera respondido.

import 'package:flutter_test/flutter_test.dart';
import 'package:Zentry/core/models/backend/streak_response.dart';
import 'package:Zentry/core/providers/streak_controller.dart';

void main() {
  group('StreakController', () {
    test(
      'sin datos cargados, todo son valores neutros (no se inventa nada)',
      () {
        final controller = StreakController();
        expect(controller.currentStreak, 0);
        expect(controller.longestStreak, 0);
        expect(controller.activeToday, isFalse);
        expect(controller.todayReward, 0);
        expect(controller.weeklyActivity, List.filled(7, 0));
      },
    );

    test(
      'todayReward usa la misma fórmula que el antiguo EngagementController local',
      () {
        final controller = StreakController();
        controller.data = const StreakResponse(
          userId: 1,
          currentStreak: 3,
          longestStreak: 3,
          activeToday: true,
        );
        // 10 + (3-1)*5 = 20
        expect(controller.todayReward, 20);
      },
    );

    test('todayReward nunca pasa de 50 (clamp) con rachas muy largas', () {
      final controller = StreakController();
      controller.data = const StreakResponse(
        userId: 1,
        currentStreak: 100,
        longestStreak: 100,
        activeToday: true,
      );
      expect(controller.todayReward, 50);
    });

    test(
      'weeklyActivity (lunes..domingo) marca hoy y los días previos de la racha, nunca inventa historial',
      () {
        final controller = StreakController();
        // lastActivityDate es un día UTC (así lo guarda el backend).
        final nowUtc = DateTime.now().toUtc();
        controller.data = StreakResponse(
          userId: 1,
          currentStreak: 3,
          longestStreak: 5,
          activeToday: true,
          lastActivityDate: DateTime.utc(nowUtc.year, nowUtc.month, nowUtc.day),
        );

        final activity = controller.weeklyActivity;
        expect(activity.length, 7);
        final todayIndex = DateTime.now().weekday - 1; // 0 = lunes
        final expected = List.generate(
          7,
          (i) => (i <= todayIndex && i > todayIndex - 3) ? 1 : 0,
        );
        expect(activity, expected);
      },
    );

    test('weeklyActivity queda todo en 0 si currentStreak es 0', () {
      final controller = StreakController();
      controller.data = StreakResponse(
        userId: 1,
        currentStreak: 0,
        longestStreak: 5,
        activeToday: false,
        lastActivityDate: DateTime.now().subtract(const Duration(days: 10)),
      );
      expect(controller.weeklyActivity, List.filled(7, 0));
    });
  });
}
