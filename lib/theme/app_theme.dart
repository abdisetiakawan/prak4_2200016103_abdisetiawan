import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color garnet = Color(0xFFA50044);
  static const Color blue = Color(0xFF004D98);
  static const Color gold = Color(0xFFEDBB00);
  static const Color navy = Color(0xFF0B1C3A);

  static ThemeData themed() {
    final baseScheme = ColorScheme.fromSeed(
      seedColor: garnet,
      brightness: Brightness.dark,
    ).copyWith(
      surface: const Color(0xFF162445),
      primary: garnet,
      secondary: gold,
      tertiary: blue,
    );

    return ThemeData(
      colorScheme: baseScheme,
      textTheme: GoogleFonts.montserratTextTheme().apply(
        bodyColor: Colors.white,
        displayColor: Colors.white,
      ),
      scaffoldBackgroundColor: navy,
      appBarTheme: const AppBarTheme(
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: garnet,
        foregroundColor: Colors.white,
      ),
      checkboxTheme: CheckboxThemeData(
        checkColor: WidgetStateProperty.all(Colors.white),
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return gold;
          }
          return Colors.white70;
        }),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.1),
        labelStyle: const TextStyle(color: Colors.white70),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.2)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.2)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: gold, width: 2),
        ),
      ),
      snackBarTheme: const SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: garnet,
        contentTextStyle: TextStyle(color: Colors.white),
      ),
      cardTheme: CardThemeData(
        color: Colors.white.withValues(alpha: 0.06),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
        ),
        margin: EdgeInsets.zero,
      ),
    );
  }
}
