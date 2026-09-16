import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Almacenamiento seguro de la sesión (JWT + datos mínimos del usuario).
///
/// El JWT se guarda en Keychain (iOS/macOS) / Keystore-EncryptedSharedPreferences
/// (Android). Nunca se almacena la contraseña.
///
/// Se persisten también `id`, `username` y `email` porque el endpoint
/// `GET /api/core/profiles/me` NO devuelve esos campos y los necesitamos para
/// reconstruir la sesión tras reiniciar la app.
class TokenStorage {
  TokenStorage._();
  static final TokenStorage instance = TokenStorage._();

  static const _kToken = 'zentry_jwt';
  static const _kUserId = 'zentry_user_id';
  static const _kUsername = 'zentry_username';
  static const _kEmail = 'zentry_email';

  final FlutterSecureStorage _storage = const FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
    iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
  );

  String? _cachedToken;
  bool _loaded = false;

  /// Carga el token en memoria (llamar una vez al arrancar).
  Future<void> warmUp() async {
    _cachedToken = await _read(_kToken);
    _loaded = true;
  }

  /// Token en caché (síncrono). Válido tras [warmUp].
  String? get token => _cachedToken;

  bool get hasToken => (_cachedToken ?? '').isNotEmpty;
  bool get isLoaded => _loaded;

  Future<String?> readToken() async {
    _cachedToken = await _read(_kToken);
    _loaded = true;
    return _cachedToken;
  }

  Future<void> saveSession({
    required String token,
    int? userId,
    String? username,
    String? email,
  }) async {
    _cachedToken = token;
    _loaded = true;
    await _write(_kToken, token);
    if (userId != null) await _write(_kUserId, userId.toString());
    if (username != null) await _write(_kUsername, username);
    if (email != null) await _write(_kEmail, email);
  }

  Future<({int? id, String? username, String? email})> readUser() async {
    final id = int.tryParse(await _read(_kUserId) ?? '');
    return (
      id: id,
      username: await _read(_kUsername),
      email: await _read(_kEmail),
    );
  }

  Future<void> clear() async {
    _cachedToken = null;
    await _delete(_kToken);
    await _delete(_kUserId);
    await _delete(_kUsername);
    await _delete(_kEmail);
  }

  // --- helpers con manejo defensivo (algunos entornos lanzan) ---
  Future<String?> _read(String k) async {
    try {
      return await _storage.read(key: k);
    } catch (_) {
      return null;
    }
  }

  Future<void> _write(String k, String v) async {
    try {
      await _storage.write(key: k, value: v);
    } catch (_) {
      /* no-op */
    }
  }

  Future<void> _delete(String k) async {
    try {
      await _storage.delete(key: k);
    } catch (_) {
      /* no-op */
    }
  }
}
