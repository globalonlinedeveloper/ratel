import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Brand font families (bundled in assets/fonts, OFL-licensed).
const String kDisplayFont = 'Baloo2';
const String kBodyFont = 'NunitoSans';

/// Ratel brand palette (light-mode anchors; shared accents work in both modes).
class RatelColors {
  static const Color charcoal = Color(0xFF2C2A2A);
  static const Color slate = Color(0xFF2B3947);
  static const Color honey = Color(0xFFC77D2E);
  static const Color teal = Color(0xFF1D9E75);
  static const Color coral = Color(0xFFD85A30);
  static const Color cream = Color(0xFFECEAE2);
  static const Color background = Color(0xFFF7F7F4);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color textMuted = Color(0xFF757470);
  static const Color hearts = Color(0xFFD4537E);
  static const Color border = Color(0xFFEAEAEA);
}

/// Dark-mode palette (warm charcoal, brand-true).
class RatelColorsDark {
  static const Color background = Color(0xFF141312);
  static const Color surface = Color(0xFF201E1C);
  static const Color border = Color(0xFF383530);
  static const Color outline = Color(0xFF3E3B36);
  static const Color text = Color(0xFFECEAE2);
  static const Color textMuted = Color(0xFFA5A29B);
  static const Color honey = Color(0xFFD08A3C);
  static const Color teal = Color(0xFF27AE83);
  static const Color coral = Color(0xFFE06A40);
}

/// Theme-aware color shortcuts so widgets never hardcode light-mode values.
extension RatelThemeColors on BuildContext {
  bool get isDark => Theme.of(this).brightness == Brightness.dark;
  Color get surfaceC => isDark ? RatelColorsDark.surface : RatelColors.surface;
  Color get backgroundC =>
      isDark ? RatelColorsDark.background : RatelColors.background;
  Color get borderC => isDark ? RatelColorsDark.border : RatelColors.border;
  Color get mutedC =>
      isDark ? RatelColorsDark.textMuted : RatelColors.textMuted;
  Color get textC => isDark ? RatelColorsDark.text : RatelColors.charcoal;
}

/// ----- Theme mode (System / Light / Dark), persisted -----
final ValueNotifier<ThemeMode> themeModeNotifier =
    ValueNotifier<ThemeMode>(ThemeMode.system);

Future<void> loadThemeMode() async {
  try {
    final prefs = await SharedPreferences.getInstance();
    switch (prefs.getString('theme_mode')) {
      case 'light':
        themeModeNotifier.value = ThemeMode.light;
      case 'dark':
        themeModeNotifier.value = ThemeMode.dark;
      default:
        themeModeNotifier.value = ThemeMode.system;
    }
  } catch (_) {}
}

Future<void> setThemeMode(ThemeMode mode) async {
  themeModeNotifier.value = mode;
  try {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('theme_mode', switch (mode) {
      ThemeMode.light => 'light',
      ThemeMode.dark => 'dark',
      ThemeMode.system => 'system',
    });
  } catch (_) {}
}

/// ----- Reduce motion (user preference, OR'd with the OS setting) -----
final ValueNotifier<bool> reduceMotionNotifier = ValueNotifier<bool>(false);

Future<void> loadReduceMotion() async {
  try {
    final prefs = await SharedPreferences.getInstance();
    reduceMotionNotifier.value = prefs.getBool('reduce_motion') ?? false;
  } catch (_) {}
}

Future<void> setReduceMotion(bool on) async {
  reduceMotionNotifier.value = on;
  try {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('reduce_motion', on);
  } catch (_) {}
}

extension RatelMotion on BuildContext {
  /// True when the OS requests reduced animations OR the user turned the
  /// in-app "Reduce motion" setting on.
  bool get reduceMotion =>
      (MediaQuery.maybeOf(this)?.disableAnimations ?? false) ||
      reduceMotionNotifier.value;
}

/// Non-color design tokens (radii, spacing).
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
      bodyLarge: TextStyle(fontFamily: kBodyFont, height: 1.45, color: text),
      bodyMedium: TextStyle(fontFamily: kBodyFont, height: 1.4, color: text),
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

class _Pal {
  const _Pal({
    required this.brightness,
    required this.bg,
    required this.surface,
    required this.border,
    required this.outline,
    required this.text,
    required this.muted,
    required this.primary,
    required this.secondary,
    required this.error,
    required this.snackBg,
    required this.snackText,
  });
  final Brightness brightness;
  final Color bg, surface, border, outline, text, muted;
  final Color primary, secondary, error, snackBg, snackText;
}

const _light = _Pal(
  brightness: Brightness.light,
  bg: RatelColors.background,
  surface: RatelColors.surface,
  border: RatelColors.border,
  outline: Color(0xFFE3E1DA),
  text: RatelColors.charcoal,
  muted: RatelColors.textMuted,
  primary: RatelColors.honey,
  secondary: RatelColors.teal,
  error: RatelColors.coral,
  snackBg: RatelColors.charcoal,
  snackText: RatelColors.cream,
);

const _dark = _Pal(
  brightness: Brightness.dark,
  bg: RatelColorsDark.background,
  surface: RatelColorsDark.surface,
  border: RatelColorsDark.border,
  outline: RatelColorsDark.outline,
  text: RatelColorsDark.text,
  muted: RatelColorsDark.textMuted,
  primary: RatelColorsDark.honey,
  secondary: RatelColorsDark.teal,
  error: RatelColorsDark.coral,
  snackBg: RatelColors.cream,
  snackText: RatelColors.charcoal,
);

ThemeData _buildTheme(_Pal p) {
  final ColorScheme scheme = ColorScheme.fromSeed(
    seedColor: p.primary,
    primary: p.primary,
    secondary: p.secondary,
    brightness: p.brightness,
  ).copyWith(surface: p.surface, error: p.error);

  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    fontFamily: kBodyFont,
    textTheme: _ratelTextTheme(p.text, p.muted),
    scaffoldBackgroundColor: p.bg,
    extensions: const <ThemeExtension<dynamic>>[RatelTokens()],
    appBarTheme: AppBarTheme(
      backgroundColor: p.surface,
      foregroundColor: p.text,
      elevation: 0,
      titleTextStyle: TextStyle(
          fontFamily: kDisplayFont,
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: p.text),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: p.primary,
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
        backgroundColor: p.primary,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        textStyle: const TextStyle(
            fontFamily: kBodyFont, fontWeight: FontWeight.w700, fontSize: 16),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: p.text,
        side: BorderSide(color: p.outline, width: 1.4),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        textStyle: const TextStyle(
            fontFamily: kBodyFont, fontWeight: FontWeight.w700, fontSize: 15),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: p.secondary,
        textStyle: const TextStyle(
            fontFamily: kBodyFont, fontWeight: FontWeight.w700, fontSize: 15),
      ),
    ),
    cardTheme: CardThemeData(
      color: p.surface,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: const BorderRadius.all(Radius.circular(16)),
        side: BorderSide(color: p.border),
      ),
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: p.surface,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(20))),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: p.surface,
      indicatorColor: p.primary.withValues(alpha: 0.16),
      labelTextStyle: WidgetStatePropertyAll(TextStyle(
          fontFamily: kBodyFont,
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: p.text)),
      iconTheme: WidgetStateProperty.resolveWith(
        (Set<WidgetState> states) => IconThemeData(
            color:
                states.contains(WidgetState.selected) ? p.primary : p.muted),
      ),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: p.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: p.outline),
      ),
      labelStyle: TextStyle(
          fontFamily: kBodyFont, fontWeight: FontWeight.w600, color: p.text),
    ),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      backgroundColor: p.snackBg,
      contentTextStyle: TextStyle(
          fontFamily: kBodyFont, fontSize: 14, color: p.snackText),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith((Set<WidgetState> states) =>
          states.contains(WidgetState.selected) ? Colors.white : null),
      trackColor: WidgetStateProperty.resolveWith((Set<WidgetState> states) =>
          states.contains(WidgetState.selected) ? p.secondary : null),
    ),
    progressIndicatorTheme: ProgressIndicatorThemeData(color: p.primary),
    listTileTheme: ListTileThemeData(iconColor: p.muted),
    dividerTheme: DividerThemeData(color: p.border, thickness: 1),
  );
}

ThemeData ratelTheme() => _buildTheme(_light);
ThemeData ratelDarkTheme() => _buildTheme(_dark);
