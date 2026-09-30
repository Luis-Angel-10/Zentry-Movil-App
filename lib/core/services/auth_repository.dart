import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:sqflite/sqflite.dart';

import 'package:Zentry/core/models/app_user.dart';
import 'package:Zentry/core/services/database_service.dart';

enum AuthFailure {
  emailTaken,
  usernameTaken,
  invalidCredentials,
  biometricFailed,
  biometricUnavailable,
  // --- añadidos para la integración con el backend Zentry ---
  /// El registro fue aceptado pero requiere verificación por código (OTP).
  needsVerification,

  /// Código OTP incorrecto.
  otpInvalid,

  /// Código OTP expirado (HTTP 410).
  otpExpired,

  /// Demasiados intentos de OTP (HTTP 429).
  otpTooManyAttempts,

  /// El backend no encontró el usuario (HTTP 404).
  userNotFound,

  /// La nueva contraseña no cumple los requisitos del backend (min. 6
  /// caracteres) al restablecerla (HTTP 400 con `errors.newPassword`).
  weakPassword,

  /// Sin conexión / timeout con el servidor.
  network,

  /// Error 5xx del servidor.
  serverError,

  /// Cualquier otro fallo no clasificado.
  unknown,
}

class AuthException implements Exception {
  AuthException(this.failure, [this.message]);
  final AuthFailure failure;

  /// Mensaje del backend cuando está disponible (para mostrar tal cual).
  final String? message;
}

class AuthRepository {
  Future<Database> get _db => DatabaseService.instance.database;

  String _generateSalt() {
    final random = Random.secure();
    final bytes = List<int>.generate(16, (_) => random.nextInt(256));
    return base64Url.encode(bytes);
  }

  String _hash(String password, String salt) {
    return sha256.convert(utf8.encode('$salt:$password')).toString();
  }

  Future<AppUser> register({
    required String fullName,
    String? artistName,
    required String username,
    required String email,
    required String password,
    String? discipline,
    String? bio,
    List<String> interests = const [],
  }) async {
    final db = await _db;
    final normalizedEmail = email.trim().toLowerCase();
    final normalizedUsername = username.trim();

    final existingEmail = await db.query(
      'users',
      where: 'email = ?',
      whereArgs: [normalizedEmail],
      limit: 1,
    );
    if (existingEmail.isNotEmpty) throw AuthException(AuthFailure.emailTaken);

    final existingUsername = await db.query(
      'users',
      where: 'username = ?',
      whereArgs: [normalizedUsername],
      limit: 1,
    );
    if (existingUsername.isNotEmpty) {
      throw AuthException(AuthFailure.usernameTaken);
    }

    final salt = _generateSalt();
    final id = await db.insert('users', {
      'fullName': fullName.trim(),
      'artistName': (artistName ?? '').trim().isEmpty
          ? null
          : artistName!.trim(),
      'username': normalizedUsername,
      'email': normalizedEmail,
      'passwordHash': _hash(password, salt),
      'salt': salt,
      'discipline': (discipline ?? '').trim().isEmpty ? null : discipline,
      'bio': (bio ?? '').trim().isEmpty ? null : bio!.trim(),
      'interests': interests.isEmpty ? null : interests.join(','),
      'createdAt': DateTime.now().toIso8601String(),
    });

    return AppUser(
      id: id,
      fullName: fullName.trim(),
      artistName: (artistName ?? '').trim().isEmpty ? null : artistName!.trim(),
      username: normalizedUsername,
      email: normalizedEmail,
      discipline: (discipline ?? '').trim().isEmpty ? null : discipline,
      bio: (bio ?? '').trim().isEmpty ? null : bio!.trim(),
      interests: interests,
    );
  }

  Future<AppUser> login({
    required String email,
    required String password,
  }) async {
    final db = await _db;
    final rows = await db.query(
      'users',
      where: 'email = ?',
      whereArgs: [email.trim().toLowerCase()],
      limit: 1,
    );
    if (rows.isEmpty) throw AuthException(AuthFailure.invalidCredentials);

    final row = rows.first;
    final expectedHash = _hash(password, row['salt'] as String);
    if (expectedHash != row['passwordHash']) {
      throw AuthException(AuthFailure.invalidCredentials);
    }

    return AppUser.fromMap(row);
  }

  Future<AppUser?> findById(int id) async {
    final db = await _db;
    final rows = await db.query(
      'users',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return AppUser.fromMap(rows.first);
  }

  Future<List<AppUser>> findByIds(List<int> ids) async {
    if (ids.isEmpty) return const [];
    final db = await _db;
    final placeholders = List.filled(ids.length, '?').join(',');
    final rows = await db.query(
      'users',
      where: 'id IN ($placeholders)',
      whereArgs: ids,
    );
    return rows.map(AppUser.fromMap).toList();
  }

  Future<List<AppUser>> allUsers({int? excludeId}) async {
    final db = await _db;
    final rows = excludeId != null
        ? await db.query('users', where: 'id != ?', whereArgs: [excludeId])
        : await db.query('users');
    return rows.map(AppUser.fromMap).toList();
  }

  Future<List<AppUser>> searchUsers(String query, {int? excludeId}) async {
    final q = query.trim();
    if (q.isEmpty) return const [];

    final db = await _db;
    final like = '%$q%';
    final where = excludeId != null
        ? '(fullName LIKE ? OR artistName LIKE ? OR username LIKE ?) AND id != ?'
        : '(fullName LIKE ? OR artistName LIKE ? OR username LIKE ?)';
    final args = excludeId != null
        ? [like, like, like, excludeId]
        : [like, like, like];

    final rows = await db.query('users', where: where, whereArgs: args);
    return rows.map(AppUser.fromMap).toList();
  }

  Future<AppUser> updateProfile({
    required int id,
    String? artistName,
    String? bio,
    String? discipline,
    String? photoPath,
    String? coverPhotoPath,
    String? avatarFrameId,
    List<String>? featuredBadgeIds,
  }) async {
    final db = await _db;
    final values = <String, Object?>{};
    if (artistName != null) {
      values['artistName'] = artistName.trim().isEmpty
          ? null
          : artistName.trim();
    }
    if (bio != null) {
      values['bio'] = bio.trim().isEmpty ? null : bio.trim();
    }
    if (discipline != null) {
      values['discipline'] = discipline.trim().isEmpty
          ? null
          : discipline.trim();
    }
    if (photoPath != null) values['photoPath'] = photoPath;
    if (coverPhotoPath != null) values['coverPhotoPath'] = coverPhotoPath;
    if (avatarFrameId != null) {
      values['avatarFrameId'] = avatarFrameId.isEmpty ? null : avatarFrameId;
    }
    if (featuredBadgeIds != null) {
      values['featuredBadgeIds'] = featuredBadgeIds.join(',');
    }

    if (values.isNotEmpty) {
      await db.update('users', values, where: 'id = ?', whereArgs: [id]);
    }

    return (await findById(id))!;
  }

  /// Refleja en la tabla local `users` el usuario autenticado contra el backend
  /// Zentry, usando su ID real (Integer del backend). Así las funciones aún no
  /// integradas que resuelven usuarios por ID local (miembros de comunidad,
  /// actores de notificaciones, búsqueda) siguen encontrando al usuario actual.
  ///
  /// No participa en la autenticación: `passwordHash`/`salt` son placeholders.
  Future<AppUser> upsertFromBackend({
    required int id,
    required String username,
    required String email,
    String? fullName,
    String? artistName,
    String? bio,
    String? discipline,
    String? photoPath,
    String? coverPhotoPath,
  }) async {
    final db = await _db;
    final now = DateTime.now().toIso8601String();
    final normalizedEmail = email.trim().toLowerCase();

    final existing = await db.query(
      'users',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );

    final values = <String, Object?>{
      'id': id,
      'fullName': (fullName ?? '').trim().isEmpty ? username : fullName!.trim(),
      'artistName': (artistName ?? '').trim().isEmpty
          ? null
          : artistName!.trim(),
      'username': username.trim(),
      'email': normalizedEmail,
      if (bio != null) 'bio': bio.trim().isEmpty ? null : bio.trim(),
      if (discipline != null)
        'discipline': discipline.trim().isEmpty ? null : discipline.trim(),
      'photoPath': ?photoPath,
      'coverPhotoPath': ?coverPhotoPath,
    };

    if (existing.isEmpty) {
      values['passwordHash'] = 'backend';
      values['salt'] = 'backend';
      values['createdAt'] = now;
      await db.insert(
        'users',
        values,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } else {
      await db.update('users', values, where: 'id = ?', whereArgs: [id]);
    }

    return (await findById(id))!;
  }
}
