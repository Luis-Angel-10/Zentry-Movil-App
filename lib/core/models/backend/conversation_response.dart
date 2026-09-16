/// Espejo de `ConversationResponse` del backend
/// (realtime/dtos/ConversationResponse.java).
class ConversationResponse {
  const ConversationResponse({
    required this.id,
    this.isGroup = false,
    this.name,
    this.createdBy,
    this.createdAt,
    this.lastMessageAt,
  });

  final int id;
  final bool isGroup;
  final String? name;
  final int? createdBy;
  final DateTime? createdAt;
  final DateTime? lastMessageAt;

  factory ConversationResponse.fromJson(Map<String, dynamic> json) {
    return ConversationResponse(
      id: (json['id'] as num).toInt(),
      isGroup: json['isGroup'] == true,
      name: json['name'] as String?,
      createdBy: (json['createdBy'] as num?)?.toInt(),
      createdAt: _date(json['createdAt']),
      lastMessageAt: _date(json['lastMessageAt']),
    );
  }

  static DateTime? _date(dynamic v) =>
      (v is String && v.isNotEmpty) ? DateTime.tryParse(v) : null;
}

/// Espejo de `ConversationSummaryResponse` del backend — una fila de la
/// bandeja de entrada (`GET /api/realtime/conversations/mine`).
class ConversationSummaryResponse {
  const ConversationSummaryResponse({
    required this.id,
    this.isGroup = false,
    this.name,
    this.otherUserId,
    this.lastMessageContent,
    this.lastMessageSenderId,
    this.lastMessageAt,
    this.unreadCount = 0,
  });

  final int id;
  final bool isGroup;
  final String? name;

  /// Sólo presente en conversaciones directas (no grupales).
  final int? otherUserId;
  final String? lastMessageContent;
  final int? lastMessageSenderId;
  final DateTime? lastMessageAt;
  final int unreadCount;

  factory ConversationSummaryResponse.fromJson(Map<String, dynamic> json) {
    return ConversationSummaryResponse(
      id: (json['id'] as num).toInt(),
      isGroup: json['isGroup'] == true,
      name: json['name'] as String?,
      otherUserId: (json['otherUserId'] as num?)?.toInt(),
      lastMessageContent: json['lastMessageContent'] as String?,
      lastMessageSenderId: (json['lastMessageSenderId'] as num?)?.toInt(),
      lastMessageAt:
          (json['lastMessageAt'] is String &&
              (json['lastMessageAt'] as String).isNotEmpty)
          ? DateTime.tryParse(json['lastMessageAt'] as String)
          : null,
      unreadCount: (json['unreadCount'] as num?)?.toInt() ?? 0,
    );
  }
}
