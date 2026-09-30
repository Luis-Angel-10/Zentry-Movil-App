import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:Zentry/core/providers/auth_controller.dart';
import 'package:Zentry/core/services/auth_repository.dart';
import 'package:Zentry/features/auth/reset_password_page.dart';
import 'package:Zentry/l10n/generated/app_localizations.dart';

/// Primer paso de "¿Olvidaste tu contraseña?": pide el correo y dispara
/// `POST /api/auth/forgot-password`, que envía un código OTP de 6 dígitos.
///
/// Devuelve `true` (vía `Navigator.pop`) a quien la abrió únicamente cuando
/// el usuario completó todo el flujo y restableció su contraseña con éxito.
class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  String _messageFor(AppLocalizations l10n, AuthFailure f) {
    switch (f) {
      case AuthFailure.userNotFound:
        return l10n.authForgotPasswordUserNotFoundError;
      case AuthFailure.network:
        return l10n.authForgotPasswordNetworkError;
      case AuthFailure.serverError:
        return l10n.authForgotPasswordServerError;
      default:
        return l10n.authForgotPasswordGenericError;
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final l10n = AppLocalizations.of(context)!;
    final auth = context.read<AuthController>();
    if (auth.isLoading) return;

    FocusScope.of(context).unfocus();
    final email = _emailController.text.trim();

    final failure = await auth.forgotPassword(email);
    if (!mounted) return;

    if (failure != null) {
      _snack(_messageFor(l10n, failure), error: true);
      return;
    }

    final resetDone = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => ResetPasswordPage(email: email)),
    );

    if (!mounted) return;
    if (resetDone == true) {
      Navigator.of(context).pop(true);
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
                            Icons.lock_reset_outlined,
                            color: Color(0xFF8B5CF6),
                            size: 56,
                          ),
                          const SizedBox(height: 18),
                          Text(
                            l10n.authForgotPasswordTitle,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            l10n.authForgotPasswordSubtitle,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.white54,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 26),
                          TextFormField(
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            textInputAction: TextInputAction.done,
                            style: const TextStyle(color: Colors.white),
                            onFieldSubmitted: (_) => _submit(),
                            decoration: InputDecoration(
                              hintText: l10n.authForgotPasswordEmailHint,
                              hintStyle: const TextStyle(color: Colors.white38),
                              prefixIcon: const Icon(
                                Icons.alternate_email,
                                color: Colors.white54,
                                size: 20,
                              ),
                              filled: true,
                              fillColor: const Color(0xFF24242C),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 18,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(18),
                                borderSide: BorderSide.none,
                              ),
                              errorStyle: TextStyle(color: Colors.red.shade200),
                              errorBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(18),
                                borderSide: BorderSide(
                                  color: Colors.red.shade300,
                                ),
                              ),
                              focusedErrorBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(18),
                                borderSide: BorderSide(
                                  color: Colors.red.shade300,
                                ),
                              ),
                            ),
                            validator: (value) {
                              final v = value?.trim() ?? '';
                              final emailRegex = RegExp(
                                r'^[^@\s]+@[^@\s]+\.[^@\s]+$',
                              );
                              if (!emailRegex.hasMatch(v)) {
                                return l10n.authForgotPasswordEmailInvalid;
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
                                      l10n.authForgotPasswordSubmitButton,
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
                            onPressed: isLoading
                                ? null
                                : () => Navigator.of(context).maybePop(),
                            child: Text(
                              l10n.authForgotPasswordBackToLogin,
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
