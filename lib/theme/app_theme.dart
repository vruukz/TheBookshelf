import 'package:flutter/material.dart';

class AppTheme {
  // Color palette from carpinisan-tech.org
  static const Color bgColor = Color(0xFF0A0A0A);
  static const Color surfaceColor = Color(0xFF111111);
  static const Color cardColor = Color(0xFF161616);
  static const Color borderColor = Color(0xFF2A2A2A);
  static const Color accentGreen = Color(0xFF4ADE80);
  static const Color accentGreenDim = Color(0xFF22C55E);
  static const Color textPrimary = Color(0xFFF0F0F0);
  static const Color textSecondary = Color(0xFF888888);
  static const Color textMuted = Color(0xFF555555);

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: bgColor,
      colorScheme: const ColorScheme.dark(
        primary: accentGreen,
        secondary: accentGreenDim,
        surface: surfaceColor,
        onPrimary: bgColor,
        onSecondary: bgColor,
        onSurface: textPrimary,
      ),
      fontFamily: 'monospace',
      appBarTheme: const AppBarTheme(
        backgroundColor: bgColor,
        foregroundColor: textPrimary,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
      ),
      cardTheme: CardThemeData(
        color: cardColor,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: const BorderSide(color: borderColor, width: 1),
        ),
      ),
      dividerTheme: const DividerThemeData(color: borderColor),
      textTheme: const TextTheme(
        displayLarge: TextStyle(color: textPrimary, fontWeight: FontWeight.w700, letterSpacing: -1.5),
        displayMedium: TextStyle(color: textPrimary, fontWeight: FontWeight.w700, letterSpacing: -1),
        headlineLarge: TextStyle(color: textPrimary, fontWeight: FontWeight.w700, letterSpacing: -0.5),
        headlineMedium: TextStyle(color: textPrimary, fontWeight: FontWeight.w600),
        headlineSmall: TextStyle(color: textPrimary, fontWeight: FontWeight.w600),
        titleLarge: TextStyle(color: textPrimary, fontWeight: FontWeight.w600, letterSpacing: 0.5),
        titleMedium: TextStyle(color: textPrimary, fontWeight: FontWeight.w500),
        titleSmall: TextStyle(color: textSecondary, fontWeight: FontWeight.w500),
        bodyLarge: TextStyle(color: textPrimary, height: 1.7),
        bodyMedium: TextStyle(color: textSecondary, height: 1.6),
        bodySmall: TextStyle(color: textMuted, height: 1.5),
        labelLarge: TextStyle(color: accentGreen, fontWeight: FontWeight.w600, letterSpacing: 1.2),
        labelMedium: TextStyle(color: textSecondary, letterSpacing: 0.8),
        labelSmall: TextStyle(color: textMuted, letterSpacing: 0.5),
      ),
    );
  }
}
