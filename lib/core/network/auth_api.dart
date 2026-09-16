import 'package:dio/dio.dart';

import 'package:Zentry/core/models/backend/auth_response.dart';
import 'package:Zentry/core/network/api_client.dart';

/// Endpoints de autenticación. Todos son PÚBLICOS en el backend
/// (`/api/auth/**` está en `permitAll()` de SecurityConfig), por eso se marcan
/// con `extra: {'noAuth': true}`: no añaden el header Authorization ni disparan
/// el flujo de "sesión inválida" ante un 401 legítimo de credenciales.
class AuthApi {
  AuthApi._();
  static final AuthApi instance = AuthApi._();

  ApiClient get _c => ApiClient.instance;

  static Options get _public => Options(extra: const {'noAuth': true});

  Map<String, dynamic> _asMap(dynamic data) =>
      data is Map ? Map<String, dynamic>.from(data) : <String, dynamic>{};

  /// `POST /api/auth/login` — body `{email, password}`.
  /// 200 -> UserResponse con token. 401 -> credenciales incorrectas.
  Future<AuthResponse> login({
    required String email,
    required String password,
  }) {
    return _c.guard(
      () => _c.dio.post(
        '/api/auth/login',
        data: {'email': email.trim(), 'password': password},
        options: _public,
      ),
      (data) => AuthResponse.fromJson(_asMap(data)),
    );
  }

  /// `POST /api/auth/register` — body `{username, email, password}`.
  /// 200 -> `{message, requiresVerification: true}` (SIN token).
  /// 409 -> el correo ya está registrado.
  Future<AuthResponse> register({
    required String username,
    required String email,
    required String password,
  }) {
    return _c.guard(
      () => _c.dio.post(
        '/api/auth/register',
        data: {
          'username': username.trim(),
          'email': email.trim(),
          'password': password,
        },
        options: _public,
      ),
      (data) => AuthResponse.fromJson(_asMap(data)),
    );
  }

  /// `POST /api/auth/verify-login` — body `{email, code}`.
  /// 200 -> UserResponse con token. 400 -> código incorrecto.
  /// 410 -> código expirado. 429 -> demasiados intentos.
  Future<AuthResponse> verifyOtp({
    required String email,
    required String code,
  }) {
    return _c.guard(
      () => _c.dio.post(
        '/api/auth/verify-login',
        data: {'email': email.trim(), 'code': code.trim()},
        options: _public,
      ),
      (data) => AuthResponse.fromJson(_asMap(data)),
    );
  }

  /// `POST /api/auth/resend-otp` — body `{email}`.
  Future<AuthResponse> resendOtp({required String email}) {
    return _c.guard(
      () => _c.dio.post(
        '/api/auth/resend-otp',
        data: {'email': email.trim()},
        options: _public,
      ),
      (data) => AuthResponse.fromJson(_asMap(data)),
    );
  }

  /// `PUT /api/auth/change-password` — body `{currentPassword, newPassword}`.
  /// Requiere JWT (NO lleva `noAuth`).
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) {
    return _c.guard(
      () => _c.dio.put(
        '/api/auth/change-password',
        data: {'currentPassword': currentPassword, 'newPassword': newPassword},
      ),
      (_) {},
    );
  }
}
