// Tests de integración ligera contra un HttpClientAdapter FALSO: ejercitan
// el camino real (AuthApi/ProfileApi/StreakApi -> ApiClient.guard -> parsing)
// sin ninguna llamada de red real ni servidor levantado, sustituyendo sólo
// el transporte HTTP de Dio. Cubren exactamente los dos flujos que se
// migraron en esta fase: recuperación de contraseña real y follow contra el
// backend (antes local).

import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:Zentry/core/network/api_client.dart';
import 'package:Zentry/core/network/auth_api.dart';
import 'package:Zentry/core/network/profile_api.dart';
import 'package:Zentry/core/network/streak_api.dart';
import 'package:Zentry/core/providers/auth_controller.dart';
import 'package:Zentry/core/services/auth_repository.dart';

/// Adaptador falso: no abre ningún socket, sólo devuelve la respuesta que le
/// da el test según el path pedido.
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

ResponseBody _json(Map<String, dynamic> body, int statusCode) {
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

  group('Recuperación de contraseña (AuthApi/AuthController)', () {
    test('forgotPassword: 200 real se parsea a AuthResponse', () async {
      ApiClient.instance.dio.httpClientAdapter = _FakeAdapter((options) {
        expect(options.uri.path, endsWith('/api/auth/forgot-password'));
        expect(options.method, 'POST');
        return _json({
          'message': 'Código de recuperación enviado al correo',
          'requiresVerification': true,
        }, 200);
      });

      final resp = await AuthApi.instance.forgotPassword(email: 'a@a.com');
      expect(resp.requiresVerification, isTrue);
    });

    test(
      'AuthController.forgotPassword mapea 404 (correo inexistente) a userNotFound',
      () async {
        ApiClient.instance.dio.httpClientAdapter = _FakeAdapter((options) {
          return _json({
            'message':
                'No existe una cuenta registrada con este correo electrónico',
          }, 404);
        });

        final controller = AuthController();
        final failure = await controller.forgotPassword('nadie@x.com');
        expect(failure, AuthFailure.userNotFound);
        expect(controller.isLoading, isFalse);
      },
    );

    test(
      'AuthController.resetPassword mapea 410 (código expirado) a otpExpired',
      () async {
        ApiClient.instance.dio.httpClientAdapter = _FakeAdapter((options) {
          expect(options.uri.path, endsWith('/api/auth/reset-password'));
          return _json({'message': 'El código expiró'}, 410);
        });

        final controller = AuthController();
        final failure = await controller.resetPassword(
          email: 'a@a.com',
          code: '123456',
          newPassword: 'nueva123',
        );
        expect(failure, AuthFailure.otpExpired);
      },
    );

    test(
      'AuthController.resetPassword mapea 400 con errors.newPassword a weakPassword',
      () async {
        ApiClient.instance.dio.httpClientAdapter = _FakeAdapter((options) {
          return _json({
            'message': 'Validación fallida',
            'errors': {'newPassword': 'tamaño inválido'},
          }, 400);
        });

        final controller = AuthController();
        final failure = await controller.resetPassword(
          email: 'a@a.com',
          code: '123456',
          newPassword: '123',
        );
        expect(failure, AuthFailure.weakPassword);
      },
    );

    test(
      'AuthController.resetPassword mapea 400 SIN errors.newPassword a otpInvalid (código incorrecto)',
      () async {
        ApiClient.instance.dio.httpClientAdapter = _FakeAdapter((options) {
          return _json({'message': 'Código incorrecto'}, 400);
        });

        final controller = AuthController();
        final failure = await controller.resetPassword(
          email: 'a@a.com',
          code: '000000',
          newPassword: 'nueva123',
        );
        expect(failure, AuthFailure.otpInvalid);
      },
    );
  });

  group('Follow contra el backend real (ProfileApi)', () {
    test('toggleFollow parsea following+followersCount reales', () async {
      ApiClient.instance.dio.httpClientAdapter = _FakeAdapter((options) {
        expect(options.uri.path, endsWith('/api/core/profiles/luis/follow'));
        expect(options.method, 'POST');
        return _json({
          'following': true,
          'isFollowing': true,
          'followersCount': 42,
          'message': 'Siguiendo exitosamente',
        }, 200);
      });

      final result = await ProfileApi.instance.toggleFollow('luis');
      expect(result.following, isTrue);
      expect(result.followersCount, 42);
    });

    test('toggleFollow refleja un unfollow (following=false)', () async {
      ApiClient.instance.dio.httpClientAdapter = _FakeAdapter((options) {
        return _json({
          'following': false,
          'followersCount': 41,
          'message': 'Dejaste de seguir',
        }, 200);
      });

      final result = await ProfileApi.instance.toggleFollow('luis');
      expect(result.following, isFalse);
      expect(result.followersCount, 41);
    });
  });

  group('Racha real (StreakApi)', () {
    test('getMyStreak parsea el StreakResponse real del backend', () async {
      ApiClient.instance.dio.httpClientAdapter = _FakeAdapter((options) {
        expect(options.uri.path, endsWith('/api/core/streaks/me'));
        return _json({
          'userId': 1,
          'currentStreak': 5,
          'longestStreak': 9,
          'lastActivityDate': '2026-09-16',
          'activeToday': true,
        }, 200);
      });

      final streak = await StreakApi.instance.getMyStreak();
      expect(streak.currentStreak, 5);
      expect(streak.longestStreak, 9);
      expect(streak.activeToday, isTrue);
    });
  });
}
