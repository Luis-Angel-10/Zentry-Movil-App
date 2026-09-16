/// Espejo de `UserResponse` del backend (core/dtos/UserResponse.java).
///
/// ```json
/// { "id": 12, "token": "eyJ...", "username": "luis", "email": "l@x.com",
///   "message": "Login exitoso", "requiresVerification": false }
/// ```
///
/// En `POST /api/auth/register` sólo llegan `message` y `requiresVerification`
/// (sin `token` ni `id`). El token se obtiene después en `verify-login`.
class AuthResponse {
  const AuthResponse({
    this.id,
    this.token,
    this.username,
    this.email,
    this.message,
    this.requiresVerification = false,
  });

  final int? id;
  final String? token;
  final String? username;
  final String? email;
  final String? message;
  final bool requiresVerification;

  bool get hasToken => (token ?? '').isNotEmpty;

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      id: (json['id'] as num?)?.toInt(),
      token: json['token'] as String?,
      username: json['username'] as String?,
      email: json['email'] as String?,
      message: json['message'] as String?,
      requiresVerification: json['requiresVerification'] == true,
    );
  }
}
