import 'package:Zentry/core/models/backend/wallet_response.dart';
import 'package:Zentry/core/network/api_client.dart';

/// Endpoints de billetera / Zentry Coins (`/api/core/wallet`, alias
/// `/api/v1/wallet`). Todos requieren JWT.
///
/// *** NOTA DE SEGURIDAD (ver reporte de la fase) ***
/// `POST /wallet/topup` (alias `/recharge`) NO tiene ningún control de rol en
/// el backend: cualquier usuario autenticado puede acuñar ZC ilimitados a su
/// propia cuenta. Este método existe aquí sólo por completitud del contrato
/// — **a propósito no se expone ningún botón/UI que lo llame**. No lo uses
/// para una funcionalidad real de usuario sin que el backend agregue control
/// de rol/límite primero.
class WalletApi {
  WalletApi._();
  static final WalletApi instance = WalletApi._();

  ApiClient get _c => ApiClient.instance;

  /// `GET /api/core/wallet` — saldo + historial de movimientos (más reciente
  /// primero).
  Future<WalletResponse> getWallet() {
    return _c.guard(
      () => _c.dio.get('/api/core/wallet'),
      (data) => WalletResponse.fromJson(Map<String, dynamic>.from(data as Map)),
    );
  }

  /// `POST /api/core/wallet/transfer` — body `{recipientUsername, amount}`.
  /// El backend rechaza auto-transferencia, montos <1 ZC y saldo
  /// insuficiente (400 con mensaje real en cada caso).
  Future<WalletResponse> transfer({
    required String recipientUsername,
    required double amount,
  }) {
    return _c.guard(
      () => _c.dio.post(
        '/api/core/wallet/transfer',
        data: {'recipientUsername': recipientUsername, 'amount': amount},
      ),
      (data) => WalletResponse.fromJson(Map<String, dynamic>.from(data as Map)),
    );
  }

  /// `POST /api/core/wallet/subscribe` — body `{planId, cycle}`. El costo se
  /// calcula server-side contra una tabla hardcodeada (`"pro"`/`"vip"` con
  /// ciclo mensual/anual); cualquier otro `planId` cuesta 0 ZC. No tiene
  /// relación con los planes en USD de `subscription_screen.dart`.
  Future<WalletResponse> subscribe({
    required String planId,
    required String cycle,
  }) {
    return _c.guard(
      () => _c.dio.post(
        '/api/core/wallet/subscribe',
        data: {'planId': planId, 'cycle': cycle},
      ),
      (data) => WalletResponse.fromJson(Map<String, dynamic>.from(data as Map)),
    );
  }

  /// `POST /api/core/wallet/topup` — ver advertencia de seguridad en el
  /// doc-comment de la clase. NO USAR desde UI de usuario final.
  Future<WalletResponse> topup({required double amount}) {
    return _c.guard(
      () => _c.dio.post('/api/core/wallet/topup', data: {'amount': amount}),
      (data) => WalletResponse.fromJson(Map<String, dynamic>.from(data as Map)),
    );
  }
}
