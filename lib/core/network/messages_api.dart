import 'package:Zentry/core/models/backend/message_response.dart';
import 'package:Zentry/core/network/api_client.dart';

/// Endpoints de mensajes (`/api/realtime/messages`). Todos requieren JWT.
///
/// Contrato real (`MessageRequest`): sólo `conversationId` + `content` +
/// `type` (String libre, máx. 10 caracteres). No hay soporte de adjuntos
/// (imagen/video/audio/archivo) vía REST — ver BACKEND GAP en el reporte.
class MessagesApi {
  MessagesApi._();
  static final MessagesApi instance = MessagesApi._();

  ApiClient get _c => ApiClient.instance;

  /// `GET /api/realtime/messages?conversationId=&page=&size=` — del más
  /// reciente al más antiguo (orden del backend: `createdAt DESC`).
  Future<List<MessageResponse>> listByConversation(
    int conversationId, {
    int page = 0,
    int size = 30,
  }) {
    return _c.guard(
      () => _c.dio.get(
        '/api/realtime/messages',
        queryParameters: {
          'conversationId': conversationId,
          'page': page,
          'size': size,
        },
      ),
      (data) {
        final content = (data is Map ? data['content'] : null);
        if (content is! List) return const <MessageResponse>[];
        return content
            .whereType<Map>()
            .map((e) => MessageResponse.fromJson(Map<String, dynamic>.from(e)))
            .toList();
      },
    );
  }

  /// `POST /api/realtime/messages` — body `{conversationId, content, type}`.
  Future<MessageResponse> send({
    required int conversationId,
    required String content,
    String type = 'text',
  }) {
    return _c.guard(
      () => _c.dio.post(
        '/api/realtime/messages',
        data: {
          'conversationId': conversationId,
          'content': content,
          'type': type,
        },
      ),
      (data) => MessageResponse.fromJson(
        data is Map ? Map<String, dynamic>.from(data) : <String, dynamic>{},
      ),
    );
  }

  /// `DELETE /api/realtime/messages/{id}` — sólo el autor puede borrar.
  Future<void> delete(int id) {
    return _c.guard(() => _c.dio.delete('/api/realtime/messages/$id'), (_) {});
  }
}
