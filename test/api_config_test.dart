// Tests de construcción/resolución de URLs del backend (ApiConfig).
//
// Pasan tanto con `flutter test` (default = servidor desplegado) como con
// `flutter test --dart-define=ZENTRY_API_BASE_URL=http://192.168.1.71:8080`
// (override local).

import 'package:flutter_test/flutter_test.dart';
import 'package:stomp_dart_client/stomp_dart_client.dart';
import 'package:Zentry/core/config/api_config.dart';

const _server = 'https://zentrycommunity.tail314909.ts.net:10000';
const _local = 'http://192.168.1.71:8080';
const _override = String.fromEnvironment('ZENTRY_API_BASE_URL');

void main() {
  group('Base URL', () {
    test('default = servidor desplegado', () {
      expect(ApiConfig.defaultBaseUrl, _server);
      expect(ApiConfig.resolveBaseUrl(), _server);
    });

    test('baseUrl efectiva = override si existe, si no el servidor', () {
      expect(
        ApiConfig.baseUrl,
        _override.isEmpty ? _server : _override.replaceAll(RegExp(r'/+$'), ''),
      );
    });

    test('REST contra el servidor por defecto', () {
      final url = '${ApiConfig.resolveBaseUrl()}/api/core/streaks/me';
      expect(url, '$_server/api/core/streaks/me');
      expect(url.contains('192.168.'), isFalse);
    });

    test('override tiene prioridad y respeta su puerto (sin :8080:8080)', () {
      final base = ApiConfig.resolveBaseUrl(override: _local);
      expect(base, _local);
      expect('$base/api/core/streaks/me', '$_local/api/core/streaks/me');
      expect(base.contains(':8080:8080'), isFalse);
      expect(ApiConfig.resolveBaseUrl(override: '$_local/'), _local);
      expect(ApiConfig.resolveBaseUrl(override: '  $_local  '), _local);
      expect(
        ApiConfig.resolveBaseUrl(override: _local, adbReverse: true),
        _local,
      );
    });

    test('adb reverse sin override usa localhost:8080', () {
      expect(
        ApiConfig.resolveBaseUrl(adbReverse: true),
        'http://localhost:8080',
      );
    });
  });

  group('STOMP/SockJS', () {
    test('endpoint SockJS /ws derivado de la Base URL', () {
      expect(ApiConfig.wsUrlFor(_server), '$_server/ws');
      expect(ApiConfig.wsUrlFor(_local), '$_local/ws');
    });

    // `connectUrl` es la URL real que abre `stomp_dart_client` en modo SockJS.
    test('https -> wss con mismo host y puerto (transporte SockJS)', () {
      final c = StompConfig.sockJS(url: ApiConfig.wsUrlFor(_server));
      expect(
        c.connectUrl,
        matches(
          RegExp(
            r'^wss://zentrycommunity\.tail314909\.ts\.net:10000/ws/\d{3}/[a-z0-5]{8}/websocket$',
          ),
        ),
      );
    });

    test('http -> ws con mismo host y puerto (transporte SockJS)', () {
      final c = StompConfig.sockJS(url: ApiConfig.wsUrlFor(_local));
      expect(
        c.connectUrl,
        matches(
          RegExp(r'^ws://192\.168\.1\.71:8080/ws/\d{3}/[a-z0-5]{8}/websocket$'),
        ),
      );
      expect(c.connectUrl.contains(':8080:8080'), isFalse);
    });

    test('wsUrl efectiva sigue a baseUrl', () {
      expect(ApiConfig.wsUrl, ApiConfig.wsUrlFor(ApiConfig.baseUrl));
    });
  });

  group('Multimedia', () {
    test('ruta relativa usa la Base URL', () {
      expect(
        ApiConfig.resolveMediaUrlFor(_server, '/uploads/archivo.jpg'),
        '$_server/uploads/archivo.jpg',
      );
      expect(
        ApiConfig.resolveMediaUrlFor(_server, 'uploads/archivo.jpg'),
        '$_server/uploads/archivo.jpg',
      );
      expect(
        ApiConfig.resolveMediaUrl('/uploads/archivo.jpg'),
        '${ApiConfig.baseUrl}/uploads/archivo.jpg',
      );
    });

    test('URL absoluta permanece intacta', () {
      const abs = 'https://cdn.example.com/a/b.mp4';
      expect(ApiConfig.resolveMediaUrlFor(_server, abs), abs);
      expect(ApiConfig.resolveMediaUrl(abs), abs);
    });

    test('null/vacío -> cadena vacía', () {
      expect(ApiConfig.resolveMediaUrlFor(_server, null), '');
      expect(ApiConfig.resolveMediaUrlFor(_server, ''), '');
    });
  });
}
