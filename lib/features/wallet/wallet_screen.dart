import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:Zentry/core/models/backend/wallet_response.dart';
import 'package:Zentry/core/providers/wallet_controller.dart';
import 'package:Zentry/l10n/generated/app_localizations.dart';

/// Billetera real de Zentry Coins — saldo y movimientos vienen SIEMPRE del
/// backend (`GET /api/core/wallet`), nunca de un contador local. Sobrevive
/// cierre de app, reinstalación y cambio de dispositivo.
class WalletScreen extends StatefulWidget {
  const WalletScreen({super.key});

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<WalletController>().load();
    });
  }

  Future<void> _openTransferSheet() async {
    final l10n = AppLocalizations.of(context)!;
    final recipientController = TextEditingController();
    final amountController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    final result = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF17171F),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) {
        return Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(sheetContext).viewInsets.bottom + 20,
          ),
          child: StatefulBuilder(
            builder: (context, setSheetState) {
              final wallet = context.watch<WalletController>();
              return Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      l10n.walletTransferDialogTitle,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 18),
                    TextFormField(
                      controller: recipientController,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: l10n.walletTransferRecipientHint,
                        hintStyle: const TextStyle(color: Colors.white38),
                        filled: true,
                        fillColor: const Color(0xFF24242C),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      validator: (v) => (v ?? '').trim().isEmpty
                          ? l10n.walletTransferRecipientRequired
                          : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: amountController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: l10n.walletTransferAmountHint,
                        hintStyle: const TextStyle(color: Colors.white38),
                        filled: true,
                        fillColor: const Color(0xFF24242C),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      validator: (v) {
                        final amount = double.tryParse(v ?? '');
                        if (amount == null || amount <= 0) {
                          return l10n.walletTransferAmountInvalid;
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 18),
                    SizedBox(
                      height: 50,
                      child: ElevatedButton(
                        onPressed: wallet.isLoading
                            ? null
                            : () async {
                                if (!formKey.currentState!.validate()) return;
                                final amount = double.parse(
                                  amountController.text.trim(),
                                );
                                final error = await context
                                    .read<WalletController>()
                                    .transfer(
                                      recipientUsername: recipientController
                                          .text
                                          .trim(),
                                      amount: amount,
                                    );
                                if (!sheetContext.mounted) return;
                                if (error != null) {
                                  setSheetState(() {});
                                  ScaffoldMessenger.of(
                                    sheetContext,
                                  ).showSnackBar(
                                    SnackBar(
                                      content: Text(error),
                                      backgroundColor: Colors.red.shade400,
                                    ),
                                  );
                                  return;
                                }
                                Navigator.of(sheetContext).pop(true);
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF8B5CF6),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: wallet.isLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.2,
                                  color: Colors.white,
                                ),
                              )
                            : Text(
                                l10n.walletTransferSubmitButton,
                                style: const TextStyle(color: Colors.white),
                              ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );

    if (result == true && mounted) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(l10n.walletTransferSuccessMessage),
            backgroundColor: Colors.green.shade600,
          ),
        );
    }
  }

  String _typeLabel(AppLocalizations l10n, WalletTransactionType type) {
    switch (type) {
      case WalletTransactionType.ingreso:
        return l10n.walletTxIngreso;
      case WalletTransactionType.egreso:
        return l10n.walletTxEgreso;
      case WalletTransactionType.recarga:
        return l10n.walletTxRecarga;
      case WalletTransactionType.unknown:
        return '—';
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final wallet = context.watch<WalletController>();

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.walletScreenTitle),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openTransferSheet,
        backgroundColor: const Color(0xFF8B5CF6),
        icon: const Icon(Icons.send_outlined, color: Colors.white),
        label: Text(
          l10n.walletTransferButton,
          style: const TextStyle(color: Colors.white),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () => context.read<WalletController>().load(),
        child: _buildBody(l10n, wallet),
      ),
    );
  }

  Widget _buildBody(AppLocalizations l10n, WalletController wallet) {
    if (wallet.isLoading && wallet.data == null) {
      return const Center(child: CircularProgressIndicator());
    }
    if (wallet.error != null && wallet.data == null) {
      return ListView(
        children: [
          const SizedBox(height: 120),
          Icon(Icons.error_outline, color: Colors.grey.shade600, size: 48),
          const SizedBox(height: 12),
          Center(
            child: Text(
              wallet.error ?? l10n.walletErrorGeneric,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade400),
            ),
          ),
          const SizedBox(height: 16),
          Center(
            child: OutlinedButton(
              onPressed: () => context.read<WalletController>().load(),
              child: Text(l10n.commonRetry),
            ),
          ),
        ],
      );
    }

    final transactions = wallet.transactions;

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
      children: [
        Container(
          padding: const EdgeInsets.symmetric(vertical: 32),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            gradient: const LinearGradient(
              colors: [Color(0xFFF59E0B), Color(0xFFFBBF24)],
            ),
          ),
          child: Column(
            children: [
              const Icon(Icons.monetization_on, color: Colors.white, size: 56),
              const SizedBox(height: 10),
              Text(
                wallet.balanceLabel,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 34,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                l10n.walletBalanceLabel,
                style: const TextStyle(
                  color: Colors.white70,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        Text(
          l10n.walletTransactionsTitle,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 12),
        if (transactions.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 40),
            child: Center(
              child: Text(
                l10n.walletEmptyTransactions,
                style: TextStyle(color: Colors.grey.shade500),
              ),
            ),
          )
        else
          ...transactions.map((tx) {
            final isPositive =
                tx.type == WalletTransactionType.ingreso ||
                tx.type == WalletTransactionType.recarga;
            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFF171725),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: (isPositive ? Colors.green : Colors.red)
                        .withValues(alpha: .15),
                    child: Icon(
                      isPositive ? Icons.arrow_downward : Icons.arrow_upward,
                      color: isPositive ? Colors.greenAccent : Colors.redAccent,
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          tx.description?.isNotEmpty == true
                              ? tx.description!
                              : _typeLabel(l10n, tx.type),
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        if (tx.createdAt != null)
                          Text(
                            '${tx.createdAt!.day}/${tx.createdAt!.month}/${tx.createdAt!.year}',
                            style: TextStyle(
                              color: Colors.grey.shade500,
                              fontSize: 12,
                            ),
                          ),
                      ],
                    ),
                  ),
                  Text(
                    '${isPositive ? '+' : '-'}${tx.amount.toStringAsFixed(tx.amount == tx.amount.roundToDouble() ? 0 : 2)}',
                    style: TextStyle(
                      color: isPositive ? Colors.greenAccent : Colors.redAccent,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            );
          }),
      ],
    );
  }
}
