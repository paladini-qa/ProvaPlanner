import 'package:flutter/material.dart';

class AppTheme {
  // Paleta de cores definida
  static const Color indigo = Color(0xFF4F46E5);
  static const Color amber = Color(0xFFF59E0B);
  static const Color slate = Color(0xFF1F2937);
  static const Color slateLight = Color(0xFF374151);
  static const Color slateLighter = Color(0xFF6B7280);

  // Cor semente para geração automática de temas
  static const Color _seedColor = indigo;

  // ColorSchemes gerados automaticamente com fromSeed
  static final ColorScheme lightColorScheme = ColorScheme.fromSeed(
    seedColor: _seedColor,
    brightness: Brightness.light,
  ).copyWith(
    primary: indigo,
    secondary: amber,
    surface: Colors.white,
    onSurface: slate,
  );

  static final ColorScheme darkColorScheme = ColorScheme.fromSeed(
    seedColor: _seedColor,
    brightness: Brightness.dark,
  ).copyWith(
    secondary: amber,
  );

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: lightColorScheme,
      appBarTheme: const AppBarTheme(
        backgroundColor: indigo,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      cardTheme: CardThemeData(
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
      // Configurações de acessibilidade
      visualDensity: VisualDensity.adaptivePlatformDensity,
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: darkColorScheme,
      appBarTheme: AppBarTheme(
        backgroundColor: darkColorScheme.surface,
        foregroundColor: darkColorScheme.onSurface,
        elevation: 0,
        centerTitle: true,
      ),
      cardTheme: CardThemeData(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: darkColorScheme.primary,
          foregroundColor: darkColorScheme.onPrimary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: amber,
        foregroundColor: Colors.black87,
      ),
      // Configurações de acessibilidade
      visualDensity: VisualDensity.adaptivePlatformDensity,
    );
  }
}

