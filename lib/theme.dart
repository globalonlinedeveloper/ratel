import 'package:flutter/material.dart';

/// Ratel brand palette (matches the generated assets).
class RatelColors {
  static const Color charcoal = Color(0xFF2C2A2A);
  static const Color slate = Color(0xFF2B3947);
  static const Color honey = Color(0xFFC77D2E);
  static const Color teal = Color(0xFF1D9E75);
  static const Color coral = Color(0xFFD85A30);
  static const Color cream = Color(0xFFECEAE2);
  static const Color background = Color(0xFFF7F7F4);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color textMuted = Color(0xFF6B6B6B);
  static const Color hearts = Color(0xFFD4537E);
}

ThemeData ratelTheme() {
  final ColorScheme scheme = ColorScheme.fromSeed(
    seedColor: RatelColors.honey,
    primary: RatelColors.honey,
    secondary: RatelColors.teal,
    brightness: Brightness.light,
  );
  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    scaffoldBackgroundColor: RatelColors.background,
    appBarTheme: const AppBarTheme(
      backgroundColor: RatelColors.surface,
      foregroundColor: RatelColors.charcoal,
      elevation: 0,
    ),
  );
}
