import 'package:Zentry/core/models/backend/conversation_response.dart';
import 'package:Zentry/core/network/api_client.dart';

/// Endpoints de conversaciones (`/api/realtime/conversations`). Todos
/// requieren JWT.
class ConversationsApi {
  ConversationsApi._();
  static final ConversationsApi instance = ConversationsApi._();

  ApiClient get _c => ApiClient.instance;

  /// `GET /api/realtime/conversations/mine?page=&size=` — bandeja de entrada.
  Future<List<ConversationSummaryResponse>> listMine({
    int page = 0,
    int size = 20,
  }) {
    return _c.guard(
      () => _c.dio.get(
        '/api/realtime/conversations/mine',
        queryParameters: {'page': page, 'size': size},
      ),
      (data) {
        final content = (data is Map ? data['content'] : null);
        if (content is! List) return const <ConversationSummaryResponse>[];
        return content
            .whereType<Map>()
            .map(
              (e) => ConversationSummaryResponse.fromJson(
                Map<String, dynamic>.from(e),
              ),
            )
            .toList();
      },
    );
  }

  /// `GET /api/realtime/conversations/{id}`.
  Future<ConversationResponse> getById(int id) {
    return _c.guard(
      () => _c.dio.get('/api/realtime/conversations/$id'),
      (data) => ConversationResponse.fromJson(
        data is Map ? Map<String, dynamic>.from(data) : <String, dynamic>{},
      ),
    );
  }

  /// `POST /api/realtime/conversations/direct/{otherUserId}` — obtiene o crea
  /// la conversación 1 a 1 con ese usuario.
  Future<ConversationResponse> startDirect(int otherUserId) {
    return _c.guard(
      () => _c.dio.post('/api/realtime/conversations/direct/$otherUserId'),
      (data) => ConversationResponse.fromJson(
        data is Map ? Map<String, dynamic>.from(data) : <String, dynamic>{},
      ),
    );
  }

  /// `POST /api/realtime/conversations/{id}/read` — marca como leída.
  Future<void> markRead(int id) {
    return _c.guard(
      () => _c.dio.post('/api/realtime/conversations/$id/read'),
      (_) {},
    );
  }
}
