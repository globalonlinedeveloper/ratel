import 'package:flutter/material.dart';
import 'tokens.dart';

/// Builds the Ratel light/dark [ThemeData] from the design tokens.
ThemeData ratelTheme() => _build(Brightness.light);
ThemeData ratelDarkTheme() => _build(Brightness.dark);

ThemeData _build(Brightness brightness) {
  final bool dark = brightness == Brightness.dark;
  final RatelTokens tk = dark ? RatelTokens.dark : RatelTokens.light;
  final Color bg = dark ? RatelColorsDark.background : RatelColors.background;
  final ColorScheme scheme = ColorScheme.fromSeed(
    seedColor: tk.primary,
    primary: tk.primary,
    secondary: tk.brand,
    brightness: brightness,
  ).copyWith(surface: tk.surface, error: tk.danger);
  return ThemeData(
    useMaterial3: true,
    brightness: brightness,
    colorScheme: scheme,
    scaffoldBackgroundColor: bg,
    fontFamily: kBodyFont,
    extensions: <ThemeExtension<dynamic>>[tk],
  );
}
