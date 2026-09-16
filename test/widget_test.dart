// Smoke test básico. El test original de plantilla (contador) nunca aplicó a
// esta app y además `ZentryApp` requiere plugins nativos (almacenamiento
// seguro, sqflite) no disponibles en el entorno de test unitario.
//
// Se valida aquí la lógica de configuración de la API, que sí es pura.

import 'package:flutter_test/flutter_test.dart';
import 'package:Zentry/core/config/api_config.dart';
import 'package:Zentry/core/network/api_exception.dart';

void main() {
  test('ApiConfig.baseUrl no termina en slash y apunta al puerto 8080', () {
    expect(ApiConfig.baseUrl.endsWith('/'), isFalse);
    expect(ApiConfig.baseUrl.contains('8080'), isTrue);
  });

  test(
    'ApiConfig.resolveMediaUrl respeta URLs absolutas y resuelve relativas',
    () {
      expect(
        ApiConfig.resolveMediaUrl('https://cdn.x/y.png'),
        'https://cdn.x/y.png',
      );
      expect(
        ApiConfig.resolveMediaUrl('/uploads/posts/a.jpg'),
        '${ApiConfig.baseUrl}/uploads/posts/a.jpg',
      );
      expect(ApiConfig.resolveMediaUrl(null), '');
    },
  );

  test('ApiException clasifica 401/403 como sesión inválida', () {
    expect(
      ApiException(statusCode: 401, message: 'x').isSessionInvalid,
      isTrue,
    );
    expect(
      ApiException(statusCode: 403, message: 'x').isSessionInvalid,
      isTrue,
    );
    expect(
      ApiException(statusCode: 404, message: 'x').isSessionInvalid,
      isFalse,
    );
  });
}
