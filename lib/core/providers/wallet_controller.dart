import 'package:flutter/material.dart';

import 'package:Zentry/core/models/backend/wallet_response.dart';
import 'package:Zentry/core/network/api_exception.dart';
import 'package:Zentry/core/network/wallet_api.dart';

/// Billetera real de Zentry Coins (`GET /api/core/wallet`) — reemplaza al
/// antiguo `EngagementController.zCoins` (un `int` puramente local) como
/// ÚNICA fuente de verdad del saldo mostrado al usuario. Sobrevive cierre de
/// app, reinstalación y cambio de dispositivo porque vive en el backend.
///
/// *** Alcance de esta migración (ver reporte de la fase) ***
/// La Tienda (`store_screen.dart`, compra de colores/mascotas) y los Retos
/// semanales (`challenges_screen.dart`) siguen gastando/otorgando el `zCoins`
/// LOCAL de `EngagementController` — el backend no tiene ningún endpoint
/// para "comprar un color de perfil" o "reclamar un reto semanal", así que
/// conectarlos habría requerido inventar un contrato que no existe. Esos dos
/// flujos quedan documentados como pendientes de un futuro endpoint de
/// backend, no como un descuido.
class WalletController extends ChangeNotifier {
  final WalletApi _api = WalletApi.instance;

  WalletResponse? data;
  bool isLoading = false;
  String? error;

  double get balance => data?.balance ?? 0;
  String get balanceLabel => data?.balanceLabel ?? '—';
  List<WalletTransactionResponse> get transactions =>
      data?.transactions ?? const [];

  Future<void> load() async {
    isLoading = true;
    error = null;
    notifyListeners();
    try {
      data = await _api.getWallet();
    } on ApiException catch (e) {
      error = e.message;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  /// Transfiere ZC a otro usuario. Devuelve `null` si tuvo éxito (y ya
  /// actualizó `data` con el saldo/movimientos reales post-transferencia),
  /// o el mensaje de error real del backend si falló (saldo insuficiente,
  /// auto-transferencia, usuario inexistente, etc.) — nunca se valida sólo
  /// en Flutter, el backend sigue siendo la autoridad.
  Future<String?> transfer({
    required String recipientUsername,
    required double amount,
  }) async {
    if (amount <= 0) return 'El monto debe ser mayor a cero.';

    isLoading = true;
    notifyListeners();
    try {
      data = await _api.transfer(
        recipientUsername: recipientUsername,
        amount: amount,
      );
      return null;
    } on ApiException catch (e) {
      return e.message;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
