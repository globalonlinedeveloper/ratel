import 'package:flutter/material.dart';
import 'tokens.dart';

/// Builds the Ratel light/dark [ThemeData] from the design tokens.
/// [accentIndex] selects one of [ratelAccents] (0 = default teal primary).
/// [highContrast] tightens muted/border tokens to the text colour.
/// [dyslexiaFont] swaps the body font family (asset deferred -> graceful fallback).
ThemeData ratelTheme({
  int accentIndex = 0,
  bool highContrast = false,
  bool dyslexiaFont = false,
}) =>
    _build(Brightness.light, accentIndex, highContrast, dyslexiaFont);
ThemeData ratelDarkTheme({
  int accentIndex = 0,
  bool highContrast = false,
  bool dyslexiaFont = false,
}) =>
    _build(Brightness.dark, accentIndex, highContrast, dyslexiaFont);

/// The 3 selectable accents, by brightness. Index 0 = default teal primary.
/// Token *names* only (no raw hex) -> token-lint safe (file is in core/ anyway).
List<Color> ratelAccents(bool dark) => <Color>[
      dark ? RatelColorsDark.teal : RatelColors.teal,
      dark ? RatelColorsDark.honey : RatelColors.honey,
      RatelSociety.purple,
    ];

ThemeData _build(
  Brightness brightness,
  int accentIndex,
  bool highContrast,
  bool dyslexiaFont,
) {
  final bool dark = brightness == Brightness.dark;
  final RatelTokens base = dark ? RatelTokens.dark : RatelTokens.light;
  final List<Color> accents = ratelAccents(dark);
  final Color accent = accents[accentIndex.clamp(0, accents.length - 1)];
  RatelTokens tk = base.copyWith(primary: accent); // accent drives token.primary
  if (highContrast) {
    // raise contrast using existing tokens only (no new hex): muted -> text,
    // borders -> text so dividers and secondary copy reach full contrast.
    tk = tk.copyWith(textMuted: tk.text, border: tk.text);
  }
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
    fontFamily: dyslexiaFont ? kDyslexiaFont : kBodyFont,
    extensions: <ThemeExtension<dynamic>>[tk],
  );
}
