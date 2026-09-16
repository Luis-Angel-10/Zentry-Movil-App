/// Espejo de `MessageResponse` del backend (realtime/dtos/MessageResponse.java).
///
/// Contrato real (`MessageRequest`/`MessageResponse`): sólo texto.
/// `type` es un String libre de máx. 10 caracteres (por convención "text");
/// el backend NO tiene un campo de adjunto/archivo en mensajes todavía
/// (ver BACKEND GAP en el reporte de la sesión).
class MessageResponse {
  const MessageResponse({
    required this.id,
    required this.conversationId,
    required this.senderId,
    this.content,
    this.type,
    this.read = false,
    this.createdAt,
  });

  final int id;
  final int conversationId;
  final int senderId;
  final String? content;
  final String? type;
  final bool read;
  final DateTime? createdAt;

  factory MessageResponse.fromJson(Map<String, dynamic> json) {
    return MessageResponse(
      id: (json['id'] as num).toInt(),
      conversationId: (json['conversationId'] as num).toInt(),
      senderId: (json['senderId'] as num).toInt(),
      content: json['content'] as String?,
      type: json['type'] as String?,
      read: json['read'] == true,
      createdAt:
          (json['createdAt'] is String &&
              (json['createdAt'] as String).isNotEmpty)
          ? DateTime.tryParse(json['createdAt'] as String)
          : null,
    );
  }
}
