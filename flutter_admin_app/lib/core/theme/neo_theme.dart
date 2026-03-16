import 'package:flutter/material.dart';

class NeoColors {
  static const Color acidLime = Color(0xFFCCFF00); // #CCFF00
  static const Color voidGreen = Color(0xFF020402); // #020402
  static const Color pureWhite = Color(0xFFFFFFFF);
  static const Color darkGray = Color(0xFF333333);

  // 기능성 색상
  static const Color error = Color(0xFFFF4C4C);
  static const Color success = Color(0xFF00E676);
}

class NeoTheme {
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: NeoColors.voidGreen,
      colorScheme: const ColorScheme.dark(
        primary: NeoColors.acidLime,
        secondary: NeoColors.pureWhite,
        surface: NeoColors.voidGreen,
        error: NeoColors.error,
        onPrimary: NeoColors.voidGreen,
        onSurface: NeoColors.pureWhite,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: NeoColors.darkGray,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: NeoColors.acidLime, width: 2),
        ),
        labelStyle: const TextStyle(color: Colors.white70),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: NeoColors.acidLime,
          foregroundColor: NeoColors.voidGreen,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
