import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocaleProvider extends ChangeNotifier {
  static const String _localeKey = 'app_locale';
  Locale _locale = const Locale('es', 'MX');

  Locale get locale => _locale;

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final languageCode = prefs.getString(_localeKey);
    if (languageCode != null) {
      if (languageCode == 'nah') {
        _locale = const Locale('nah');
      } else if (languageCode == 'es_MX') {
        _locale = const Locale('es', 'MX');
      } else {
        _locale = Locale(languageCode);
      }
      notifyListeners();
    }
  }

  void setLocale(Locale newLocale) {
    if (_locale != newLocale) {
      _locale = newLocale;
      _saveLocale(newLocale);
      notifyListeners();
    }
  }

  Future<void> _saveLocale(Locale locale) async {
    final prefs = await SharedPreferences.getInstance();
    String localeStr = locale.languageCode;
    if (locale.countryCode != null) {
      localeStr = '${locale.languageCode}_${locale.countryCode}';
    }
    await prefs.setString(_localeKey, localeStr);
  }

  String getLocaleName(Locale locale) {
    if (locale.languageCode == 'nah') return 'Náhuatl';
    return 'Español (México)';
  }
}
