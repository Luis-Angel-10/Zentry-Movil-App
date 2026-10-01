/// Configuración centralizada del backend Zentry (Spring Boot). ÚNICA fuente
/// de verdad del host del backend: REST ([baseUrl]), WebSocket ([wsUrl]) y
/// multimedia ([resolveMediaUrl]) se derivan todos de aquí.
///
/// Por defecto la app consume el backend DESPLEGADO ([defaultBaseUrl]), por
/// HTTPS a través de Internet: cualquier teléfono/tablet con el APK funciona
/// sin estar en la misma red que la laptop de desarrollo.
///
/// Para desarrollo local se puede sobrescribir en tiempo de compilación sin
/// tocar código (el valor se usa TAL CUAL, incluido su puerto; solo se
/// eliminan espacios y el slash final):
///
///   flutter run --dart-define=ZENTRY_API_BASE_URL=http://192.168.1.71:8080
///   flutter run --dart-define=ZENTRY_API_BASE_URL=http://10.0.2.2:8080   (emulador)
///   flutter run --dart-define=ZENTRY_ANDROID_ADB_REVERSE=true             (adb reverse tcp:8080 tcp:8080)
///
/// Prioridad: ZENTRY_API_BASE_URL  >  ZENTRY_ANDROID_ADB_REVERSE  >  [defaultBaseUrl].
///
/// Nota: Android bloquea HTTP en claro por defecto (targetSdk >= 28). Los
/// hosts de desarrollo HTTP deben estar listados en
/// `android/app/src/debug/res/xml/network_security_config.xml` (solo debug).
/// El backend desplegado usa HTTPS y no necesita ninguna excepción.
class ApiConfig {
  ApiConfig._();

  /// Backend desplegado (servidor). Default de todas las plataformas.
  static const String defaultBaseUrl =
      'https://zentrycommunity.tail314909.ts.net:10000';

  /// Override explícito (vacío si no se pasó `--dart-define`).
  static const String _override = String.fromEnvironment(
    'ZENTRY_API_BASE_URL',
    defaultValue: '',
  );

  /// Puerto del backend cuando corre localmente (solo para adb reverse).
  static const int devPort = 8080;

  /// `true` para usar `http://localhost:8080` (útil con
  /// `adb reverse tcp:8080 tcp:8080` contra un backend local).
  static const bool _androidUsesAdbReverse = bool.fromEnvironment(
    'ZENTRY_ANDROID_ADB_REVERSE',
    defaultValue: false,
  );

  /// Base URL efectiva del API (sin slash final).
  static String get baseUrl =>
      resolveBaseUrl(override: _override, adbReverse: _androidUsesAdbReverse);

  /// Raíz para servir archivos estáticos subidos (`/uploads/**`).
  static String get uploadsBaseUrl => baseUrl;

  /// URL del endpoint STOMP-sobre-SockJS del backend
  /// (`WebSocketConfig.registerStompEndpoints` registra `/ws` con SockJS).
  ///
  /// Es una URL HTTP/HTTPS (`{baseUrl}/ws`) porque así la exige
  /// `StompConfig.sockJS` de `stomp_dart_client`: la propia librería genera
  /// el transporte SockJS convirtiendo `https` -> `wss` / `http` -> `ws`
  /// (`{baseUrl}/ws/<server>/<session>/websocket`, ver
  /// `SockJsUtils.generateTransportUrl`) y lanza `ArgumentError` si recibe
  /// una URL `ws(s)://`.
  static String get wsUrl => wsUrlFor(baseUrl);

  /// Resuelve una ruta relativa devuelta por el backend (p. ej.
  /// `/uploads/posts/abc.jpg`) a una URL absoluta apuntando al host correcto.
  /// Si ya es absoluta (http/https) se devuelve intacta.
  static String resolveMediaUrl(String? path) =>
      resolveMediaUrlFor(baseUrl, path);

  // ── Funciones puras (testeables sin --dart-define) ──

  /// Base URL a partir del override y del flag de adb reverse.
  static String resolveBaseUrl({String override = '', bool adbReverse = false}) {
    final o = override.trim();
    if (o.isNotEmpty) return _stripTrailingSlash(o);
    if (adbReverse) return 'http://localhost:$devPort';
    return defaultBaseUrl;
  }

  /// Endpoint SockJS `/ws` de [base], con el mismo esquema, host y puerto.
  static String wsUrlFor(String base) => '$base/ws';

  /// Igual que [resolveMediaUrl], pero contra una [base] explícita.
  static String resolveMediaUrlFor(String base, String? path) {
    if (path == null || path.isEmpty) return '';
    final p = path.trim();
    if (p.startsWith('http://') || p.startsWith('https://')) return p;
    if (p.startsWith('/')) return '$base$p';
    return '$base/$p';
  }

  static String _stripTrailingSlash(String v) {
    var s = v;
    while (s.endsWith('/')) {
      s = s.substring(0, s.length - 1);
    }
    return s;
  }
}
