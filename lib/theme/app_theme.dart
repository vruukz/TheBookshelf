import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppTheme {
  // Color palette from carpinisan-tech.org
  static const Color bgColor = Color(0xFF0A0A0A);
  static const Color surfaceColor = Color(0xFF111111);
  static const Color cardColor = Color(0xFF161616);
  static const Color borderColor = Color(0xFF2A2A2A);
  static const Color defaultAccent = Color(0xFF4ADE80);
  static final ValueNotifier<Color> accentNotifier = ValueNotifier<Color>(defaultAccent);
  static Color get accentGreen => accentNotifier.value;
  static Color get accentGreenDim {
    final hsl = HSLColor.fromColor(accentGreen);
    return hsl.withLightness((hsl.lightness * 0.75).clamp(0.0, 1.0)).toColor();
  }
  static const Color textPrimary = Color(0xFFF0F0F0);
  static const Color textSecondary = Color(0xFF888888);
  static const Color textMuted = Color(0xFF555555);

  static Future<void> loadAccent() async {
    final prefs = await SharedPreferences.getInstance();
    final value = prefs.getInt('accent_color');
    if (value != null) accentNotifier.value = Color(value);
  }

  static Future<void> setAccent(Color color) async {
    accentNotifier.value = color;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('accent_color', color.value);
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: bgColor,
      colorScheme: ColorScheme.dark(
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
      textTheme: TextTheme(
        displayLarge: const TextStyle(color: textPrimary, fontWeight: FontWeight.w700, letterSpacing: -1.5),
        displayMedium: const TextStyle(color: textPrimary, fontWeight: FontWeight.w700, letterSpacing: -1),
        headlineLarge: const TextStyle(color: textPrimary, fontWeight: FontWeight.w700, letterSpacing: -0.5),
        headlineMedium: const TextStyle(color: textPrimary, fontWeight: FontWeight.w600),
        headlineSmall: const TextStyle(color: textPrimary, fontWeight: FontWeight.w600),
        titleLarge: const TextStyle(color: textPrimary, fontWeight: FontWeight.w600, letterSpacing: 0.5),
        titleMedium: const TextStyle(color: textPrimary, fontWeight: FontWeight.w500),
        titleSmall: const TextStyle(color: textSecondary, fontWeight: FontWeight.w500),
        bodyLarge: const TextStyle(color: textPrimary, height: 1.7),
        bodyMedium: const TextStyle(color: textSecondary, height: 1.6),
        bodySmall: const TextStyle(color: textMuted, height: 1.5),
        labelLarge: TextStyle(color: accentGreen, fontWeight: FontWeight.w600, letterSpacing: 1.2),
        labelMedium: const TextStyle(color: textSecondary, letterSpacing: 0.8),
        labelSmall: const TextStyle(color: textMuted, letterSpacing: 0.5),
      ),
    );
  }
}
