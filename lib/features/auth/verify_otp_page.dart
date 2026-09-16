import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'package:Zentry/core/providers/auth_controller.dart';
import 'package:Zentry/core/services/auth_repository.dart';

/// Verificación por código (OTP) que exige el backend tras el registro.
///
/// El backend imprime el código de 6 dígitos en su consola
/// (`========== EMAIL SIMULADO ==========`) y lo valida en
/// `POST /api/auth/verify-login`.
class VerifyOtpPage extends StatefulWidget {
  const VerifyOtpPage({
    super.key,
    required this.email,
    this.pendingName,
    this.pendingArtistName,
    this.pendingDiscipline,
    this.pendingBio,
  });

  final String email;
  final String? pendingName;
  final String? pendingArtistName;
  final String? pendingDiscipline;
  final String? pendingBio;

  @override
  State<VerifyOtpPage> createState() => _VerifyOtpPageState();
}

class _VerifyOtpPageState extends State<VerifyOtpPage> {
  final _codeController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  int _resendCooldown = 0;
  Timer? _timer;

  @override
  void dispose() {
    _timer?.cancel();
    _codeController.dispose();
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

  String _messageFor(AuthFailure f) {
    switch (f) {
      case AuthFailure.otpInvalid:
        return 'Código incorrecto. Revísalo e inténtalo de nuevo.';
      case AuthFailure.otpExpired:
        return 'El código expiró. Solicita uno nuevo.';
      case AuthFailure.otpTooManyAttempts:
        return 'Demasiados intentos. Solicita un código nuevo.';
      case AuthFailure.userNotFound:
        return 'No encontramos una cuenta con ese correo.';
      case AuthFailure.network:
        return 'Sin conexión con el servidor. Verifica tu red.';
      case AuthFailure.serverError:
        return 'Error del servidor. Inténtalo más tarde.';
      default:
        return 'No se pudo verificar el código.';
    }
  }

  Future<void> _verify() async {
    if (!_formKey.currentState!.validate()) return;
    final auth = context.read<AuthController>();
    if (auth.isLoading) return;

    FocusScope.of(context).unfocus();

    final failure = await auth.verifyOtp(
      email: widget.email,
      code: _codeController.text.trim(),
      pendingName: widget.pendingName,
      pendingArtistName: widget.pendingArtistName,
      pendingDiscipline: widget.pendingDiscipline,
      pendingBio: widget.pendingBio,
    );

    if (!mounted) return;

    if (failure != null) {
      _snack(_messageFor(failure), error: true);
      return;
    }

    // Sesión establecida: se cierra toda la pila de auth y el root muestra Home.
    Navigator.of(context).popUntil((r) => r.isFirst);
  }

  Future<void> _resend() async {
    if (_resendCooldown > 0) return;
    final auth = context.read<AuthController>();
    final failure = await auth.resendOtp(widget.email);
    if (!mounted) return;
    if (failure != null) {
      _snack(_messageFor(failure), error: true);
    } else {
      _snack('Te enviamos un nuevo código.');
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

  @override
  Widget build(BuildContext context) {
    final isLoading = context.watch<AuthController>().isLoading;

    return Scaffold(
      backgroundColor: const Color(0xFF07070D),
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
                        const Text(
                          'Verifica tu correo',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'Escribe el código de 6 dígitos que enviamos a\n${widget.email}',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.white54,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 26),
                        Form(
                          key: _formKey,
                          child: TextFormField(
                            controller: _codeController,
                            keyboardType: TextInputType.number,
                            textAlign: TextAlign.center,
                            maxLength: 6,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 28,
                              letterSpacing: 12,
                              fontWeight: FontWeight.bold,
                            ),
                            decoration: InputDecoration(
                              counterText: '',
                              hintText: '••••••',
                              hintStyle: const TextStyle(
                                color: Colors.white24,
                                letterSpacing: 12,
                              ),
                              filled: true,
                              fillColor: const Color(0xFF24242C),
                              contentPadding: const EdgeInsets.symmetric(
                                vertical: 18,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(18),
                                borderSide: BorderSide.none,
                              ),
                            ),
                            validator: (v) {
                              if ((v ?? '').trim().length != 6) {
                                return 'El código tiene 6 dígitos';
                              }
                              return null;
                            },
                            onFieldSubmitted: (_) => _verify(),
                          ),
                        ),
                        const SizedBox(height: 8),
                        SizedBox(
                          height: 54,
                          child: ElevatedButton(
                            onPressed: isLoading ? null : _verify,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF8B5CF6),
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
                                : const Text(
                                    'Verificar',
                                    style: TextStyle(
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
                                ? 'Reenviar código en $_resendCooldown s'
                                : 'Reenviar código',
                            style: const TextStyle(color: Colors.white70),
                          ),
                        ),
                        TextButton(
                          onPressed: isLoading
                              ? null
                              : () => Navigator.of(context).maybePop(),
                          child: const Text(
                            'Volver',
                            style: TextStyle(color: Colors.white38),
                          ),
                        ),
                      ],
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
