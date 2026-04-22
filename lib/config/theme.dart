import 'package:flutter/material.dart';

class AppTheme {
  static const Color primary = Color(0xFF1A1A2E);
  static const Color accent = Color(0xFFE94560);
  static const Color background = Color(0xFF16213E);
  static const Color surface = Color(0xFF0F3460);
  static const Color textLight = Color(0xFFFFFFFF);
  static const Color textMuted = Color(0xFFB0B0C0);

  static ThemeData get theme => ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.dark(
      primary: accent,
      surface: surface,
      background: background,
    ),
    scaffoldBackgroundColor: background,
    textTheme: const TextTheme(
      displayLarge: TextStyle(color: textLight, fontWeight: FontWeight.bold),
      bodyLarge: TextStyle(color: textLight),
      bodyMedium: TextStyle(color: textMuted),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: accent,
        foregroundColor: textLight,
        minimumSize: const Size(double.infinity, 56),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
    ),
  );
}
