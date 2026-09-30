// Tests de la fase de integración social (rachas, comunidades en perfil,
// consistencia de likes/guardados entre pantallas).

import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:Zentry/core/models/backend/community_response.dart';
import 'package:Zentry/core/models/backend/post_response.dart';
import 'package:Zentry/core/models/backend/streak_response.dart';
import 'package:Zentry/core/network/api_client.dart';
import 'package:Zentry/core/providers/auth_controller.dart';
import 'package:Zentry/core/providers/community_controller.dart';
import 'package:Zentry/core/providers/posts_controller.dart';
import 'package:Zentry/core/providers/streak_controller.dart';

class _FakeAdapter implements HttpClientAdapter {
  _FakeAdapter(this.handler);
  final ResponseBody Function(RequestOptions options) handler;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    return handler(options);
  }

  @override
  void close({bool force = false}) {}
}

ResponseBody _json(dynamic body, int statusCode) {
  return ResponseBody.fromString(
    jsonEncode(body),
    statusCode,
    headers: {
      'content-type': ['application/json; charset=utf-8'],
    },
  );
}

void main() {
  setUpAll(() {
    ApiClient.instance.init();
  });

  group('StreakController.status — 4 estados reales (corrección racha)', () {
    StreakController controllerWith(StreakResponse data) {
      final c = StreakController();
      c.data = data;
      return c;
    }

    test('nunca iniciada: lastActivityDate null', () {
      final c = controllerWith(
        const StreakResponse(
          userId: 1,
          currentStreak: 0,
          longestStreak: 0,
          activeToday: false,
        ),
      );
      expect(c.status, StreakStatus.neverStarted);
    });

    test('activa hoy', () {
      final c = controllerWith(
        StreakResponse(
          userId: 1,
          currentStreak: 3,
          longestStreak: 5,
          activeToday: true,
          lastActivityDate: DateTime.now().toUtc(),
        ),
      );
      expect(c.status, StreakStatus.activeToday);
    });

    test('vigente pero pendiente hoy: actividad ayer, todavía no hoy', () {
      final yesterday = DateTime.now().toUtc().subtract(
        const Duration(days: 1),
      );
      final c = controllerWith(
        StreakResponse(
          userId: 1,
          currentStreak: 4,
          longestStreak: 5,
          activeToday: false,
          lastActivityDate: yesterday,
        ),
      );
      expect(c.status, StreakStatus.pendingToday);
    });

    test('perdida: el backend ya resetea currentStreak a 0', () {
      final longAgo = DateTime.now().toUtc().subtract(const Duration(days: 5));
      final c = controllerWith(
        StreakResponse(
          userId: 1,
          currentStreak: 0,
          longestStreak: 5,
          activeToday: false,
          lastActivityDate: longAgo,
        ),
      );
      expect(c.status, StreakStatus.lost);
    });

    test(
      'no confunde "nunca iniciada" con "perdida" (distinta lastActivityDate)',
      () {
        final neverStarted = controllerWith(
          const StreakResponse(
            userId: 1,
            currentStreak: 0,
            longestStreak: 0,
            activeToday: false,
          ),
        );
        final lost = controllerWith(
          StreakResponse(
            userId: 1,
            currentStreak: 0,
            longestStreak: 3,
            activeToday: false,
            lastActivityDate: DateTime.now().toUtc().subtract(
              const Duration(days: 10),
            ),
          ),
        );
        expect(neverStarted.status, isNot(equals(lost.status)));
      },
    );
  });

  group(
    'CommunityController.backendMyCommunities — corrección "Aún no perteneces"',
    () {
      test('filtra sólo isJoined==true de la lista general', () {
        final controller = CommunityController();
        controller.backendCommunities.addAll([
          CommunityResponse.fromJson({
            'id': 1,
            'slug': 'a',
            'nombre': 'Comunidad A',
            'isJoined': true,
          }),
          CommunityResponse.fromJson({
            'id': 2,
            'slug': 'b',
            'nombre': 'Comunidad B',
            'isJoined': false,
          }),
          CommunityResponse.fromJson({
            'id': 3,
            'slug': 'c',
            'nombre': 'Comunidad C',
            'isJoined': true,
          }),
        ]);

        final mine = controller.backendMyCommunities;
        expect(mine.map((c) => c.nombre), ['Comunidad A', 'Comunidad C']);
      });

      test('lista vacía cuando no hay ninguna unida', () {
        final controller = CommunityController();
        controller.backendCommunities.add(
          CommunityResponse.fromJson({
            'id': 1,
            'slug': 'a',
            'nombre': 'Comunidad A',
            'isJoined': false,
          }),
        );
        expect(controller.backendMyCommunities, isEmpty);
      });
    },
  );

  group(
    'PostsController — consistencia de like/guardado entre pantallas (Sección 12)',
    () {
      test(
        'dar like desde un post encontrado sólo en likedBackendPosts actualiza esa lista',
        () async {
          final controller = PostsController();
          // Simula un post que sólo está cargado en "Mis likes" (p. ej. ya
          // salió del feed principal), no en backendPosts/communityPosts.
          controller.likedBackendPosts.add(
            _fakePost(id: 42, liked: true, likesCount: 5),
          );

          ApiClient.instance.dio.httpClientAdapter = _FakeAdapter((options) {
            expect(options.path, contains('/posts/42/like'));
            return _json({
              'id': 42,
              'likesCount': 4,
              'liked': false,
              'commentsCount': 0,
              'saved': false,
            }, 200);
          });

          await controller.toggleLikeBackend(42);

          // Ya no está "liked" -> debe desaparecer de la lista de likes.
          expect(
            controller.likedBackendPosts.where((p) => p.id == 42),
            isEmpty,
          );
        },
      );

      test(
        'guardar un post visto en el feed lo agrega también a savedBackendPosts',
        () async {
          final controller = PostsController();
          controller.savedPostsLoaded = true; // ya se cargó Guardados antes
          controller.backendPosts.add(
            _fakePost(id: 7, liked: false, likesCount: 1, saved: false),
          );

          ApiClient.instance.dio.httpClientAdapter = _FakeAdapter((options) {
            expect(options.path, contains('/posts/7/bookmark'));
            return _json({'saved': true}, 200);
          });

          await controller.toggleBookmarkBackend(7);

          expect(controller.savedBackendPosts.any((p) => p.id == 7), isTrue);
          expect(
            controller.backendPosts.firstWhere((p) => p.id == 7).saved,
            isTrue,
          );
        },
      );
    },
  );

  group(
    'Corrección "racha bugeada" — no debe sobrevivir a un cambio de cuenta',
    () {
      test(
        'StreakController.reset() limpia currentStreak/longestStreak/activeToday del usuario anterior',
        () {
          final controller = StreakController();
          controller.data = const StreakResponse(
            userId: 1,
            currentStreak: 12,
            longestStreak: 20,
            activeToday: true,
          );
          expect(controller.currentStreak, 12);

          controller.reset();

          expect(controller.data, isNull);
          expect(controller.currentStreak, 0);
          expect(controller.longestStreak, 0);
          expect(controller.activeToday, isFalse);
          expect(controller.status, StreakStatus.neverStarted);
        },
      );

      test(
        'TEST 11: AuthController.logout() dispara onSessionCleared (hook que main.dart usa para limpiar StreakController)',
        () async {
          TestWidgetsFlutterBinding.ensureInitialized();
          SharedPreferences.setMockInitialValues({});

          final auth = AuthController();
          var clearedCalled = false;
          auth.onSessionCleared = () => clearedCalled = true;

          await auth.logout();

          expect(
            clearedCalled,
            isTrue,
            reason:
                'sin este hook, la racha (y otro estado "del usuario '
                'actual") del usuario que cierra sesión sigue en memoria '
                'cuando otra cuenta inicia sesión en la misma ejecución',
          );
        },
      );
    },
  );
}

Map<String, dynamic> _fakePostJson({
  required int id,
  required bool liked,
  required int likesCount,
  bool saved = false,
}) {
  return {
    'id': id,
    'likesCount': likesCount,
    'liked': liked,
    'saved': saved,
    'commentsCount': 0,
  };
}

// Construye un PostResponse real vía fromJson para no depender de su
// constructor interno (mantiene el test acoplado sólo al contrato JSON).
PostResponse _fakePost({
  required int id,
  required bool liked,
  required int likesCount,
  bool saved = false,
}) {
  return PostResponse.fromJson(
    _fakePostJson(id: id, liked: liked, likesCount: likesCount, saved: saved),
  );
}
