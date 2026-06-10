import 'package:flutter/material.dart';

/// Brand font families (bundled in assets/fonts, OFL-licensed).
/// Baloo2 = rounded display face (headings, hero moments).
/// NunitoSans = friendly, highly legible UI/body face.
const String kDisplayFont = 'Baloo2';
const String kBodyFont = 'NunitoSans';

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
  static const Color border = Color(0xFFEAEAEA);
}

/// Non-color design tokens (radii, spacing), attached to the theme so
/// widgets can read one source of truth: `Theme.of(context).extension<RatelTokens>()`.
class RatelTokens extends ThemeExtension<RatelTokens> {
  const RatelTokens({
    this.radiusSm = 12,
    this.radiusMd = 14,
    this.radiusLg = 20,
    this.gapSm = 8,
    this.gapMd = 16,
    this.gapLg = 24,
  });

  final double radiusSm;
  final double radiusMd;
  final double radiusLg;
  final double gapSm;
  final double gapMd;
  final double gapLg;

  @override
  RatelTokens copyWith({
    double? radiusSm,
    double? radiusMd,
    double? radiusLg,
    double? gapSm,
    double? gapMd,
    double? gapLg,
  }) =>
      RatelTokens(
        radiusSm: radiusSm ?? this.radiusSm,
        radiusMd: radiusMd ?? this.radiusMd,
        radiusLg: radiusLg ?? this.radiusLg,
        gapSm: gapSm ?? this.gapSm,
        gapMd: gapMd ?? this.gapMd,
        gapLg: gapLg ?? this.gapLg,
      );

  @override
  RatelTokens lerp(covariant RatelTokens? other, double t) => other ?? this;
}

/// Brand text styles: Baloo2 for display roles, NunitoSans for body/UI.
/// Only family/weight/height are set — sizes inherit Material defaults so
/// existing layouts don't shift.
TextTheme _ratelTextTheme(Color text, Color muted) => TextTheme(
      displayLarge: TextStyle(
          fontFamily: kDisplayFont, fontWeight: FontWeight.w800, color: text),
      displayMedium: TextStyle(
          fontFamily: kDisplayFont, fontWeight: FontWeight.w800, color: text),
      displaySmall: TextStyle(
          fontFamily: kDisplayFont, fontWeight: FontWeight.w700, color: text),
      headlineLarge: TextStyle(
          fontFamily: kDisplayFont, fontWeight: FontWeight.w800, color: text),
      headlineMedium: TextStyle(
          fontFamily: kDisplayFont, fontWeight: FontWeight.w700, color: text),
      headlineSmall: TextStyle(
          fontFamily: kDisplayFont, fontWeight: FontWeight.w700, color: text),
      titleLarge: TextStyle(
          fontFamily: kDisplayFont, fontWeight: FontWeight.w700, color: text),
      titleMedium: TextStyle(
          fontFamily: kBodyFont, fontWeight: FontWeight.w700, color: text),
      titleSmall: TextStyle(
          fontFamily: kBodyFont, fontWeight: FontWeight.w600, color: text),
      bodyLarge: TextStyle(
          fontFamily: kBodyFont, height: 1.45, color: text),
      bodyMedium: TextStyle(
          fontFamily: kBodyFont, height: 1.4, color: text),
      bodySmall: TextStyle(fontFamily: kBodyFont, color: muted),
      labelLarge: TextStyle(
          fontFamily: kBodyFont,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.2,
          color: text),
      labelMedium: TextStyle(
          fontFamily: kBodyFont, fontWeight: FontWeight.w600, color: text),
      labelSmall: TextStyle(
          fontFamily: kBodyFont, fontWeight: FontWeight.w600, color: muted),
    );

ThemeData ratelTheme() {
  final ColorScheme scheme = ColorScheme.fromSeed(
    seedColor: RatelColors.honey,
    primary: RatelColors.honey,
    secondary: RatelColors.teal,
    brightness: Brightness.light,
  ).copyWith(surface: RatelColors.surface, error: RatelColors.coral);

  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    fontFamily: kBodyFont,
    textTheme: _ratelTextTheme(RatelColors.charcoal, RatelColors.textMuted),
    scaffoldBackgroundColor: RatelColors.background,
    extensions: const <ThemeExtension<dynamic>>[RatelTokens()],
    appBarTheme: const AppBarTheme(
      backgroundColor: RatelColors.surface,
      foregroundColor: RatelColors.charcoal,
      elevation: 0,
      titleTextStyle: TextStyle(
          fontFamily: kDisplayFont,
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: RatelColors.charcoal),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: RatelColors.honey,
        foregroundColor: Colors.white,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        textStyle: const TextStyle(
            fontFamily: kBodyFont, fontWeight: FontWeight.w700, fontSize: 16),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: RatelColors.honey,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        textStyle: const TextStyle(
            fontFamily: kBodyFont, fontWeight: FontWeight.w700, fontSize: 16),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: RatelColors.charcoal,
        side: const BorderSide(color: Color(0xFFE3E1DA), width: 1.4),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        textStyle: const TextStyle(
            fontFamily: kBodyFont, fontWeight: FontWeight.w700, fontSize: 15),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: RatelColors.teal,
        textStyle: const TextStyle(
            fontFamily: kBodyFont, fontWeight: FontWeight.w700, fontSize: 15),
      ),
    ),
    cardTheme: const CardThemeData(
      color: RatelColors.surface,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(16)),
        side: BorderSide(color: RatelColors.border),
      ),
    ),
    dialogTheme: const DialogThemeData(
      backgroundColor: RatelColors.surface,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(20))),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: RatelColors.surface,
      indicatorColor: RatelColors.honey.withValues(alpha: 0.16),
      labelTextStyle: const WidgetStatePropertyAll(TextStyle(
          fontFamily: kBodyFont, fontSize: 12, fontWeight: FontWeight.w700)),
      iconTheme: WidgetStateProperty.resolveWith(
        (Set<WidgetState> states) => IconThemeData(
            color: states.contains(WidgetState.selected)
                ? RatelColors.honey
                : RatelColors.textMuted),
      ),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: RatelColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: Color(0xFFE3E1DA)),
      ),
      labelStyle: const TextStyle(
          fontFamily: kBodyFont,
          fontWeight: FontWeight.w600,
          color: RatelColors.charcoal),
    ),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      backgroundColor: RatelColors.charcoal,
      contentTextStyle: const TextStyle(
          fontFamily: kBodyFont, fontSize: 14, color: RatelColors.cream),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith((Set<WidgetState> states) =>
          states.contains(WidgetState.selected) ? Colors.white : null),
      trackColor: WidgetStateProperty.resolveWith((Set<WidgetState> states) =>
          states.contains(WidgetState.selected) ? RatelColors.teal : null),
    ),
    progressIndicatorTheme:
        const ProgressIndicatorThemeData(color: RatelColors.honey),
    listTileTheme: const ListTileThemeData(iconColor: RatelColors.textMuted),
    dividerTheme:
        const DividerThemeData(color: RatelColors.border, thickness: 1),
  );
}
