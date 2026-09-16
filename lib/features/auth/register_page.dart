import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:Zentry/core/models/zentry_category.dart';
import 'package:Zentry/core/providers/auth_controller.dart';
import 'package:Zentry/core/services/auth_repository.dart';
import 'package:Zentry/features/auth/verify_otp_page.dart';
import 'package:Zentry/l10n/generated/app_localizations.dart';

const int _kMaxRegisterInterests = 5;

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage>
    with SingleTickerProviderStateMixin {
  int currentStep = 0;

  bool obscurePassword = true;

  final GlobalKey<FormState> step1FormKey = GlobalKey<FormState>();

  late AnimationController animationController;

  late Animation<double> fadeAnimation;

  final TextEditingController nombreController = TextEditingController();

  final TextEditingController artistaController = TextEditingController();

  final TextEditingController usernameController = TextEditingController();

  final TextEditingController correoController = TextEditingController();

  final TextEditingController passwordController = TextEditingController();

  final TextEditingController descripcionController = TextEditingController();

  List<String> interesesSeleccionados = [];

  @override
  void initState() {
    super.initState();

    animationController = AnimationController(
      vsync: this,

      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    fadeAnimation = Tween<double>(
      begin: 0.7,
      end: 1,
    ).animate(animationController);
  }

  @override
  void dispose() {
    animationController.dispose();

    nombreController.dispose();

    artistaController.dispose();

    usernameController.dispose();

    correoController.dispose();

    passwordController.dispose();

    descripcionController.dispose();

    super.dispose();
  }

  Future<void> registrar() async {
    final l10n = AppLocalizations.of(context)!;
    final auth = context.read<AuthController>();

    if (auth.isLoading) return;

    final email = correoController.text.trim();

    final failure = await auth.register(
      username: usernameController.text,
      email: email,
      password: passwordController.text,
    );

    if (!mounted) return;

    if (failure != null) {
      final message = switch (failure) {
        AuthFailure.emailTaken => l10n.authRegisterEmailTakenError,
        AuthFailure.usernameTaken => l10n.authRegisterUsernameTakenError,
        AuthFailure.network => 'Sin conexión con el servidor. Verifica tu red.',
        AuthFailure.serverError => 'Error del servidor. Inténtalo más tarde.',
        _ => l10n.commonError,
      };

      _showError(message);

      setState(() {
        currentStep = 0;
      });
      return;
    }

    // El backend aceptó el alta y exige verificación por código (OTP).
    // Los campos extra del formulario se guardan tras verificar, vía
    // PUT /api/core/profiles/me.
    final discipline = interesesSeleccionados.isNotEmpty
        ? interesesSeleccionados.first
        : null;

    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => VerifyOtpPage(
          email: email,
          pendingName: nombreController.text.trim(),
          pendingArtistName: artistaController.text.trim(),
          pendingDiscipline: discipline,
          pendingBio: descripcionController.text.trim(),
        ),
      ),
    );

    if (!mounted) return;
    // Si la verificación tuvo éxito, AuthController ya está logueado y el root
    // muestra Home; esta pila se cierra sola. Si el usuario volvió atrás,
    // simplemente permanece en el registro.
    if (context.read<AuthController>().isLoggedIn) {
      Navigator.of(context).popUntil((r) => r.isFirst);
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

  void siguientePaso() {
    final l10n = AppLocalizations.of(context)!;

    if (currentStep == 0 && !step1FormKey.currentState!.validate()) {
      return;
    }

    if (currentStep == 1 && interesesSeleccionados.isEmpty) {
      _showError(l10n.authRegisterSelectDisciplineError);
      return;
    }

    if (currentStep < 2) {
      setState(() {
        currentStep++;
      });
    } else {
      registrar();
    }
  }

  void regresarPaso() {
    if (currentStep > 0) {
      setState(() {
        currentStep--;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isLoading = context.watch<AuthController>().isLoading;

    return Scaffold(
      resizeToAvoidBottomInset: true,

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
                  constraints: const BoxConstraints(maxWidth: 520),

                  child: Container(
                    padding: const EdgeInsets.all(28),

                    decoration: BoxDecoration(
                      color: const Color(0xFF17171F),

                      borderRadius: BorderRadius.circular(30),

                      border: Border.all(color: Colors.white10),
                    ),

                    child: Column(
                      mainAxisSize: MainAxisSize.min,

                      children: [
                        FadeTransition(
                          opacity: fadeAnimation,

                          child: const Text(
                            "Zentry",

                            style: TextStyle(
                              color: Colors.white,

                              fontSize: 42,

                              fontWeight: FontWeight.bold,

                              letterSpacing: 1.2,
                            ),
                          ),
                        ),

                        const SizedBox(height: 15),

                        Text(
                          l10n.authRegisterHeadline,

                          textAlign: TextAlign.center,

                          style: const TextStyle(
                            color: Colors.white,

                            fontSize: 28,

                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 10),

                        Text(
                          l10n.authRegisterSubheading,

                          textAlign: TextAlign.center,

                          style: const TextStyle(
                            color: Colors.white54,

                            fontSize: 15,
                          ),
                        ),

                        const SizedBox(height: 28),

                        buildIndicadores(),

                        const SizedBox(height: 30),

                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 300),

                          child: currentStep == 0
                              ? buildPasoUno()
                              : currentStep == 1
                              ? buildPasoDos()
                              : buildPasoTres(),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          if (isLoading)
            Container(
              color: Colors.black54,

              child: const Center(
                child: CircularProgressIndicator(color: Color(0xFF8B5CF6)),
              ),
            ),
        ],
      ),
    );
  }

  Widget buildIndicadores() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,

      children: List.generate(3, (index) {
        bool activo = currentStep == index;

        return AnimatedContainer(
          duration: const Duration(milliseconds: 250),

          margin: const EdgeInsets.symmetric(horizontal: 5),

          width: activo ? 32 : 10,

          height: 10,

          decoration: BoxDecoration(
            color: activo ? const Color(0xFF8B5CF6) : Colors.white24,

            borderRadius: BorderRadius.circular(20),
          ),
        );
      }),
    );
  }

  Widget buildPasoUno() {
    final l10n = AppLocalizations.of(context)!;

    return Form(
      key: step1FormKey,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      child: Column(
        key: const ValueKey(1),

        children: [
          buildInput(
            l10n.authRegisterFullNameHint,
            nombreController,
            validator: (value) {
              if ((value ?? '').trim().isEmpty) {
                return l10n.authRegisterFullNameValidationError;
              }
              return null;
            },
          ),

          const SizedBox(height: 18),

          buildInput(l10n.authRegisterArtistNameHint, artistaController),

          const SizedBox(height: 18),

          buildInput(
            l10n.authRegisterUsernameHint,
            usernameController,
            validator: (value) {
              final v = (value ?? '').trim();
              if (v.length < 3 || v.contains(' ')) {
                return l10n.authRegisterUsernameValidationError;
              }
              return null;
            },
          ),

          const SizedBox(height: 18),

          buildInput(
            l10n.authRegisterEmailHint,
            correoController,
            keyboardType: TextInputType.emailAddress,
            validator: (value) {
              final v = (value ?? '').trim();
              final emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
              if (!emailRegex.hasMatch(v)) {
                return l10n.authRegisterEmailValidationError;
              }
              return null;
            },
          ),

          const SizedBox(height: 18),

          TextFormField(
            controller: passwordController,

            obscureText: obscurePassword,

            style: const TextStyle(color: Colors.white),

            decoration: decoracionInput(l10n.authRegisterPasswordHint).copyWith(
              suffixIcon: IconButton(
                icon: Icon(
                  obscurePassword ? Icons.visibility_off : Icons.visibility,

                  color: Colors.white54,
                ),

                onPressed: () {
                  setState(() {
                    obscurePassword = !obscurePassword;
                  });
                },
              ),
            ),

            validator: (value) {
              if ((value ?? '').length < 6) {
                return l10n.authRegisterPasswordValidationError;
              }
              return null;
            },
          ),

          const SizedBox(height: 30),

          buildBoton(l10n.commonContinue, siguientePaso),
        ],
      ),
    );
  }

  Widget buildPasoDos() {
    final l10n = AppLocalizations.of(context)!;

    return Column(
      key: const ValueKey(2),

      crossAxisAlignment: CrossAxisAlignment.start,

      children: [
        Text(
          l10n.authRegisterDisciplineTitle,

          style: const TextStyle(
            color: Colors.white,

            fontSize: 24,

            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 8),

        Text(
          l10n.authRegisterDisciplineSubtitle,

          style: const TextStyle(color: Colors.white54),
        ),

        const SizedBox(height: 6),

        Text(
          l10n.authRegisterInterestsCount(interesesSeleccionados.length),
          style: TextStyle(
            color: interesesSeleccionados.length >= _kMaxRegisterInterests
                ? const Color(0xFFD946EF)
                : Colors.white38,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),

        const SizedBox(height: 18),

        GridView.builder(
          shrinkWrap: true,

          physics: const NeverScrollableScrollPhysics(),

          itemCount: kZentryCategoryGroups.length,

          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,

            mainAxisSpacing: 14,

            crossAxisSpacing: 14,

            childAspectRatio: 2.6,
          ),

          itemBuilder: (_, index) {
            final group = kZentryCategoryGroups[index];

            final selected = interesesSeleccionados.contains(group.name);

            return GestureDetector(
              onTap: () {
                setState(() {
                  if (selected) {
                    interesesSeleccionados.remove(group.name);
                  } else if (interesesSeleccionados.length <
                      _kMaxRegisterInterests) {
                    interesesSeleccionados.add(group.name);
                  } else {
                    _showError(l10n.authRegisterInterestsMaxReached);
                  }
                });
              },

              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),

                padding: const EdgeInsets.symmetric(horizontal: 16),

                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),

                  gradient: selected
                      ? const LinearGradient(
                          colors: [Color(0xFF8B5CF6), Color(0xFFD946EF)],
                        )
                      : null,

                  color: selected ? null : const Color(0xFF24242C),
                ),

                child: Row(
                  children: [
                    Text(group.emoji, style: const TextStyle(fontSize: 22)),

                    const SizedBox(width: 10),

                    Expanded(
                      child: Text(
                        group.name,

                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,

                        style: const TextStyle(
                          color: Colors.white,

                          fontWeight: FontWeight.w500,

                          fontSize: 13,
                        ),
                      ),
                    ),

                    if (selected)
                      const Icon(
                        Icons.check_circle,
                        color: Colors.white,
                        size: 18,
                      ),
                  ],
                ),
              ),
            );
          },
        ),

        const SizedBox(height: 30),

        Row(
          children: [
            Expanded(
              child: buildBotonSecundario(l10n.commonBack, regresarPaso),
            ),

            const SizedBox(width: 14),

            Expanded(child: buildBoton(l10n.commonContinue, siguientePaso)),
          ],
        ),
      ],
    );
  }

  Widget buildPasoTres() {
    final l10n = AppLocalizations.of(context)!;

    return Column(
      key: const ValueKey(3),

      crossAxisAlignment: CrossAxisAlignment.start,

      children: [
        Text(
          l10n.authRegisterAboutTitle,

          style: const TextStyle(
            color: Colors.white,

            fontSize: 24,

            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 8),

        Text(
          l10n.authRegisterAboutSubtitle,

          style: const TextStyle(color: Colors.white54),
        ),

        const SizedBox(height: 24),

        TextField(
          controller: descripcionController,

          maxLines: 6,

          style: const TextStyle(color: Colors.white),

          decoration: decoracionInput(l10n.authRegisterBioHint),
        ),

        const SizedBox(height: 30),

        Row(
          children: [
            Expanded(
              child: buildBotonSecundario(l10n.commonBack, regresarPaso),
            ),

            const SizedBox(width: 14),

            Expanded(
              child: buildBoton(l10n.authRegisterFinishButton, registrar),
            ),
          ],
        ),
      ],
    );
  }

  Widget buildInput(
    String hint,
    TextEditingController controller, {
    String? Function(String?)? validator,
    TextInputType? keyboardType,
  }) {
    return TextFormField(
      controller: controller,

      keyboardType: keyboardType,

      style: const TextStyle(color: Colors.white),

      decoration: decoracionInput(hint),

      validator: validator,
    );
  }

  InputDecoration decoracionInput(String hint) {
    return InputDecoration(
      hintText: hint,

      hintStyle: const TextStyle(color: Colors.white38),

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

  Widget buildBoton(String texto, VoidCallback onTap) {
    return SizedBox(
      height: 56,

      child: ElevatedButton(
        onPressed: onTap,

        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF8B5CF6),

          elevation: 0,

          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),

        child: Text(
          texto,

          style: const TextStyle(
            color: Colors.white,

            fontSize: 16,

            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget buildBotonSecundario(String texto, VoidCallback onTap) {
    return SizedBox(
      height: 56,

      child: OutlinedButton(
        onPressed: onTap,

        style: OutlinedButton.styleFrom(
          side: BorderSide(color: Colors.white10),

          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),

        child: Text(texto, style: const TextStyle(color: Colors.white)),
      ),
    );
  }
}
