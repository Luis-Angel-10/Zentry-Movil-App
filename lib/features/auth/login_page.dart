import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:Zentry/core/providers/auth_controller.dart';
import 'package:Zentry/core/services/auth_repository.dart';
import 'package:Zentry/features/auth/verify_otp_page.dart';
import 'package:Zentry/l10n/generated/app_localizations.dart';
import 'package:Zentry/theme/theme_controller.dart';
import 'register_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool obscurePassword = true;
  bool _showPasswordForm = false;
  bool _biometricAttempted = false;

  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  late AnimationController _pulseController;
  late Animation<double> _fingerprintPulse;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _fadeAnimation = Tween<double>(begin: 0.6, end: 1).animate(_controller);

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    )..repeat(reverse: true);

    _fingerprintPulse = Tween<double>(begin: 1.0, end: 1.12).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) => _maybeAutoPrompt());
  }

  @override
  void dispose() {
    _controller.dispose();
    _pulseController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  bool _canUseBiometrics(AuthController auth) =>
      auth.biometricEnabled && auth.biometricUserId != null;

  void _maybeAutoPrompt() {
    final auth = context.read<AuthController>();
    if (_biometricAttempted || _showPasswordForm) return;
    if (!_canUseBiometrics(auth)) return;
    _biometricAttempted = true;
    _submitBiometric();
  }

  Future<void> _submitBiometric() async {
    final l10n = AppLocalizations.of(context)!;
    final auth = context.read<AuthController>();

    if (auth.isLoading) return;

    final failure = await auth.loginWithBiometrics();
    if (!mounted) return;

    if (failure == AuthFailure.biometricUnavailable) {
      setState(() => _showPasswordForm = true);
    } else if (failure == AuthFailure.biometricFailed) {
      _showError(l10n.authLoginBiometricFailedError);
    }
  }

  Future<void> _submit() async {
    final l10n = AppLocalizations.of(context)!;
    final auth = context.read<AuthController>();

    if (auth.isLoading) return;
    if (!_formKey.currentState!.validate()) return;

    FocusScope.of(context).unfocus();

    final email = _emailController.text.trim();
    final failure = await auth.login(
      email: email,
      password: _passwordController.text,
    );

    if (!mounted) return;
    if (failure == null) return; // sesión iniciada; el root cambia a Home

    switch (failure) {
      case AuthFailure.invalidCredentials:
        _showError(l10n.authLoginInvalidCredentialsError);
      case AuthFailure.userNotFound:
        _showError('No existe una cuenta con ese correo.');
      case AuthFailure.needsVerification:
        _showError('Tu cuenta aún no está verificada. Revisa tu correo.');
        Navigator.of(
          context,
        ).push(MaterialPageRoute(builder: (_) => VerifyOtpPage(email: email)));
      case AuthFailure.network:
        _showError('Sin conexión con el servidor. Verifica tu red.');
      case AuthFailure.serverError:
        _showError('Error del servidor. Inténtalo más tarde.');
      default:
        _showError(l10n.commonError);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red.shade400,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.green.shade600,
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
    final accentColor = context.watch<ThemeController>().accentColor;
    final auth = context.watch<AuthController>();
    final isLoading = auth.isLoading;

    final showBiometricScreen = _canUseBiometrics(auth) && !_showPasswordForm;

    if (auth.sessionExpired) {
      auth.acknowledgeSessionExpired();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _showError('Tu sesión expiró. Inicia sesión de nuevo.');
        }
      });
    }

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF0F0F1A), Color(0xFF1A1A2E)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),

          SafeArea(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30),
                child: showBiometricScreen
                    ? _biometricSection(l10n, accentColor, auth, isLoading)
                    : Form(
                        key: _formKey,
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        child: _passwordSection(
                          l10n,
                          accentColor,
                          auth,
                          isLoading,
                        ),
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _biometricSection(
    AppLocalizations l10n,
    Color accentColor,
    AuthController auth,
    bool isLoading,
  ) {
    final name =
        auth.biometricUser?.artistName ?? auth.biometricUser?.fullName ?? '';

    return Column(
      children: [
        const SizedBox(height: 90),

        FadeTransition(
          opacity: _fadeAnimation,
          child: Image.asset("assets/inicio.png", height: 200),
        ),

        const SizedBox(height: 16),

        Text(
          l10n.authLoginWelcomeTitle,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),

        if (name.isNotEmpty) ...[
          const SizedBox(height: 6),
          Text(
            name,
            style: TextStyle(color: Colors.grey.shade400, fontSize: 15),
          ),
        ],

        const SizedBox(height: 46),

        GestureDetector(
          onTap: isLoading ? null : _submitBiometric,
          child: ScaleTransition(
            scale: _fingerprintPulse,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    accentColor.withOpacity(0.35),
                    accentColor.withOpacity(0.05),
                  ],
                ),
                border: Border.all(
                  color: accentColor.withOpacity(0.6),
                  width: 2,
                ),
              ),
              child: isLoading
                  ? const Padding(
                      padding: EdgeInsets.all(40),
                      child: CircularProgressIndicator(
                        strokeWidth: 2.4,
                        color: Colors.white,
                      ),
                    )
                  : Icon(Icons.fingerprint, color: accentColor, size: 64),
            ),
          ),
        ),

        const SizedBox(height: 24),

        Text(
          l10n.authLoginBiometricPrompt,
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.grey.shade400, fontSize: 13.5),
        ),

        const SizedBox(height: 28),

        SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton.icon(
            onPressed: isLoading ? null : _submitBiometric,
            style: ElevatedButton.styleFrom(
              backgroundColor: accentColor,
              disabledBackgroundColor: accentColor.withOpacity(.6),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            icon: const Icon(Icons.fingerprint, color: Colors.white),
            label: Text(
              l10n.authLoginUseBiometricButton,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),

        const SizedBox(height: 14),

        TextButton(
          onPressed: isLoading
              ? null
              : () => setState(() => _showPasswordForm = true),
          child: Text(
            l10n.authLoginUsePasswordButton,
            style: const TextStyle(color: Colors.white70),
          ),
        ),

        const SizedBox(height: 30),
      ],
    );
  }

  Widget _passwordSection(
    AppLocalizations l10n,
    Color accentColor,
    AuthController auth,
    bool isLoading,
  ) {
    return Column(
      children: [
        const SizedBox(height: 70),

        FadeTransition(
          opacity: _fadeAnimation,
          child: Image.asset("assets/inicio.png", height: 220),
        ),

        const SizedBox(height: 10),

        Text(
          l10n.authLoginWelcomeTitle,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 32),

        Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(.05),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.white10),
          ),
          child: Column(
            children: [
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                style: const TextStyle(color: Colors.white),
                decoration: _fieldDecoration(
                  hint: l10n.authLoginEmailHint,
                  icon: Icons.alternate_email,
                ),
                validator: (value) {
                  final v = value?.trim() ?? '';
                  final emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
                  if (!emailRegex.hasMatch(v)) {
                    return l10n.authLoginEmailValidationError;
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              TextFormField(
                controller: _passwordController,
                obscureText: obscurePassword,
                textInputAction: TextInputAction.done,
                style: const TextStyle(color: Colors.white),
                onFieldSubmitted: (_) => _submit(),
                decoration: _fieldDecoration(
                  hint: l10n.authLoginPasswordHint,
                  icon: Icons.lock_outline,
                  suffixIcon: IconButton(
                    icon: Icon(
                      obscurePassword ? Icons.visibility_off : Icons.visibility,
                      color: Colors.white70,
                    ),
                    onPressed: () {
                      setState(() {
                        obscurePassword = !obscurePassword;
                      });
                    },
                  ),
                ),
                validator: (value) {
                  if ((value ?? '').isEmpty) {
                    return l10n.authLoginPasswordValidationError;
                  }
                  return null;
                },
              ),
            ],
          ),
        ),

        const SizedBox(height: 26),

        SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            onPressed: isLoading ? null : _submit,
            style: ElevatedButton.styleFrom(
              backgroundColor: accentColor,
              disabledBackgroundColor: accentColor.withOpacity(.6),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
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
                    l10n.authLoginSubmitButton,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
          ),
        ),

        if (_canUseBiometrics(auth)) ...[
          const SizedBox(height: 14),
          TextButton.icon(
            onPressed: isLoading
                ? null
                : () => setState(() => _showPasswordForm = false),
            icon: Icon(Icons.fingerprint, color: accentColor, size: 20),
            label: Text(
              l10n.authLoginUseBiometricButton,
              style: TextStyle(color: accentColor),
            ),
          ),
        ],

        const SizedBox(height: 18),

        TextButton(
          onPressed: isLoading
              ? null
              : () async {
                  final registeredEmail = await Navigator.push<String>(
                    context,
                    MaterialPageRoute(builder: (_) => const RegisterPage()),
                  );

                  if (!mounted || registeredEmail == null) return;

                  _emailController.text = registeredEmail;
                  _showSuccess(l10n.authRegisterSuccessMessage);
                },
          child: Text(
            l10n.authLoginNoAccountText,
            style: const TextStyle(color: Colors.white70),
          ),
        ),

        const SizedBox(height: 30),
      ],
    );
  }

  InputDecoration _fieldDecoration({
    required String hint,
    required IconData icon,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Colors.white54),
      prefixIcon: Icon(icon, color: Colors.white54, size: 20),
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: Colors.white10,
      errorStyle: TextStyle(color: Colors.red.shade200),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.red.shade300),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.red.shade300),
      ),
    );
  }
}
