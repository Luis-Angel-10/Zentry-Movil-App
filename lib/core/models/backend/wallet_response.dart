/// Espejo de `TransactionType` del backend (`core/models/TransactionType.java`).
/// Sólo existen estos 3 valores — las transferencias reutilizan
/// INGRESO/EGRESO, no hay un tipo dedicado "transferencia".
enum WalletTransactionType { ingreso, egreso, recarga, unknown }

WalletTransactionType _parseTransactionType(dynamic v) {
  switch ((v as String?)?.toUpperCase()) {
    case 'INGRESO':
      return WalletTransactionType.ingreso;
    case 'EGRESO':
      return WalletTransactionType.egreso;
    case 'RECARGA':
      return WalletTransactionType.recarga;
    default:
      return WalletTransactionType.unknown;
  }
}

/// Espejo de `WalletTransactionResponse` (core/dtos).
class WalletTransactionResponse {
  const WalletTransactionResponse({
    required this.id,
    required this.username,
    required this.type,
    required this.amount,
    this.description,
    this.createdAt,
  });

  final int id;
  final String username;
  final WalletTransactionType type;
  final double amount;
  final String? description;
  final DateTime? createdAt;

  factory WalletTransactionResponse.fromJson(Map<String, dynamic> json) {
    return WalletTransactionResponse(
      id: (json['id'] as num?)?.toInt() ?? 0,
      username: (json['username'] as String?) ?? '',
      type: _parseTransactionType(json['type']),
      amount: (json['amount'] as num?)?.toDouble() ?? 0,
      description: json['description'] as String?,
      createdAt: json['createdAt'] is String
          ? DateTime.tryParse(json['createdAt'] as String)
          : null,
    );
  }
}

/// Espejo de `WalletResponse` (core/dtos). `activePlanId` es un string libre
/// persistido por `POST /wallet/subscribe` sin catálogo real detrás — puede
/// venir null si el usuario nunca se ha "suscrito" con ZC.
class WalletResponse {
  const WalletResponse({
    required this.id,
    required this.username,
    required this.balance,
    this.activePlanId,
    this.nextBillingDate,
    this.transactions = const [],
  });

  final int id;
  final String username;
  final double balance;
  final String? activePlanId;
  final DateTime? nextBillingDate;
  final List<WalletTransactionResponse> transactions;

  factory WalletResponse.fromJson(Map<String, dynamic> json) {
    final rawTx = json['transactions'];
    return WalletResponse(
      id: (json['id'] as num?)?.toInt() ?? 0,
      username: (json['username'] as String?) ?? '',
      balance: (json['balance'] as num?)?.toDouble() ?? 0,
      activePlanId: json['activePlanId'] as String?,
      nextBillingDate: json['nextBillingDate'] is String
          ? DateTime.tryParse(json['nextBillingDate'] as String)
          : null,
      transactions: rawTx is List
          ? rawTx
                .whereType<Map>()
                .map(
                  (e) => WalletTransactionResponse.fromJson(
                    Map<String, dynamic>.from(e),
                  ),
                )
                .toList()
          : const [],
    );
  }

  /// Saldo formateado sin decimales cuando es un entero exacto (caso normal
  /// de Zentry Coins), con hasta 2 decimales si no lo es.
  String get balanceLabel {
    if (balance == balance.roundToDouble()) return balance.toInt().toString();
    return balance.toStringAsFixed(2);
  }
}
