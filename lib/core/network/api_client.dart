import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import 'package:Zentry/core/config/api_config.dart';
import 'package:Zentry/core/network/api_exception.dart';
import 'package:Zentry/core/network/token_storage.dart';

/// Cliente HTTP central de la app. Toda comunicación con el backend Zentry
/// pasa por aquí. Un único [Dio] con interceptores para:
///
///   * inyectar `Authorization: Bearer <jwt>` en cada petición autenticada
///   * normalizar errores a [ApiException]
///   * detectar sesión inválida (401/403) y notificar a la app una sola vez
class ApiClient {
  ApiClient._();
  static final ApiClient instance = ApiClient._();

  late final Dio dio;
  bool _initialized = false;

  /// Se invoca cuando el backend responde 401/403 en un endpoint autenticado.
  /// La app (AuthController) lo usa para limpiar la sesión y volver al login.
  VoidCallback? onSessionInvalid;

  void init() {
    if (_initialized) return;
    _initialized = true;

    dio = Dio(
      BaseOptions(
        baseUrl: ApiConfig.baseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 20),
        sendTimeout: const Duration(seconds: 20),
        // Content-Type EXPLÍCITO con charset UTF-8 en cada request con body.
        // Spring Boot devuelve `application/json` sin parámetro charset (es
        // válido: JSON es UTF-8 por definición en RFC 8259), pero lo hacemos
        // explícito en la salida para no depender de que ningún proxy/túnel
        // intermedio (dev tunnels, etc.) reescriba esa cabecera.
        contentType: 'application/json; charset=utf-8',
        headers: {'Accept': 'application/json; charset=utf-8'},
        // No lanzamos por código: lo gestiona el interceptor de errores.
        validateStatus: (code) => code != null && code < 500,
      ),
    );

    // Decodificador de respuesta EXPLÍCITO: fuerza UTF-8 en los bytes crudos
    // de cada respuesta, sin importar el charset (o su ausencia) que declare
    // el Content-Type del backend. Diagnóstico de la Fase 4 (caracteres
    // "chinos"/mojibake en textos con tildes, ñ y emoji): se verificó que
    // dio 5.11.1 ya decodifica con UTF-8 por defecto (ver
    // package:dio/src/transformers/sync_transformer.dart), así que esto es
    // un refuerzo explícito y defensivo, no una corrección de un bug
    // detectado en el pipeline actual — ver el reporte de la sesión para el
    // detalle de la investigación (no se encontró el bug reportado en el
    // código ni en el backend en vivo).
    dio.options.responseDecoder =
        (List<int> responseBytes, RequestOptions options, dynamic body) {
          return utf8.decode(responseBytes, allowMalformed: true);
        };

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          final token = TokenStorage.instance.token;
          final noAuth = options.extra['noAuth'] == true;
          if (!noAuth && token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          handler.next(options);
        },
        onResponse: (response, handler) {
          final code = response.statusCode ?? 0;
          if (code == 401 || code == 403) {
            final noAuth = response.requestOptions.extra['noAuth'] == true;
            if (!noAuth) _notifySessionInvalid();
            handler.reject(
              DioException(
                requestOptions: response.requestOptions,
                response: response,
                type: DioExceptionType.badResponse,
              ),
            );
            return;
          }
          if (code >= 400) {
            handler.reject(
              DioException(
                requestOptions: response.requestOptions,
                response: response,
                type: DioExceptionType.badResponse,
              ),
            );
            return;
          }
          handler.next(response);
        },
        onError: (e, handler) {
          final code = e.response?.statusCode ?? 0;
          if ((code == 401 || code == 403) &&
              e.requestOptions.extra['noAuth'] != true) {
            _notifySessionInvalid();
          }
          handler.next(e);
        },
      ),
    );

    if (kDebugMode) {
      dio.interceptors.add(
        LogInterceptor(
          request: false,
          requestHeader: false,
          requestBody: true,
          responseHeader: false,
          responseBody: false,
          error: true,
          logPrint: (o) => debugPrint('[Zentry API] $o'),
        ),
      );
    }
  }

  bool _sessionInvalidFired = false;

  void _notifySessionInvalid() {
    if (_sessionInvalidFired) return;
    _sessionInvalidFired = true;
    onSessionInvalid?.call();
    // Se permite volver a disparar tras un breve margen (siguiente sesión).
    Future.delayed(const Duration(seconds: 2), () {
      _sessionInvalidFired = false;
    });
  }

  /// Ejecuta [request] y convierte cualquier fallo en [ApiException].
  Future<T> guard<T>(
    Future<Response<dynamic>> Function() request,
    T Function(dynamic data) parse,
  ) async {
    try {
      final res = await request();
      return parse(res.data);
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(statusCode: 0, message: 'Error inesperado: $e');
    }
  }
}
