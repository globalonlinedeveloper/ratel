import 'package:flutter/material.dart';
import 'tokens.dart';

/// Builds the Ratel light/dark [ThemeData] from the design tokens.
/// [accentIndex] selects one of [ratelAccents] (0 = default teal primary).
ThemeData ratelTheme({int accentIndex = 0}) =>
    _build(Brightness.light, accentIndex);
ThemeData ratelDarkTheme({int accentIndex = 0}) =>
    _build(Brightness.dark, accentIndex);

/// The 3 selectable accents, by brightness. Index 0 = default teal primary.
/// Token *names* only (no raw hex) -> token-lint safe (file is in core/ anyway).
List<Color> ratelAccents(bool dark) => <Color>[
      dark ? RatelColorsDark.teal : RatelColors.teal,
      dark ? RatelColorsDark.honey : RatelColors.honey,
      RatelSociety.purple,
    ];

ThemeData _build(Brightness brightness, int accentIndex) {
  final bool dark = brightness == Brightness.dark;
  final RatelTokens base = dark ? RatelTokens.dark : RatelTokens.light;
  final List<Color> accents = ratelAccents(dark);
  final Color accent = accents[accentIndex.clamp(0, accents.length - 1)];
  final RatelTokens tk = base.copyWith(primary: accent); // accent drives token.primary
  final Color bg = dark ? RatelColorsDark.background : RatelColors.background;
  final ColorScheme scheme = ColorScheme.fromSeed(
    seedColor: accent,
    primary: accent,
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
