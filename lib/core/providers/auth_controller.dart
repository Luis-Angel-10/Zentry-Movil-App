import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:Zentry/core/models/app_user.dart';
import 'package:Zentry/core/models/backend/auth_response.dart';
import 'package:Zentry/core/models/backend/profile_response.dart';
import 'package:Zentry/core/network/api_exception.dart';
import 'package:Zentry/core/network/auth_api.dart';
import 'package:Zentry/core/network/profile_api.dart';
import 'package:Zentry/core/network/realtime_client.dart';
import 'package:Zentry/core/network/token_storage.dart';
import 'package:Zentry/core/services/auth_repository.dart';
import 'package:Zentry/core/services/biometric_service.dart';
import 'package:Zentry/core/services/fcm_service.dart';

/// Controlador de autenticación. Desde la integración con el backend Zentry
/// (Spring Boot) la sesión se basa en un JWT guardado en almacenamiento seguro:
///
///  * `login`        -> POST /api/auth/login          -> token
///  * `register`     -> POST /api/auth/register       -> requiere OTP
///  * `verifyOtp`    -> POST /api/auth/verify-login   -> token
///  * `resendOtp`    -> POST /api/auth/resend-otp
///  * arranque       -> GET  /api/core/profiles/me    (restaura sesión)
///  * `logout`       -> borra el token
///
/// La tabla local `users` se sigue usando SÓLO como espejo de lectura para las
/// funciones aún no integradas (comunidades, notificaciones, búsqueda).
class AuthController extends ChangeNotifier {
  static const String _biometricEnabledKey = 'biometric_enabled';
  static const String _biometricUserIdKey = 'biometric_user_id';

  /// Mantiene `RealtimeClient.currentUserId` sincronizado con `currentUser`
  /// sin importar por cuál de los varios flujos de login/refresh haya
  /// cambiado — se necesita para que el cliente STOMP nunca genere una
  /// notificación local de un mensaje propio.
  @override
  void notifyListeners() {
    RealtimeClient.instance.currentUserId = currentUser?.id;
    super.notifyListeners();
  }

  final AuthRepository _repository = AuthRepository();
  final BiometricService _biometrics = BiometricService();
  final AuthApi _authApi = AuthApi.instance;
  final ProfileApi _profileApi = ProfileApi.instance;
  final TokenStorage _tokens = TokenStorage.instance;

  AppUser? currentUser;
  ProfileResponse? backendProfile;
  bool isLoading = false;

  /// Se pone a `true` cuando el backend invalida la sesión (401/403) para que
  /// la UI pueda mostrar un aviso una sola vez.
  bool sessionExpired = false;

  bool biometricEnabled = false;
  int? biometricUserId;
  AppUser? biometricUser;

  bool get isLoggedIn => currentUser != null;

  /// Se dispara al FINAL de [_establishSession] (login real y verificación
  /// de OTP tras registro) — es decir, cuando una sesión nueva se establece
  /// DENTRO de la ejecución actual de la app (no al reiniciarla).
  ///
  /// Existe porque varios controllers (`StreakController`, `WalletController`)
  /// sólo se cargaban una vez, en `main.dart`, al arrancar el proceso — si en
  /// ese momento todavía no había sesión (usuario recién abre la app y aún no
  /// ha iniciado sesión), esa carga fallaba por falta de token y nunca se
  /// repetía. Por eso la racha/saldo aparecían en 0 hasta cerrar y reabrir la
  /// app (momento en que el token ya existía desde el arranque). Login
  /// biométrico no necesita este hook: sólo es posible cuando el token ya
  /// existía desde el arranque, así que esas cargas ya tuvieron éxito.
  VoidCallback? onSessionEstablished;

  /// Se dispara al FINAL de [_wipeSession] (logout real o sesión invalidada
  /// por 401/403) — corrección: `StreakController` (y otros controllers con
  /// estado "del usuario actual" que main.dart sólo carga una vez al
  /// arrancar) vivían como singletons durante toda la vida del proceso y
  /// nunca se limpiaban en logout. Si el usuario A cerraba sesión e iniciaba
  /// sesión el usuario B en la MISMA ejecución de la app (sin reiniciarla),
  /// la UI podía mostrar brevemente la racha de A hasta que la respuesta de
  /// `GET /api/core/streaks/me` para B llegara — o, si esa petición fallaba,
  /// quedarse indefinidamente con el valor de A (el controller conserva el
  /// último valor conocido ante errores de red, asumiendo que sigue siendo
  /// el mismo usuario). Con este hook, main.dart limpia ese estado ANTES de
  /// que pueda quedar visible.
  VoidCallback? onSessionCleared;

  // ─────────────────────────────────────────────────────────────────────────
  // Arranque / restauración de sesión
  // ─────────────────────────────────────────────────────────────────────────

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    biometricEnabled = prefs.getBool(_biometricEnabledKey) ?? false;
    biometricUserId = prefs.getInt(_biometricUserIdKey);

    await _tokens.warmUp();

    if (!_tokens.hasToken) {
      biometricEnabled = false;
      biometricUserId = null;
      notifyListeners();
      return;
    }

    try {
      final profile = await _profileApi.getMyProfile();
      await _applyProfile(profile);
    } on ApiException catch (e) {
      if (e.isSessionInvalid) {
        await _wipeSession(markExpired: false);
      } else {
        // Sin conexión con el servidor: restauramos una sesión mínima con lo
        // guardado para no expulsar al usuario por un fallo de red puntual.
        final stored = await _tokens.readUser();
        if (stored.id != null && stored.username != null) {
          currentUser = AppUser(
            id: stored.id!,
            fullName: stored.username!,
            username: stored.username!,
            email: stored.email ?? '',
          );
        }
      }
    }

    if (biometricEnabled && biometricUserId != null) {
      biometricUser = currentUser;
      if (currentUser == null) {
        // Token presente pero perfil no verificable ahora: se conserva.
      }
    }

    notifyListeners();
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Login con email + contraseña
  // ─────────────────────────────────────────────────────────────────────────

  Future<AuthFailure?> login({
    required String email,
    required String password,
  }) async {
    isLoading = true;
    sessionExpired = false;
    notifyListeners();
    try {
      final resp = await _authApi.login(email: email, password: password);

      if (resp.requiresVerification && !resp.hasToken) {
        return AuthFailure.needsVerification;
      }
      if (!resp.hasToken) {
        return AuthFailure.invalidCredentials;
      }

      await _establishSession(resp, fallbackEmail: email);
      return null;
    } on ApiException catch (e) {
      return _mapAuthError(e);
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Registro (el backend siempre exige verificación por OTP)
  // ─────────────────────────────────────────────────────────────────────────

  /// Devuelve `null` si el registro fue aceptado y ahora procede la pantalla
  /// de verificación por código. Devuelve un [AuthFailure] si hubo error.
  Future<AuthFailure?> register({
    required String username,
    required String email,
    required String password,
  }) async {
    isLoading = true;
    notifyListeners();
    try {
      await _authApi.register(
        username: username,
        email: email,
        password: password,
      );
      return null;
    } on ApiException catch (e) {
      if (e.isConflict) return AuthFailure.emailTaken;
      if (e.isValidation) {
        final f = e.fieldErrors;
        if (f.containsKey('username')) return AuthFailure.usernameTaken;
        if (f.containsKey('email')) return AuthFailure.emailTaken;
      }
      return _mapAuthError(e);
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  /// Verifica el código OTP. Al obtener token, si se pasan datos de perfil
  /// pendientes del registro, se guardan con `PUT /api/core/profiles/me`.
  Future<AuthFailure?> verifyOtp({
    required String email,
    required String code,
    String? pendingName,
    String? pendingArtistName,
    String? pendingDiscipline,
    String? pendingBio,
  }) async {
    isLoading = true;
    notifyListeners();
    try {
      final resp = await _authApi.verifyOtp(email: email, code: code);
      if (!resp.hasToken) return AuthFailure.otpInvalid;

      await _establishSession(resp, fallbackEmail: email);

      final hasPending = [
        pendingName,
        pendingArtistName,
        pendingDiscipline,
        pendingBio,
      ].any((v) => (v ?? '').trim().isNotEmpty);

      if (hasPending) {
        try {
          final updated = await _profileApi.updateMyProfile(
            name: _nullIfBlank(pendingName),
            artisticName: _nullIfBlank(pendingArtistName),
            discipline: _nullIfBlank(pendingDiscipline),
            bio: _nullIfBlank(pendingBio),
          );
          await _applyProfile(updated);
        } on ApiException {
          // El alta ya está hecha; si el perfil falla no bloqueamos el acceso.
        }
      }
      return null;
    } on ApiException catch (e) {
      return _mapAuthError(e);
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<AuthFailure?> resendOtp(String email) async {
    try {
      await _authApi.resendOtp(email: email);
      return null;
    } on ApiException catch (e) {
      return _mapAuthError(e);
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Recuperación de contraseña (forgot / reset password)
  // ─────────────────────────────────────────────────────────────────────────

  /// `POST /api/auth/forgot-password`. Envía un código OTP de 6 dígitos al
  /// correo si existe una cuenta asociada.
  Future<AuthFailure?> forgotPassword(String email) async {
    isLoading = true;
    notifyListeners();
    try {
      await _authApi.forgotPassword(email: email);
      return null;
    } on ApiException catch (e) {
      return _mapAuthError(e);
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  /// `POST /api/auth/reset-password`. Verifica el código y establece la
  /// nueva contraseña en una sola llamada. No inicia sesión: el usuario debe
  /// volver a loguearse con la contraseña nueva.
  Future<AuthFailure?> resetPassword({
    required String email,
    required String code,
    required String newPassword,
  }) async {
    isLoading = true;
    notifyListeners();
    try {
      await _authApi.resetPassword(
        email: email,
        code: code,
        newPassword: newPassword,
      );
      return null;
    } on ApiException catch (e) {
      if (e.isValidation && e.fieldErrors.containsKey('newPassword')) {
        return AuthFailure.weakPassword;
      }
      return _mapAuthError(e);
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Biometría (desbloqueo rápido; requiere token válido en almacenamiento)
  // ─────────────────────────────────────────────────────────────────────────

  Future<bool> setBiometricEnabled(bool value) async {
    final prefs = await SharedPreferences.getInstance();

    if (!value) {
      biometricEnabled = false;
      biometricUserId = null;
      biometricUser = null;
      await prefs.remove(_biometricEnabledKey);
      await prefs.remove(_biometricUserIdKey);
      notifyListeners();
      return true;
    }

    final user = currentUser;
    if (user == null || !_tokens.hasToken) return false;
    if (!await _biometrics.isSupported()) return false;

    final ok = await _biometrics.authenticate(
      'Confirma tu huella o rostro para activar el desbloqueo biométrico',
    );
    if (!ok) return false;

    biometricEnabled = true;
    biometricUserId = user.id;
    biometricUser = user;
    await prefs.setBool(_biometricEnabledKey, true);
    await prefs.setInt(_biometricUserIdKey, user.id);
    notifyListeners();
    return true;
  }

  Future<AuthFailure?> loginWithBiometrics() async {
    if (!_tokens.hasToken) return AuthFailure.biometricUnavailable;

    isLoading = true;
    notifyListeners();
    try {
      if (!await _biometrics.isSupported()) {
        return AuthFailure.biometricUnavailable;
      }
      final ok = await _biometrics.authenticate(
        'Usa tu huella o rostro para iniciar sesión',
      );
      if (!ok) return AuthFailure.biometricFailed;

      try {
        final profile = await _profileApi.getMyProfile();
        await _applyProfile(profile);
        return null;
      } on ApiException catch (e) {
        if (e.isSessionInvalid) {
          await _wipeSession(markExpired: false);
          return AuthFailure.biometricUnavailable;
        }
        // Sin red: restaura sesión mínima con lo almacenado.
        final stored = await _tokens.readUser();
        if (stored.id != null && stored.username != null) {
          currentUser = AppUser(
            id: stored.id!,
            fullName: stored.username!,
            username: stored.username!,
            email: stored.email ?? '',
          );
          return null;
        }
        return AuthFailure.network;
      }
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Logout / expiración de sesión
  // ─────────────────────────────────────────────────────────────────────────

  Future<void> logout() async {
    await _wipeSession(markExpired: false);
  }

  /// Invocado por [ApiClient.onSessionInvalid] cuando el backend responde
  /// 401/403 en un endpoint autenticado.
  void handleSessionInvalid() {
    if (currentUser == null && !_tokens.hasToken) return;
    _wipeSession(markExpired: true);
  }

  Future<void> _wipeSession({required bool markExpired}) async {
    currentUser = null;
    backendProfile = null;
    biometricEnabled = false;
    biometricUserId = null;
    biometricUser = null;
    sessionExpired = markExpired;
    RealtimeClient.instance.disconnect();
    await FcmService.instance.onLogout();
    await _tokens.clear();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_biometricEnabledKey);
    await prefs.remove(_biometricUserIdKey);
    onSessionCleared?.call();
    notifyListeners();
  }

  void acknowledgeSessionExpired() {
    sessionExpired = false;
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Perfil
  // ─────────────────────────────────────────────────────────────────────────

  /// Actualiza el perfil contra `PUT /api/core/profiles/me`.
  ///
  /// * Campos de texto y `isPrivate` -> DTO `ProfileRequest` (JSON).
  /// * `avatarPath` / `bannerPath` -> multipart/form-data (campos `avatar` /
  ///   `banner`); el backend los guarda en `/uploads/profiles/**`.
  /// * `avatarFrameId` / `featuredBadgeIds` / rutas de foto locales -> sólo se
  ///   guardan en el espejo local (son elementos de UI sin equivalente backend).
  ///
  /// Devuelve `null` si todo fue bien, o la [ApiException] si el backend falló
  /// (el cambio local se conserva de todas formas).
  Future<ApiException?> updateProfile({
    String? name,
    String? artistName,
    String? bio,
    String? discipline,
    String? location,
    String? experienceLevel,
    bool? isPrivate,
    String? avatarPath,
    String? bannerPath,
    String? photoPath,
    String? coverPhotoPath,
    String? avatarFrameId,
    List<String>? featuredBadgeIds,
  }) async {
    final user = currentUser;
    if (user == null) return null;

    ApiException? failure;

    final hasFiles =
        (avatarPath?.isNotEmpty ?? false) || (bannerPath?.isNotEmpty ?? false);
    final hasBackendFields =
        [
          _nullIfBlank(name),
          _nullIfBlank(artistName),
          bio,
          _nullIfBlank(discipline),
          _nullIfBlank(location),
          _nullIfBlank(experienceLevel),
        ].any((v) => v != null) ||
        isPrivate != null;

    if (hasFiles || hasBackendFields) {
      try {
        final updated = hasFiles
            ? await _profileApi.updateMyProfileMultipart(
                name: _nullIfBlank(name),
                artisticName: _nullIfBlank(artistName),
                discipline: _nullIfBlank(discipline),
                location: _nullIfBlank(location),
                bio: bio,
                experienceLevel: _nullIfBlank(experienceLevel),
                isPrivate: isPrivate,
                avatarPath: avatarPath,
                bannerPath: bannerPath,
              )
            : await _profileApi.updateMyProfile(
                name: _nullIfBlank(name),
                artisticName: _nullIfBlank(artistName),
                discipline: _nullIfBlank(discipline),
                location: _nullIfBlank(location),
                bio: bio,
                experienceLevel: _nullIfBlank(experienceLevel),
                isPrivate: isPrivate,
              );
        backendProfile = updated;
      } on ApiException catch (e) {
        failure = e; // se conserva el cambio local
      }
    }

    // Espejo local + campos sólo-UI. Las rutas locales de avatar/banner recién
    // elegidas se guardan también para verlas al instante en el perfil.
    final updatedLocal = await _repository.updateProfile(
      id: user.id,
      artistName: artistName,
      bio: bio,
      discipline: discipline,
      photoPath: photoPath ?? avatarPath,
      coverPhotoPath: coverPhotoPath ?? bannerPath,
      avatarFrameId: avatarFrameId,
      featuredBadgeIds: featuredBadgeIds,
    );

    currentUser = _mergeUser(base: updatedLocal, profile: backendProfile);
    notifyListeners();
    return failure;
  }

  /// Recarga el perfil desde el backend.
  Future<void> refreshProfile() async {
    if (!_tokens.hasToken) return;
    try {
      final profile = await _profileApi.getMyProfile();
      await _applyProfile(profile);
      notifyListeners();
    } on ApiException {
      /* silencioso */
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Helpers privados
  // ─────────────────────────────────────────────────────────────────────────

  Future<void> _establishSession(
    AuthResponse resp, {
    required String fallbackEmail,
  }) async {
    await _tokens.saveSession(
      token: resp.token!,
      userId: resp.id,
      username: resp.username,
      email: resp.email ?? fallbackEmail,
    );
    sessionExpired = false;

    ProfileResponse? profile;
    try {
      profile = await _profileApi.getMyProfile();
    } on ApiException {
      profile = null;
    }

    if (profile != null) {
      await _applyProfile(
        profile,
        idOverride: resp.id,
        emailOverride: resp.email ?? fallbackEmail,
        usernameOverride: resp.username,
      );
    } else {
      final id = resp.id ?? 0;
      final username = resp.username ?? fallbackEmail.split('@').first;
      currentUser = AppUser(
        id: id,
        fullName: username,
        username: username,
        email: resp.email ?? fallbackEmail,
      );
      if (id != 0) {
        await _repository.upsertFromBackend(
          id: id,
          username: username,
          email: resp.email ?? fallbackEmail,
        );
      }
    }

    onSessionEstablished?.call();
  }

  Future<void> _applyProfile(
    ProfileResponse profile, {
    int? idOverride,
    String? emailOverride,
    String? usernameOverride,
  }) async {
    backendProfile = profile;

    final stored = await _tokens.readUser();
    final id = idOverride ?? stored.id ?? currentUser?.id ?? 0;
    final email = emailOverride ?? stored.email ?? currentUser?.email ?? '';
    final username =
        usernameOverride ??
        (profile.username.isNotEmpty ? profile.username : null) ??
        stored.username ??
        currentUser?.username ??
        (email.contains('@') ? email.split('@').first : email);

    // Espejo local para funciones aún no integradas.
    AppUser? mirrored;
    if (id != 0) {
      try {
        mirrored = await _repository.upsertFromBackend(
          id: id,
          username: username,
          email: email,
          fullName: profile.name,
          artistName: profile.artisticName,
          bio: profile.bio,
          discipline: profile.discipline,
        );
      } catch (_) {
        mirrored = null;
      }
    }

    final base =
        mirrored ??
        AppUser(
          id: id,
          fullName: (profile.name ?? '').trim().isEmpty
              ? username
              : profile.name!.trim(),
          username: username,
          email: email,
        );

    currentUser = _mergeUser(base: base, profile: profile);

    if (currentUser != null &&
        biometricEnabled &&
        biometricUserId == currentUser!.id) {
      biometricUser = currentUser;
    }
  }

  AppUser _mergeUser({required AppUser base, ProfileResponse? profile}) {
    if (profile == null) return base;
    return AppUser(
      id: base.id,
      fullName: (profile.name ?? '').trim().isNotEmpty
          ? profile.name!.trim()
          : base.fullName,
      username: profile.username.isNotEmpty ? profile.username : base.username,
      email: base.email,
      artistName: _nullIfBlank(profile.artisticName) ?? base.artistName,
      discipline: _nullIfBlank(profile.discipline) ?? base.discipline,
      bio: _nullIfBlank(profile.bio) ?? base.bio,
      photoPath: base.photoPath,
      coverPhotoPath: base.coverPhotoPath,
      avatarFrameId: base.avatarFrameId,
      featuredBadgeIds: base.featuredBadgeIds,
      interests: base.interests,
    );
  }

  AuthFailure _mapAuthError(ApiException e) {
    if (e.isNetworkError || e.isTimeout) return AuthFailure.network;
    if (e.statusCode == 401) return AuthFailure.invalidCredentials;
    if (e.statusCode == 404) return AuthFailure.userNotFound;
    if (e.statusCode == 409) return AuthFailure.emailTaken;
    if (e.statusCode == 410) return AuthFailure.otpExpired;
    if (e.statusCode == 429) return AuthFailure.otpTooManyAttempts;
    if (e.statusCode == 400) return AuthFailure.otpInvalid;
    if (e.isServerError) return AuthFailure.serverError;
    return AuthFailure.unknown;
  }

  static String? _nullIfBlank(String? v) =>
      (v == null || v.trim().isEmpty) ? null : v.trim();
}
