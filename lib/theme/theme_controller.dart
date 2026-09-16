import 'package:flutter/material.dart';
import 'theme_preferences.dart';

class ThemeController extends ChangeNotifier {
  ThemeMode themeMode = ThemeMode.dark;

  Color accentColor = Colors.deepPurple;

  double textScale = 1.0;

  bool blur = true;

  bool animations = true;

  bool rounded = true;

  bool heroAnimations = true;

  Future<void> load() async {
    themeMode = await ThemePreferences.loadThemeMode();

    accentColor = await ThemePreferences.loadAccent();

    textScale = await ThemePreferences.loadTextScale();

    blur = await ThemePreferences.loadBlur();

    animations = await ThemePreferences.loadAnimations();

    rounded = await ThemePreferences.loadRounded();

    heroAnimations = await ThemePreferences.loadHero();

    notifyListeners();
  }

  void setTheme(ThemeMode mode) {
    themeMode = mode;

    ThemePreferences.saveThemeMode(mode);

    notifyListeners();
  }

  void setAccent(Color color) {
    accentColor = color;

    ThemePreferences.saveAccent(color);

    notifyListeners();
  }

  void setTextScale(double value) {
    textScale = value;

    ThemePreferences.saveTextScale(value);

    notifyListeners();
  }

  void setBlur(bool value) {
    blur = value;

    ThemePreferences.saveBlur(value);

    notifyListeners();
  }

  void setAnimations(bool value) {
    animations = value;

    ThemePreferences.saveAnimations(value);

    notifyListeners();
  }

  void setRounded(bool value) {
    rounded = value;

    ThemePreferences.saveRounded(value);

    notifyListeners();
  }

  void setHero(bool value) {
    heroAnimations = value;

    ThemePreferences.saveHero(value);

    notifyListeners();
  }
}
