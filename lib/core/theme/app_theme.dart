import 'package:flutter/material.dart';

class AppTheme {
  AppTheme._();

  // Premium Custom Color Palette (Seed: deep indigo/violet)
  static const Color primaryLight = Color(0xFF6200EE);
  static const Color secondaryLight = Color(0xFF03DAC6);
  static const Color accentLight = Color(0xFFFF5722);
  static const Color backgroundLight = Color(0xFFF8F9FA);
  static const Color surfaceLight = Colors.white;

  static const Color primaryDark = Color(0xFFBB86FC);
  static const Color secondaryDark = Color(0xFF03DAC6);
  static const Color accentDark = Color(0xFFF35D30);
  static const Color backgroundDark = Color(0xFF121212);
  static const Color surfaceDark = Color(0xFF1E1E1E);

  // Modern Light Theme
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: const ColorScheme.light(
        primary: primaryLight,
        secondary: secondaryLight,
        tertiary: accentLight,
        surface: surfaceLight,
        error: Color(0xFFB00020),
      ),
      scaffoldBackgroundColor: backgroundLight,
      appBarTheme: const AppBarTheme(
        backgroundColor: surfaceLight,
        elevation: 0,
        centerTitle: false,
        iconTheme: IconThemeData(color: Colors.black87),
        titleTextStyle: TextStyle(
          color: Colors.black87,
          fontSize: 20,
          fontWeight: FontWeight.bold,
          fontFamily: 'Inter',
        ),
      ),
      cardTheme: CardThemeData(
        color: surfaceLight,
        elevation: 2,
        shadowColor: Colors.black12,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryLight,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            fontFamily: 'Inter',
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.grey.shade50,
        contentPadding: const EdgeInsets.all(16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primaryLight, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFB00020)),
        ),
      ),
      textTheme: const TextTheme(
        headlineLarge: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.black87, fontFamily: 'Inter'),
        headlineMedium: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black87, fontFamily: 'Inter'),
        titleLarge: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: Colors.black87, fontFamily: 'Inter'),
        titleMedium: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black87, fontFamily: 'Inter'),
        bodyLarge: TextStyle(fontSize: 16, color: Colors.black87, fontFamily: 'Inter'),
        bodyMedium: TextStyle(fontSize: 14, color: Colors.black54, fontFamily: 'Inter'),
        labelLarge: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: primaryLight, fontFamily: 'Inter'),
      ),
    );
  }

  // Modern Dark Theme
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: const ColorScheme.dark(
        primary: primaryDark,
        secondary: secondaryDark,
        tertiary: accentDark,
        surface: surfaceDark,
        error: Color(0xFFCF6679),
      ),
      scaffoldBackgroundColor: backgroundDark,
      appBarTheme: const AppBarTheme(
        backgroundColor: surfaceDark,
        elevation: 0,
        centerTitle: false,
        iconTheme: IconThemeData(color: Colors.white70),
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
          fontFamily: 'Inter',
        ),
      ),
      cardTheme: CardThemeData(
        color: surfaceDark,
        elevation: 4,
        shadowColor: Colors.black54,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryDark,
          foregroundColor: Colors.black87,
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            fontFamily: 'Inter',
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF2C2C2C),
        contentPadding: const EdgeInsets.all(16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade800),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade800),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primaryDark, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFCF6679)),
        ),
      ),
      textTheme: const TextTheme(
        headlineLarge: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white, fontFamily: 'Inter'),
        headlineMedium: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white, fontFamily: 'Inter'),
        titleLarge: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: Colors.white, fontFamily: 'Inter'),
        titleMedium: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white, fontFamily: 'Inter'),
        bodyLarge: TextStyle(fontSize: 16, color: Colors.white, fontFamily: 'Inter'),
        bodyMedium: TextStyle(fontSize: 14, color: Colors.white70, fontFamily: 'Inter'),
        labelLarge: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: primaryDark, fontFamily: 'Inter'),
      ),
    );
  }
}
