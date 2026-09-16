import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemePreferences {
  static const String _themeModeKey = 'theme_mode';
  static const String _accentKey = 'accent_color';
  static const String _textScaleKey = 'text_scale';
  static const String _blurKey = 'blur';
  static const String _animationsKey = 'animations';
  static const String _roundedKey = 'rounded';
  static const String _heroKey = 'hero_animations';

  static Future<ThemeMode> loadThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    final index = prefs.getInt(_themeModeKey) ?? ThemeMode.dark.index;
    return ThemeMode.values[index];
  }

  static Future<void> saveThemeMode(ThemeMode mode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_themeModeKey, mode.index);
  }

  static Future<Color> loadAccent() async {
    final prefs = await SharedPreferences.getInstance();
    final value = prefs.getInt(_accentKey);
    if (value != null) return Color(value);
    return Colors.deepPurple;
  }

  static Future<void> saveAccent(Color color) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_accentKey, color.value);
  }

  static Future<double> loadTextScale() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getDouble(_textScaleKey) ?? 1.0;
  }

  static Future<void> saveTextScale(double value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_textScaleKey, value);
  }

  static Future<bool> loadBlur() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_blurKey) ?? true;
  }

  static Future<void> saveBlur(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_blurKey, value);
  }

  static Future<bool> loadAnimations() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_animationsKey) ?? true;
  }

  static Future<void> saveAnimations(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_animationsKey, value);
  }

  static Future<bool> loadRounded() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_roundedKey) ?? true;
  }

  static Future<void> saveRounded(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_roundedKey, value);
  }

  static Future<bool> loadHero() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_heroKey) ?? true;
  }

  static Future<void> saveHero(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_heroKey, value);
  }
}
