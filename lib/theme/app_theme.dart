import 'package:flutter/material.dart';

class AppTheme {
  // Paleta de cores definida
  static const Color indigo = Color(0xFF4F46E5);
  static const Color amber = Color(0xFFF59E0B);
  static const Color slate = Color(0xFF1F2937);
  static const Color slateLight = Color(0xFF374151);
  static const Color slateLighter = Color(0xFF6B7280);

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: indigo,
        primary: indigo,
        secondary: amber,
        surface: Colors.white,
        onSurface: slate,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: indigo,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      cardTheme: CardTheme(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: indigo,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: amber,
        foregroundColor: Colors.white,
      ),
      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          color: slate,
          fontWeight: FontWeight.bold,
        ),
        headlineMedium: TextStyle(
          color: slate,
          fontWeight: FontWeight.w600,
        ),
        bodyLarge: TextStyle(color: slate),
        bodyMedium: TextStyle(color: slateLight),
      ),
    );
  }
}

