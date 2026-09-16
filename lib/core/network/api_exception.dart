import 'package:dio/dio.dart';

/// Error normalizado de cualquier llamada al backend Zentry.
///
/// El backend responde los errores con este cuerpo (ver GlobalExceptionHandler):
/// ```json
/// { "timestamp": "...", "status": 404, "error": "Not Found",
///   "message": "Usuario no encontrado", "errors": { "email": "no válido" } }
/// ```
class ApiException implements Exception {
  ApiException({
    required this.statusCode,
    required this.message,
    this.fieldErrors = const {},
    this.isNetworkError = false,
    this.isTimeout = false,
  });

  /// Código HTTP. `0` cuando no hubo respuesta (sin red / timeout).
  final int statusCode;

  /// Mensaje legible para el usuario (extraído del backend cuando existe).
  final String message;

  /// Errores de validación por campo (`errors` en el cuerpo del backend).
  final Map<String, String> fieldErrors;

  final bool isNetworkError;
  final bool isTimeout;

  bool get isUnauthorized => statusCode == 401;
  bool get isForbidden => statusCode == 403;

  /// El backend usa 403 tanto para "sin token" como para "JWT inválido".
  /// Ambos casos, junto al 401, se tratan como sesión inválida.
  bool get isSessionInvalid => statusCode == 401 || statusCode == 403;

  bool get isNotFound => statusCode == 404;
  bool get isConflict => statusCode == 409;
  bool get isValidation => statusCode == 400 || statusCode == 422;
  bool get isServerError => statusCode >= 500;

  /// Construye una [ApiException] a partir de un [DioException].
  factory ApiException.fromDio(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return ApiException(
          statusCode: 0,
          message: 'La conexión con el servidor tardó demasiado.',
          isTimeout: true,
          isNetworkError: true,
        );
      case DioExceptionType.connectionError:
      case DioExceptionType.unknown:
        return ApiException(
          statusCode: 0,
          message: 'No se pudo conectar con el servidor. Verifica tu conexión.',
          isNetworkError: true,
        );
      case DioExceptionType.badCertificate:
        return ApiException(
          statusCode: 0,
          message: 'Certificado del servidor no válido.',
          isNetworkError: true,
        );
      case DioExceptionType.cancel:
        return ApiException(statusCode: 0, message: 'Solicitud cancelada.');
      case DioExceptionType.badResponse:
        final response = e.response;
        final code = response?.statusCode ?? 0;
        return ApiException(
          statusCode: code,
          message: _extractMessage(response?.data, code),
          fieldErrors: _extractFieldErrors(response?.data),
        );
      default:
        return ApiException(
          statusCode: 0,
          message: 'No se pudo completar la solicitud. Inténtalo de nuevo.',
          isNetworkError: true,
        );
    }
  }

  static String _extractMessage(dynamic data, int code) {
    if (data is Map) {
      final msg = data['message'] ?? data['error'] ?? data['detail'];
      if (msg is String && msg.trim().isNotEmpty) return msg.trim();
    }
    if (data is String && data.trim().isNotEmpty && data.length < 300) {
      return data.trim();
    }
    return switch (code) {
      400 => 'Solicitud inválida.',
      401 => 'Debes iniciar sesión para continuar.',
      403 => 'Tu sesión expiró o no tienes permiso.',
      404 => 'Recurso no encontrado.',
      409 => 'Conflicto: el recurso ya existe.',
      422 => 'Datos no procesables.',
      >= 500 => 'Error interno del servidor. Inténtalo más tarde.',
      _ => 'Ocurrió un error inesperado (HTTP $code).',
    };
  }

  static Map<String, String> _extractFieldErrors(dynamic data) {
    if (data is Map && data['errors'] is Map) {
      final raw = data['errors'] as Map;
      return raw.map((k, v) => MapEntry(k.toString(), v.toString()));
    }
    return const {};
  }

  @override
  String toString() =>
      'ApiException($statusCode): $message'
      '${fieldErrors.isNotEmpty ? ' $fieldErrors' : ''}';
}
