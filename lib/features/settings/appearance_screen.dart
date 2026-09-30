import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:Zentry/l10n/generated/app_localizations.dart';
import 'package:Zentry/theme/theme_controller.dart';

/// Apariencia simplificada (Fase 3B): Zentry sólo ofrece Claro/Oscuro/
/// Sistema. El color de marca (morado Zentry) ya no es elegible por el
/// usuario — sigue siendo el mismo en todos los componentes, sólo que ya
/// no hay un selector para cambiarlo. Se retiraron de esta pantalla:
/// selector de color de acento, escala de texto, blur, animaciones,
/// esquinas redondeadas y animaciones "hero" — ninguna de esas
/// preferencias se borró de `ThemeController`/`SharedPreferences` (por si
/// algo más las sigue leyendo con su valor por defecto), simplemente ya no
/// son ajustables desde la UI.
class AppearanceScreen extends StatelessWidget {
  const AppearanceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<ThemeController>();
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          l10n.appearanceScreenTitle,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          Text(
            l10n.appearanceHeading,
            style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(l10n.appearanceSubtitle),
          const SizedBox(height: 24),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.appearanceThemeCardTitle,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 8),
                  RadioListTile<ThemeMode>(
                    value: ThemeMode.light,
                    groupValue: controller.themeMode,
                    activeColor: controller.accentColor,
                    onChanged: (_) => controller.setTheme(ThemeMode.light),
                    title: Text(l10n.appearanceThemeLight),
                    secondary: const Icon(Icons.light_mode_outlined),
                  ),
                  RadioListTile<ThemeMode>(
                    value: ThemeMode.dark,
                    groupValue: controller.themeMode,
                    activeColor: controller.accentColor,
                    onChanged: (_) => controller.setTheme(ThemeMode.dark),
                    title: Text(l10n.appearanceThemeDark),
                    secondary: const Icon(Icons.dark_mode_outlined),
                  ),
                  RadioListTile<ThemeMode>(
                    value: ThemeMode.system,
                    groupValue: controller.themeMode,
                    activeColor: controller.accentColor,
                    onChanged: (_) => controller.setTheme(ThemeMode.system),
                    title: Text(l10n.appearanceThemeSystem),
                    secondary: const Icon(Icons.settings_suggest_outlined),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
