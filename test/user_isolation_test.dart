// Aislamiento por usuario de EngagementController y StreakController cuando
// varias cuentas comparten el mismo dispositivo (y una misma cuenta usa
// varios dispositivos). SharedPreferences se simula en memoria; el backend
// se simula inyectando `fetchStats` (EngagementController) o un
// HttpClientAdapter falso (StreakController -> StreakApi -> ApiClient).

import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:Zentry/core/models/backend/user_stats_response.dart';
import 'package:Zentry/core/models/challenge.dart';
import 'package:Zentry/core/network/api_client.dart';
import 'package:Zentry/core/providers/engagement_controller.dart';
import 'package:Zentry/core/providers/streak_controller.dart';

const int userA = 101;
const int userB = 202;

/// Backend falso de `/friends/stats`: responde según el usuario "autenticado"
/// en el momento de la petición (como haría el JWT real).
class _FakeStatsBackend {
  _FakeStatsBackend(this.postsCountByUser);

  final Map<int, int> postsCountByUser;
  int? authenticatedUser;

  Future<UserStatsResponse> fetch() async {
    final uid = authenticatedUser!;
    return UserStatsResponse(
      userId: uid,
      postsCount: postsCountByUser[uid] ?? 0,
    );
  }
}

class _FakeAdapter implements HttpClientAdapter {
  _FakeAdapter(this.handler);

  final Future<ResponseBody> Function(RequestOptions options) handler;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) => handler(options);

  @override
  void close({bool force = false}) {}
}

ResponseBody _streakJson(int userId, int current, int longest) {
  final now = DateTime.now().toUtc();
  final today =
      '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  return ResponseBody.fromString(
    jsonEncode({
      'userId': userId,
      'currentStreak': current,
      'longestStreak': longest,
      'lastActivityDate': today,
      'activeToday': true,
    }),
    200,
    headers: {
      'content-type': ['application/json; charset=utf-8'],
    },
  );
}

/// Simula login: el backend pasa a autenticar a [uid] y el controller se
/// vincula a ese usuario (lo que hace main.dart en onSessionEstablished).
Future<void> _login(
  EngagementController c,
  _FakeStatsBackend backend,
  int uid,
) async {
  backend.authenticatedUser = uid;
  await c.bindUser(uid);
}

Future<void> _logout(EngagementController c, _FakeStatsBackend backend) async {
  backend.authenticatedUser = null;
  await c.bindUser(null);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    // La URL real no importa (el adaptador HTTP es falso).
    ApiClient.instance.init();
  });

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('EngagementController por usuario', () {
    test('1. A y B en el mismo dispositivo mantienen estados independientes',
        () async {
      final backend = _FakeStatsBackend({userA: 0, userB: 0});
      final c = EngagementController(fetchStats: backend.fetch);

      await _login(c, backend, userA);
      await c.registerLike();
      await c.registerLike();
      await c.registerComment();
      await c.registerShare();

      await _logout(c, backend);
      await _login(c, backend, userB);
      await c.registerLike();
      await c.registerSave();

      expect(c.likesGiven, 1);
      expect(c.savesGiven, 1);
      expect(c.commentsGiven, 0);
      expect(c.sharesGiven, 0);

      // Lo persistido está separado por namespace de usuario.
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getInt(EngagementController.keyFor(userA, 'likes_given')), 2);
      expect(prefs.getInt(EngagementController.keyFor(userB, 'likes_given')), 1);
      expect(
        prefs.getInt(EngagementController.keyFor(userA, 'comments_given')),
        1,
      );
      expect(
        prefs.getInt(EngagementController.keyFor(userB, 'comments_given')),
        isNull,
      );
      // Ninguna clave global (sin namespace) de engagement.
      expect(
        prefs.getKeys().where(
          (k) => k.startsWith('engagement') && !k.startsWith('engagement.u'),
        ),
        isEmpty,
      );
    });

    test('2. Logout A -> login B no muestra datos de A', () async {
      final backend = _FakeStatsBackend({userA: 0, userB: 0});
      final c = EngagementController(fetchStats: backend.fetch);

      await _login(c, backend, userA);
      await c.registerLike(); // desbloquea like_1 (+10 monedas)
      expect(c.unlockedAchievements, contains('like_1'));
      expect(c.zCoins, greaterThan(0));

      await _logout(c, backend);
      // Tras logout la memoria queda limpia y nada se registra sin sesión.
      expect(c.userId, isNull);
      expect(c.likesGiven, 0);
      expect(c.zCoins, 0);
      expect(c.unlockedAchievements, isEmpty);
      await c.registerLike();
      expect(c.likesGiven, 0);

      await _login(c, backend, userB);
      expect(c.userId, userB);
      expect(c.likesGiven, 0);
      expect(c.zCoins, 0);
      expect(c.unlockedAchievements, isEmpty);
      expect(c.ownedColors, isEmpty);
      expect(c.weeklyProgressFor(ChallengeMetric.likes), 0);
      expect(c.weeklyLikes, List.filled(7, 0));
    });

    test('3. Logout B -> login A recupera los datos de A', () async {
      final backend = _FakeStatsBackend({userA: 0, userB: 0});
      final c = EngagementController(fetchStats: backend.fetch);

      await _login(c, backend, userA);
      for (var i = 0; i < 5; i++) {
        await c.registerLike(); // like_1 + like_5 -> 35 monedas
      }
      expect(await c.buyColor('neon', 20), isTrue);
      final coinsA = c.zCoins;
      final unlockedA = Set.of(c.unlockedAchievements);

      await _logout(c, backend);
      await _login(c, backend, userB);
      await c.registerComment();
      await _logout(c, backend);

      await _login(c, backend, userA);
      expect(c.likesGiven, 5);
      expect(c.commentsGiven, 0);
      expect(c.zCoins, coinsA);
      expect(c.unlockedAchievements, unlockedA);
      expect(c.ownedColors, {'neon'});
      expect(c.weeklyProgressFor(ChallengeMetric.likes), 5);
    });

    test(
      '4. Una respuesta tardía iniciada con A no modifica el estado visible de B',
      () async {
        final lateA = Completer<UserStatsResponse>();
        var calls = 0;
        final c = EngagementController(
          fetchStats: () {
            calls++;
            // 1ª petición (sesión de A) queda en vuelo; 2ª es la de B.
            if (calls == 1) return lateA.future;
            return Future.value(
              const UserStatsResponse(userId: userB, postsCount: 4),
            );
          },
        );

        final bindA = c.bindUser(userA);
        await pumpEventQueue();
        expect(calls, 1); // la petición de A está en vuelo

        // Logout A -> login B mientras tanto.
        await c.bindUser(null);
        await c.bindUser(userB);
        expect(c.postsPublished, 4);

        // Llega la respuesta tardía de A.
        lateA.complete(const UserStatsResponse(userId: userA, postsCount: 99));
        await bindA;

        expect(c.userId, userB);
        expect(c.postsPublished, 4);
        final prefs = await SharedPreferences.getInstance();
        expect(
          prefs.getInt(EngagementController.keyFor(userB, 'posts_published')),
          4,
        );
        expect(
          prefs.getInt(EngagementController.keyFor(userA, 'posts_published')),
          isNull,
        );

        // Una acción iniciada por A (capturó su id antes del await) que
        // termina ya con B dentro tampoco se le cuenta a B.
        await c.registerComment(forUserId: userA);
        expect(c.commentsGiven, 0);
        await c.registerComment(forUserId: userB);
        expect(c.commentsGiven, 1);

        // Racha de otra cuenta tampoco se aplica.
        c.syncBackendStreak(userId: userA, currentStreak: 30, longestStreak: 30);
        expect(c.unlockedAchievements, isNot(contains('streak_30')));
        expect(c.weeklyProgressFor(ChallengeMetric.streak), 0);
      },
    );

    test(
      '5. Dos dispositivos con la misma cuenta muestran los datos del backend',
      () async {
        // Dispositivo 1: caché local vieja de A (2 publicaciones).
        SharedPreferences.setMockInitialValues({
          EngagementController.keyFor(userA, 'posts_published'): 2,
        });
        final backend = _FakeStatsBackend({userA: 7});
        final device1 = EngagementController(fetchStats: backend.fetch);
        await _login(device1, backend, userA);
        expect(device1.postsPublished, 7);
        expect(
          device1.unlockedAchievements,
          containsAll(['posts_1']),
        );

        // Dispositivo 2: sin nada local.
        SharedPreferences.setMockInitialValues({});
        final device2 = EngagementController(fetchStats: backend.fetch);
        await _login(device2, backend, userA);
        expect(device2.postsPublished, 7);
        expect(device2.unlockedAchievements, containsAll(['posts_1']));

        // La racha (logros streak_*) también viene del backend en ambos.
        for (final d in [device1, device2]) {
          d.syncBackendStreak(userId: userA, currentStreak: 3, longestStreak: 8);
          expect(d.unlockedAchievements, containsAll(['streak_3', 'streak_7']));
          expect(d.unlockedAchievements, isNot(contains('streak_30')));
          expect(d.weeklyProgressFor(ChallengeMetric.streak), 3);
        }
      },
    );
  });

  group('StreakController por usuario', () {
    test(
      '4. Respuesta tardía de /streaks/me de A no se muestra a B',
      () async {
        final lateA = Completer<ResponseBody>();
        var calls = 0;
        ApiClient.instance.dio.httpClientAdapter = _FakeAdapter((options) {
          calls++;
          if (calls == 1) return lateA.future;
          return Future.value(_streakJson(userB, 1, 1));
        });

        final streak = StreakController();
        final loadA = streak.load();
        await pumpEventQueue();

        streak.reset(); // logout A
        await streak.load(); // login B
        expect(streak.data?.userId, userB);

        lateA.complete(_streakJson(userA, 40, 40));
        await loadA;

        expect(streak.data?.userId, userB);
        expect(streak.currentStreak, 1);
        expect(streak.isLoading, isFalse);
      },
    );

    test(
      '5. Dos dispositivos con la misma cuenta muestran la racha del backend',
      () async {
        ApiClient.instance.dio.httpClientAdapter = _FakeAdapter(
          (options) async => _streakJson(userA, 6, 9),
        );
        final device1 = StreakController();
        final device2 = StreakController();
        await device1.load();
        await device2.load();
        for (final d in [device1, device2]) {
          expect(d.data?.userId, userA);
          expect(d.currentStreak, 6);
          expect(d.longestStreak, 9);
        }
      },
    );
  });
}
