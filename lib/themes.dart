import 'package:flutter/material.dart';

class AppThemes {
  // Custom red colors for light and dark themes
  static const _lightRed = Color(0xFFE53935);  // A bright, vibrant red for light theme
  static const _darkRed = Color(0xFFFF5252);   // A lighter, more visible red for dark theme

  static ThemeData light = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: ColorScheme.fromSeed(
      seedColor: _lightRed,
      brightness: Brightness.light,
    ).copyWith(
      // Optional: directly override specific colors if needed
      primary: _lightRed,
      primaryContainer: _lightRed.withOpacity(0.2),
    ),
    scaffoldBackgroundColor: Colors.white,
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.white,
      foregroundColor: Colors.black,
      elevation: 0,
    ),
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: Colors.white,
    ),
    textTheme: const TextTheme(
      titleLarge: TextStyle(
        color: Colors.black,
        fontSize: 24,
        fontWeight: FontWeight.bold,
      ),
      titleMedium: TextStyle(
        color: Colors.black,
        fontSize: 20,
        fontWeight: FontWeight.w600,
      ),
      bodyLarge: TextStyle(
        color: Colors.black,
        fontSize: 16,
      ),
      bodyMedium: TextStyle(
        color: Colors.black,
        fontSize: 14,
      ),
      bodySmall: TextStyle(
        color: Colors.black,
        fontSize: 12,
      ),
    ),
    iconTheme: const IconThemeData(
      color: Colors.black87,
    ),
  );

  static ThemeData dark = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: ColorScheme.fromSeed(
      seedColor: _darkRed,
      brightness: Brightness.dark,
    ).copyWith(
      // Optional: directly override specific colors if needed
      primary: _darkRed,
      primaryContainer: _darkRed.withOpacity(0.2),
    ),
    scaffoldBackgroundColor: Colors.black,
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.black,
      foregroundColor: Colors.white,
      elevation: 0,
    ),
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: Color(0xFF1E1E1E),
    ),
    textTheme: const TextTheme(
      titleLarge: TextStyle(
        color: Colors.white,
        fontSize: 24,
        fontWeight: FontWeight.bold,
      ),
      titleMedium: TextStyle(
        color: Colors.white,
        fontSize: 20,
        fontWeight: FontWeight.w600,
      ),
      bodyLarge: TextStyle(
        color: Colors.white,
        fontSize: 16,
      ),
      bodyMedium: TextStyle(
        color: Colors.white,
        fontSize: 14,
      ),
      bodySmall: TextStyle(
        color: Colors.white,
        fontSize: 12,
      ),
    ),
    iconTheme: const IconThemeData(
      color: Colors.white70,
    ),
  );
}
