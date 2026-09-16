import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData light(Color accent, bool rounded) {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,

      colorScheme: ColorScheme.fromSeed(
        seedColor: accent,
        brightness: Brightness.light,
      ),

      scaffoldBackgroundColor: Colors.white,

      appBarTheme: const AppBarTheme(elevation: 0, centerTitle: false),

      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(rounded ? 20 : 6),
        ),
      ),

      navigationBarTheme: NavigationBarThemeData(
        indicatorColor: accent.withOpacity(.15),
      ),

      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: accent,
        foregroundColor: Colors.white,
      ),

      switchTheme: SwitchThemeData(
        thumbColor: WidgetStatePropertyAll(accent),
        trackColor: WidgetStatePropertyAll(accent.withOpacity(.4)),
      ),

      sliderTheme: SliderThemeData(
        activeTrackColor: accent,
        thumbColor: accent,
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: accent,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(rounded ? 16 : 6),
          ),
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.grey.shade100,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(rounded ? 16 : 6),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  static ThemeData dark(Color accent, bool rounded) {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,

      colorScheme: ColorScheme.fromSeed(
        seedColor: accent,
        brightness: Brightness.dark,
      ),

      scaffoldBackgroundColor: const Color(0xff09090F),

      appBarTheme: const AppBarTheme(
        elevation: 0,
        backgroundColor: Color(0xff09090F),
      ),

      cardTheme: CardThemeData(
        color: const Color(0xff171725),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(rounded ? 20 : 6),
        ),
      ),

      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: const Color(0xff101018),
        indicatorColor: accent.withOpacity(.20),
      ),

      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: accent,
      ),

      switchTheme: SwitchThemeData(
        thumbColor: WidgetStatePropertyAll(accent),
        trackColor: WidgetStatePropertyAll(accent.withOpacity(.4)),
      ),

      sliderTheme: SliderThemeData(
        activeTrackColor: accent,
        thumbColor: accent,
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: accent,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(rounded ? 16 : 6),
          ),
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xff171725),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(rounded ? 16 : 6),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  static ThemeData amoled(Color accent, bool rounded) {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,

      colorScheme: ColorScheme.fromSeed(
        seedColor: accent,
        brightness: Brightness.dark,
      ),

      scaffoldBackgroundColor: Colors.black,

      appBarTheme: const AppBarTheme(
        elevation: 0,
        backgroundColor: Colors.black,
      ),

      cardTheme: CardThemeData(
        color: const Color(0xff050505),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(rounded ? 20 : 6),
        ),
      ),

      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: Colors.black,
        indicatorColor: accent.withOpacity(.25),
      ),

      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: accent,
      ),

      switchTheme: SwitchThemeData(
        thumbColor: WidgetStatePropertyAll(accent),
        trackColor: WidgetStatePropertyAll(accent.withOpacity(.4)),
      ),

      sliderTheme: SliderThemeData(
        activeTrackColor: accent,
        thumbColor: accent,
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: accent,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(rounded ? 16 : 6),
          ),
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xff050505),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(rounded ? 16 : 6),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
