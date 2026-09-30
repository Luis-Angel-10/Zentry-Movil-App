import 'package:flutter/foundation.dart';

/// Configuración centralizada del backend Zentry (Spring Boot).
///
/// El backend local corre en el puerto 8080. La URL correcta depende de dónde
/// se ejecute Flutter:
///
///   * Android Emulator   -> `http://10.0.2.2:8080`  (10.0.2.2 = host loopback)
///   * Dispositivo físico -> `http://IP-LAN-de-la-PC:8080`
///   * Web / Desktop      -> `http://localhost:8080`
///
/// Se puede sobrescribir en tiempo de compilación sin tocar código:
///
///   flutter run --dart-define=ZENTRY_API_BASE_URL=http://192.168.1.50:8080
///   flutter build apk --dart-define=ZENTRY_API_BASE_URL=https://api.zentry.app
///
/// Prioridad: --dart-define  >  default por plataforma.
///
/// ── Dispositivo físico por ADB (p. ej. Huawei MatePad 11.5S en la misma
///    red que la laptop del backend) ──
/// El default de Android apunta a `10.0.2.2` (solo válido en el EMULADOR).
/// En un dispositivo físico usa la IP LAN real de la laptop vía el override:
///
///   flutter run --dart-define=ZENTRY_API_BASE_URL=http://192.168.1.71:8080
///
/// Además, Android bloquea HTTP en claro por defecto (targetSdk >= 28): el
/// host debe estar listado en
/// `android/app/src/debug/res/xml/network_security_config.xml` (ya incluye
/// `10.0.2.2`, `192.168.1.71`, `localhost` y `127.0.0.1`). Si la IP de la
/// laptop cambia, añádela también ahí.
class ApiConfig {
  ApiConfig._();

  /// Override explícito (vacío si no se pasó `--dart-define`).
  static const String _override = String.fromEnvironment(
    'ZENTRY_API_BASE_URL',
    defaultValue: '',
  );

  /// Puerto por defecto del backend en desarrollo.
  static const int devPort = 8080;

  /// `true` para forzar `localhost` incluso en Android (útil con
  /// `adb reverse tcp:8080 tcp:8080`).
  static const bool _androidUsesAdbReverse = bool.fromEnvironment(
    'ZENTRY_ANDROID_ADB_REVERSE',
    defaultValue: false,
  );

  /// Base URL efectiva del API (sin slash final).
  static String get baseUrl {
    if (_override.isNotEmpty) return _stripTrailingSlash(_override);
    return _stripTrailingSlash(_defaultForPlatform());
  }

  /// Raíz para servir archivos estáticos subidos (`/uploads/**`).
  static String get uploadsBaseUrl => baseUrl;

  /// URL del endpoint STOMP-sobre-WebSocket del backend
  /// (`WebSocketConfig.registerStompEndpoints` registra `/ws` con fallback
  /// SockJS). Spring registra automáticamente un transporte de WebSocket
  /// nativo (sin framing SockJS) en `{endpoint}/websocket`, que es el que se
  /// usa aquí para poder hablar STOMP puro con `stomp_dart_client` sin
  /// necesitar un cliente SockJS.
  static String get wsUrl {
    final http = baseUrl;
    final ws = http.startsWith('https://')
        ? 'wss://${http.substring('https://'.length)}'
        : 'ws://${http.substring('http://'.length)}';
    return '$ws/ws/websocket';
  }

  /// Resuelve una ruta relativa devuelta por el backend (p. ej.
  /// `/uploads/posts/abc.jpg`) a una URL absoluta apuntando al host correcto.
  /// Si ya es absoluta (http/https) se devuelve intacta.
  static String resolveMediaUrl(String? path) {
    if (path == null || path.isEmpty) return '';
    final p = path.trim();
    if (p.startsWith('http://') || p.startsWith('https://')) return p;
    if (p.startsWith('/')) return '$baseUrl$p';
    return '$baseUrl/$p';
  }

  /// ── ÚNICO PUNTO A CAMBIAR si la IP de la laptop cambia (DHCP) ──
  /// IP LAN de la laptop donde corre Spring Boot en las pruebas físicas
  /// (Wi-Fi "Centro Computo"). NO es la IP de ningún teléfono cliente
  /// (192.168.1.71 / 192.168.1.72). Es SOLO el host, sin puerto: el puerto lo
  /// aporta [devPort] al construirse la URL en [_defaultForPlatform] (ver
  /// [baseUrl] y [wsUrl]); si cambia, añade también el nuevo host en
  /// android/app/src/debug/res/xml/network_security_config.xml.
  /// Para un emulador usa `--dart-define=ZENTRY_API_BASE_URL=http://10.0.2.2:8080`.
  static const String lanServerHost = '192.168.1.71';

  static String _defaultForPlatform() {
    if (kIsWeb) return 'http://localhost:$devPort';
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return _androidUsesAdbReverse
            ? 'http://localhost:$devPort'
            : 'http://$lanServerHost:$devPort';
      case TargetPlatform.iOS:
      case TargetPlatform.macOS:
      case TargetPlatform.windows:
      case TargetPlatform.linux:
      case TargetPlatform.fuchsia:
        return 'http://localhost:$devPort';
    }
  }

  static String _stripTrailingSlash(String v) =>
      v.endsWith('/') ? v.substring(0, v.length - 1) : v;
}
