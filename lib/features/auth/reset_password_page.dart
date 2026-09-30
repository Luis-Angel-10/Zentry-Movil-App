import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'package:Zentry/core/providers/auth_controller.dart';
import 'package:Zentry/core/services/auth_repository.dart';
import 'package:Zentry/l10n/generated/app_localizations.dart';

/// Segundo paso de "¿Olvidaste tu contraseña?": el usuario introduce el
/// código OTP recibido por correo y su nueva contraseña.
///
/// Llama a `POST /api/auth/reset-password` (verifica el código y cambia la
/// contraseña en la misma llamada; el backend no expone un endpoint
/// separado de "verificar código"). No inicia sesión: al terminar, el
/// usuario vuelve a Login para autenticarse con la contraseña nueva.
class ResetPasswordPage extends StatefulWidget {
  const ResetPasswordPage({super.key, required this.email});

  final String email;

  @override
  State<ResetPasswordPage> createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _codeController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  int _resendCooldown = 0;
  Timer? _timer;

  @override
  void dispose() {
    _timer?.cancel();
    _codeController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  void _startCooldown() {
    setState(() => _resendCooldown = 30);
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) return;
      setState(() => _resendCooldown--);
      if (_resendCooldown <= 0) t.cancel();
    });
  }

  String _messageFor(AppLocalizations l10n, AuthFailure f) {
    switch (f) {
      case AuthFailure.otpInvalid:
        return l10n.authResetPasswordCodeInvalidError;
      case AuthFailure.otpExpired:
        return l10n.authResetPasswordCodeExpiredError;
      case AuthFailure.otpTooManyAttempts:
        return l10n.authResetPasswordTooManyAttemptsError;
      case AuthFailure.weakPassword:
        return l10n.authResetPasswordWeakPasswordError;
      case AuthFailure.userNotFound:
        return l10n.authResetPasswordNoPendingCodeError;
      case AuthFailure.network:
        return l10n.authResetPasswordNetworkError;
      case AuthFailure.serverError:
        return l10n.authResetPasswordServerError;
      default:
        return l10n.authResetPasswordGenericError;
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final l10n = AppLocalizations.of(context)!;
    final auth = context.read<AuthController>();
    if (auth.isLoading) return;

    FocusScope.of(context).unfocus();

    final failure = await auth.resetPassword(
      email: widget.email,
      code: _codeController.text.trim(),
      newPassword: _passwordController.text,
    );

    if (!mounted) return;

    if (failure != null) {
      _snack(_messageFor(l10n, failure), error: true);
      return;
    }

    _snack(l10n.authResetPasswordSuccessMessage);
    await Future.delayed(const Duration(milliseconds: 600));
    if (!mounted) return;
    Navigator.of(context).pop(true);
  }

  Future<void> _resend() async {
    if (_resendCooldown > 0) return;
    final l10n = AppLocalizations.of(context)!;
    final auth = context.read<AuthController>();
    if (auth.isLoading) return;

    final failure = await auth.forgotPassword(widget.email);
    if (!mounted) return;
    if (failure != null) {
      _snack(_messageFor(l10n, failure), error: true);
    } else {
      _snack(l10n.authResetPasswordResentMessage);
      _startCooldown();
    }
  }

  void _snack(String msg, {bool error = false}) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(msg),
          backgroundColor: error ? Colors.red.shade400 : Colors.green.shade600,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
  }

  InputDecoration _fieldDecoration({
    required String hint,
    required IconData icon,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Colors.white38),
      prefixIcon: Icon(icon, color: Colors.white54, size: 20),
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: const Color(0xFF24242C),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: BorderSide.none,
      ),
      errorStyle: TextStyle(color: Colors.red.shade200),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: BorderSide(color: Colors.red.shade300),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: BorderSide(color: Colors.red.shade300),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isLoading = context.watch<AuthController>().isLoading;

    return Scaffold(
      backgroundColor: const Color(0xFF07070D),
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFF1A1030), Color(0xFF07070D)],
              ),
            ),
          ),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 460),
                  child: Container(
                    padding: const EdgeInsets.all(28),
                    decoration: BoxDecoration(
                      color: const Color(0xFF17171F),
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(color: Colors.white10),
                    ),
                    child: Form(
                      key: _formKey,
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const Icon(
                            Icons.mark_email_read_outlined,
                            color: Color(0xFF8B5CF6),
                            size: 56,
                          ),
                          const SizedBox(height: 18),
                          Text(
                            l10n.authResetPasswordTitle,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            l10n.authResetPasswordSubtitle(widget.email),
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.white54,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 26),
                          TextFormField(
                            controller: _codeController,
                            keyboardType: TextInputType.number,
                            textAlign: TextAlign.center,
                            maxLength: 6,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 26,
                              letterSpacing: 10,
                              fontWeight: FontWeight.bold,
                            ),
                            decoration: InputDecoration(
                              counterText: '',
                              hintText: '••••••',
                              hintStyle: const TextStyle(
                                color: Colors.white24,
                                letterSpacing: 10,
                              ),
                              filled: true,
                              fillColor: const Color(0xFF24242C),
                              contentPadding: const EdgeInsets.symmetric(
                                vertical: 16,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(18),
                                borderSide: BorderSide.none,
                              ),
                            ),
                            validator: (v) {
                              if ((v ?? '').trim().length != 6) {
                                return l10n.authResetPasswordCodeLengthError;
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _passwordController,
                            obscureText: _obscurePassword,
                            textInputAction: TextInputAction.next,
                            style: const TextStyle(color: Colors.white),
                            decoration: _fieldDecoration(
                              hint: l10n.authResetPasswordNewPasswordHint,
                              icon: Icons.lock_outline,
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscurePassword
                                      ? Icons.visibility_off
                                      : Icons.visibility,
                                  color: Colors.white54,
                                ),
                                onPressed: () => setState(
                                  () => _obscurePassword = !_obscurePassword,
                                ),
                              ),
                            ),
                            validator: (value) {
                              if ((value ?? '').length < 6) {
                                return l10n.authResetPasswordMinLengthError;
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _confirmController,
                            obscureText: _obscureConfirm,
                            textInputAction: TextInputAction.done,
                            style: const TextStyle(color: Colors.white),
                            onFieldSubmitted: (_) => _submit(),
                            decoration: _fieldDecoration(
                              hint: l10n.authResetPasswordConfirmHint,
                              icon: Icons.lock_outline,
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscureConfirm
                                      ? Icons.visibility_off
                                      : Icons.visibility,
                                  color: Colors.white54,
                                ),
                                onPressed: () => setState(
                                  () => _obscureConfirm = !_obscureConfirm,
                                ),
                              ),
                            ),
                            validator: (value) {
                              if (value != _passwordController.text) {
                                return l10n.authResetPasswordMismatchError;
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 24),
                          SizedBox(
                            height: 54,
                            child: ElevatedButton(
                              onPressed: isLoading ? null : _submit,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF8B5CF6),
                                disabledBackgroundColor: const Color(
                                  0xFF8B5CF6,
                                ).withValues(alpha: .6),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                              child: isLoading
                                  ? const SizedBox(
                                      height: 22,
                                      width: 22,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2.4,
                                        color: Colors.white,
                                      ),
                                    )
                                  : Text(
                                      l10n.authResetPasswordSubmitButton,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                            ),
                          ),
                          const SizedBox(height: 6),
                          TextButton(
                            onPressed: (_resendCooldown > 0 || isLoading)
                                ? null
                                : _resend,
                            child: Text(
                              _resendCooldown > 0
                                  ? l10n.authResetPasswordResendCooldown(
                                      _resendCooldown,
                                    )
                                  : l10n.authResetPasswordResendButton,
                              style: const TextStyle(color: Colors.white70),
                            ),
                          ),
                          TextButton(
                            onPressed: isLoading
                                ? null
                                : () => Navigator.of(context).maybePop(),
                            child: Text(
                              l10n.authResetPasswordBackButton,
                              style: const TextStyle(color: Colors.white38),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
