import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'flags.dart';

/// Brand font families (bundled in assets/fonts, OFL-licensed).
const String kDisplayFont = 'Baloo2';
const String kBodyFont = 'NunitoSans';

/// Ratel brand palette (light-mode anchors; shared accents work in both modes).
/// NEW design system: teal is the action color; honey is brand/wordmark only.
class RatelColors {
  static const Color charcoal = Color(0xFF2C2A2A);
  static const Color slate = Color(0xFF2B3947);
  static const Color honey = Color(0xFFC77D2E); // brand/wordmark ONLY
  static const Color teal = Color(0xFF0F6E56); // primary/action (AA on white)
  static const Color coral = Color(0xFFD85A30); // streak/coral
  static const Color cream = Color(0xFFECEAE2);
  static const Color background = Color(0xFFFFFFFF); // app bg = pure white
  static const Color surface = Color(0xFFFFFFFF);
  static const Color textMuted = Color(0xFF757470);
  static const Color hearts = Color(0xFFD4537E);
  static const Color border = Color(0xFFE3E1DA); // warm hairline

  // Reward / energy (NEW). win = gold; MUST read distinct from honey.
  static const Color win = Color(0xFFEF9F27); // reward gold ONLY
  static const Color energy = Color(0xFFEF9F27); // energy/XP fuel

  // Semantic surfaces (NEW).
  static const Color page = Color(0xFFECEAE2); // page wash
  static const Color surface2 = Color(0xFFF4F4F1); // raised inner

  // Semantic fg + container pairs (NEW).
  static const Color success = Color(0xFF0F6E56);
  static const Color successBg = Color(0xFFE1F5EE);
  static const Color warning = Color(0xFF854F0B);
  static const Color warningBg = Color(0xFFFAEEDA);
  static const Color danger = Color(0xFFA32D2D);
  static const Color dangerBg = Color(0xFFFCEBEB);
  static const Color info = Color(0xFF185FA5);
  static const Color infoBg = Color(0xFFE6F1FB);

  /// 'EN' language-badge avatar fill (Learn-tab header). Inc 172:
  /// lifted from learn_tab so the tab body holds no raw hex (token-lint).
  static const Color enBadge = Color(0xFF185FA5); // == info
  /// lesson_screen accents (Inc 173.., detokenised so the screen is hex-clean):
  static const Color fixChip = Color(0xFFE08330); // 'FIXING MISTAKES' chip
  static const Color selected = Color(
    0xFF378ADD,
  ); // selected (unanswered) option
  static const Color scoreStat = Color(
    0xFF7B5EA7,
  ); // completion SCORE stat chip
  static const Color speedStat = Color(
    0xFF4A7FB5,
  ); // completion SPEED stat chip
}

/// Dark-mode palette (warm charcoal, brand-true). NEW design system.
class RatelColorsDark {
  static const Color background = Color(0xFF201E1C); // warmer base
  static const Color surface = Color(0xFF191817); // cards below page
  static const Color border = Color(0xFF383530);
  static const Color outline = Color(0xFF3E3B36);
  static const Color text = Color(0xFFECEAE2);
  static const Color textMuted = Color(0xFFA5A29B);
  static const Color honey = Color(0xFFD08A3C); // brand/wordmark (dark)
  static const Color teal = Color(0xFF27AE83); // primary/action (dark)
  static const Color coral = Color(0xFFD85A30); // single coral token

  // NEW semantic surfaces + reward/energy (dark).
  static const Color page = Color(0xFF34312C);
  static const Color surface2 = Color(0xFF34312C);
  static const Color win = Color(0xFFEF9F27);
  static const Color energy = Color(0xFFEF9F27);
  static const Color success = Color(0xFF27AE83);
  static const Color successBg = Color(0xFF1B3A30);
  static const Color warning = Color(0xFFD08A3C);
  static const Color warningBg = Color(0xFF3A301F);
  static const Color danger = Color(0xFFE06A66);
  static const Color dangerBg = Color(0xFF3A1F1F);
  static const Color info = Color(0xFF5FA0E0);
  static const Color infoBg = Color(0xFF1E2E3F);
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

  /// Subtle hairline (lighter than [borderC]) for input fields / idle tiles.
  Color get faintBorderC =>
      isDark ? const Color(0xFF34312C) : const Color(0xFFD8D8D8);

  /// Tinted halo behind the Profile avatar mascot (warm cream / warm dark).
  /// Inc 170: lifted from home_screen's Profile tab so the tab body holds
  /// no raw hex (token-lint allowlist).
  Color get avatarBgC =>
      isDark ? const Color(0xFF35302A) : const Color(0xFFFAEEDA);

  /// Idle/locked path-node + unready-chest fill (warm dark / soft grey).
  /// Inc 172: lifted from learn_tab so the tab body holds no raw hex.
  Color get lockedNodeC =>
      isDark ? const Color(0xFF3A3733) : const Color(0xFFD9D9D9);

  /// Solid accent wash readable in BOTH modes: blends the accent over the
  /// current surface (light -> soft pastel, dark -> deep accent-washed
  /// surface), so default text keeps contrast. Use for answer-state fills,
  /// highlight rows, info cards.
  Color tintC(Color accent) => Color.alphaBlend(
    accent.withValues(alpha: isDark ? 0.24 : 0.12),
    surfaceC,
  );
}

/// ----- Theme mode (System / Light / Dark), persisted -----
final ValueNotifier<ThemeMode> themeModeNotifier = ValueNotifier<ThemeMode>(
  ThemeMode.system,
);

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

/// ----- Battle mode (the duel layer over lessons), persisted -----
/// Per-unit accent palette (cycles) — gives each unit a visual identity
/// on the learn path instead of one monotone teal column.
const List<Color> kUnitAccents = [
  RatelColors.teal,
  Color(0xFFB66A2E), // amber
  Color(0xFF7B5EA7), // plum
  Color(0xFF3E8E5A), // forest
  Color(0xFF4A7FB5), // steel
];

Color unitAccent(int index) => kUnitAccents[index % kUnitAccents.length];

final ValueNotifier<bool> battleModeNotifier = ValueNotifier<bool>(true);

Future<void> loadBattleMode() async {
  try {
    final prefs = await SharedPreferences.getInstance();
    battleModeNotifier.value =
        prefs.getBool('battle_mode') ??
        Flags.instance.flag('battle_default_on', true);
  } catch (_) {}
}

Future<void> setBattleMode(bool on) async {
  battleModeNotifier.value = on;
  try {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('battle_mode', on);
  } catch (_) {}
}

/// Non-color design tokens (radii, spacing, hairline) + theme-aware reward /
/// energy / semantic colors carried on the extension. NEW design system.
class RatelTokens extends ThemeExtension<RatelTokens> {
  const RatelTokens({
    this.radiusSm = 8,
    this.radiusMd = 12,
    this.radiusLg = 16,
    this.radiusPill = 999,
    this.hairline = 0.5,
    this.gapSm = 8,
    this.gapMd = 16,
    this.gapLg = 24,
    this.win = RatelColors.win,
    this.energy = RatelColors.energy,
    this.success = RatelColors.success,
    this.successBg = RatelColors.successBg,
    this.warning = RatelColors.warning,
    this.warningBg = RatelColors.warningBg,
    this.danger = RatelColors.danger,
    this.dangerBg = RatelColors.dangerBg,
    this.info = RatelColors.info,
    this.infoBg = RatelColors.infoBg,
  });

  final double radiusSm, radiusMd, radiusLg, radiusPill, hairline;
  final double gapSm, gapMd, gapLg;
  final Color win, energy;
  final Color success,
      successBg,
      warning,
      warningBg,
      danger,
      dangerBg,
      info,
      infoBg;

  /// Dark preset, wired into the dark ThemeData below.
  static const RatelTokens dark = RatelTokens(
    win: RatelColorsDark.win,
    energy: RatelColorsDark.energy,
    success: RatelColorsDark.success,
    successBg: RatelColorsDark.successBg,
    warning: RatelColorsDark.warning,
    warningBg: RatelColorsDark.warningBg,
    danger: RatelColorsDark.danger,
    dangerBg: RatelColorsDark.dangerBg,
    info: RatelColorsDark.info,
    infoBg: RatelColorsDark.infoBg,
  );

  @override
  RatelTokens copyWith({
    double? radiusSm,
    double? radiusMd,
    double? radiusLg,
    double? radiusPill,
    double? hairline,
    double? gapSm,
    double? gapMd,
    double? gapLg,
    Color? win,
    Color? energy,
    Color? success,
    Color? successBg,
    Color? warning,
    Color? warningBg,
    Color? danger,
    Color? dangerBg,
    Color? info,
    Color? infoBg,
  }) => RatelTokens(
    radiusSm: radiusSm ?? this.radiusSm,
    radiusMd: radiusMd ?? this.radiusMd,
    radiusLg: radiusLg ?? this.radiusLg,
    radiusPill: radiusPill ?? this.radiusPill,
    hairline: hairline ?? this.hairline,
    gapSm: gapSm ?? this.gapSm,
    gapMd: gapMd ?? this.gapMd,
    gapLg: gapLg ?? this.gapLg,
    win: win ?? this.win,
    energy: energy ?? this.energy,
    success: success ?? this.success,
    successBg: successBg ?? this.successBg,
    warning: warning ?? this.warning,
    warningBg: warningBg ?? this.warningBg,
    danger: danger ?? this.danger,
    dangerBg: dangerBg ?? this.dangerBg,
    info: info ?? this.info,
    infoBg: infoBg ?? this.infoBg,
  );

  @override
  RatelTokens lerp(covariant RatelTokens? other, double t) {
    if (other == null) return this;
    return RatelTokens(
      radiusSm: _lerpD(radiusSm, other.radiusSm, t),
      radiusMd: _lerpD(radiusMd, other.radiusMd, t),
      radiusLg: _lerpD(radiusLg, other.radiusLg, t),
      radiusPill: _lerpD(radiusPill, other.radiusPill, t),
      hairline: _lerpD(hairline, other.hairline, t),
      gapSm: _lerpD(gapSm, other.gapSm, t),
      gapMd: _lerpD(gapMd, other.gapMd, t),
      gapLg: _lerpD(gapLg, other.gapLg, t),
      win: Color.lerp(win, other.win, t)!,
      energy: Color.lerp(energy, other.energy, t)!,
      success: Color.lerp(success, other.success, t)!,
      successBg: Color.lerp(successBg, other.successBg, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      warningBg: Color.lerp(warningBg, other.warningBg, t)!,
      danger: Color.lerp(danger, other.danger, t)!,
      dangerBg: Color.lerp(dangerBg, other.dangerBg, t)!,
      info: Color.lerp(info, other.info, t)!,
      infoBg: Color.lerp(infoBg, other.infoBg, t)!,
    );
  }

  static double _lerpD(double a, double b, double t) => a + (b - a) * t;
}

/// Convenience accessors so widgets read tokens cleanly (Inc B+ kit uses these).
extension RatelTokensX on BuildContext {
  RatelTokens get tokens =>
      Theme.of(this).extension<RatelTokens>() ?? const RatelTokens();
  Color get winC => tokens.win; // reward gold ONLY
  Color get energyC => tokens.energy; // energy/XP
}

/// Fixed spacing scale (logical px) — use instead of ad-hoc numbers so the
/// rhythm is consistent across screens (Standardization Master Plan, 0.3).
/// Mirrors the RatelTokens gaps; provided as plain consts for `const` call
/// sites (EdgeInsets/SizedBox). Screens adopt these in Phase 1.
class RatelSpacing {
  RatelSpacing._();
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 24;
}

/// Semantic type-scale shortcuts over the app TextTheme (0.3) so screens use
/// named roles (display/title/body/caption) instead of raw `TextStyle(
/// fontSize: ...)`. Backed by the brand `_ratelTextTheme`.
extension RatelTypeScale on BuildContext {
  TextTheme get _textTheme => Theme.of(this).textTheme;
  TextStyle? get displayStyle => _textTheme.displaySmall;
  TextStyle? get titleStyle => _textTheme.titleLarge;
  TextStyle? get bodyStyle => _textTheme.bodyMedium;
  TextStyle? get captionStyle => _textTheme.bodySmall;
}

TextTheme _ratelTextTheme(Color text, Color muted) => TextTheme(
  displayLarge: TextStyle(
    fontFamily: kDisplayFont,
    fontWeight: FontWeight.w800,
    color: text,
  ),
  displayMedium: TextStyle(
    fontFamily: kDisplayFont,
    fontWeight: FontWeight.w800,
    color: text,
  ),
  displaySmall: TextStyle(
    fontFamily: kDisplayFont,
    fontWeight: FontWeight.w700,
    color: text,
  ),
  headlineLarge: TextStyle(
    fontFamily: kDisplayFont,
    fontWeight: FontWeight.w800,
    color: text,
  ),
  headlineMedium: TextStyle(
    fontFamily: kDisplayFont,
    fontWeight: FontWeight.w700,
    color: text,
  ),
  headlineSmall: TextStyle(
    fontFamily: kDisplayFont,
    fontWeight: FontWeight.w700,
    color: text,
  ),
  titleLarge: TextStyle(
    fontFamily: kDisplayFont,
    fontWeight: FontWeight.w700,
    color: text,
  ),
  titleMedium: TextStyle(
    fontFamily: kBodyFont,
    fontWeight: FontWeight.w700,
    color: text,
  ),
  titleSmall: TextStyle(
    fontFamily: kBodyFont,
    fontWeight: FontWeight.w600,
    color: text,
  ),
  bodyLarge: TextStyle(fontFamily: kBodyFont, height: 1.45, color: text),
  bodyMedium: TextStyle(fontFamily: kBodyFont, height: 1.4, color: text),
  bodySmall: TextStyle(fontFamily: kBodyFont, color: muted),
  labelLarge: TextStyle(
    fontFamily: kBodyFont,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.2,
    color: text,
  ),
  labelMedium: TextStyle(
    fontFamily: kBodyFont,
    fontWeight: FontWeight.w600,
    color: text,
  ),
  labelSmall: TextStyle(
    fontFamily: kBodyFont,
    fontWeight: FontWeight.w600,
    color: muted,
  ),
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
  outline: RatelColors.border,
  text: RatelColors.charcoal,
  muted: RatelColors.textMuted,
  primary: RatelColors.teal, // was honey -> teal (action)
  secondary: RatelColors.honey, // was teal -> honey (brand)
  error: RatelColors.danger, // was coral -> danger
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
  primary: RatelColorsDark.teal, // was honey -> teal (action)
  secondary: RatelColorsDark.honey, // was teal -> honey (brand)
  error: RatelColorsDark.danger, // was coral -> danger
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
    extensions: <ThemeExtension<dynamic>>[
      p.brightness == Brightness.dark ? RatelTokens.dark : const RatelTokens(),
    ],
    appBarTheme: AppBarTheme(
      backgroundColor: p.surface,
      foregroundColor: p.text,
      elevation: 0,
      titleTextStyle: TextStyle(
        fontFamily: kDisplayFont,
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: p.text,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: p.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: const TextStyle(
          fontFamily: kBodyFont,
          fontWeight: FontWeight.w700,
          fontSize: 16,
        ),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: p.primary,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: const TextStyle(
          fontFamily: kBodyFont,
          fontWeight: FontWeight.w700,
          fontSize: 16,
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: p.text,
        side: BorderSide(color: p.outline, width: 0.5),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: const TextStyle(
          fontFamily: kBodyFont,
          fontWeight: FontWeight.w700,
          fontSize: 15,
        ),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: p.secondary,
        textStyle: const TextStyle(
          fontFamily: kBodyFont,
          fontWeight: FontWeight.w700,
          fontSize: 15,
        ),
      ),
    ),
    cardTheme: CardThemeData(
      color: p.surface,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: const BorderRadius.all(Radius.circular(16)),
        side: BorderSide(color: p.border, width: 0.5),
      ),
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: p.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(20)),
      ),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: p.surface,
      indicatorColor: p.primary.withValues(alpha: 0.16),
      labelTextStyle: WidgetStatePropertyAll(
        TextStyle(
          fontFamily: kBodyFont,
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: p.text,
        ),
      ),
      iconTheme: WidgetStateProperty.resolveWith(
        (Set<WidgetState> states) => IconThemeData(
          color: states.contains(WidgetState.selected) ? p.primary : p.muted,
        ),
      ),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: p.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: p.outline, width: 0.5),
      ),
      labelStyle: TextStyle(
        fontFamily: kBodyFont,
        fontWeight: FontWeight.w600,
        color: p.text,
      ),
    ),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      backgroundColor: p.snackBg,
      contentTextStyle: TextStyle(
        fontFamily: kBodyFont,
        fontSize: 14,
        color: p.snackText,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith(
        (Set<WidgetState> states) =>
            states.contains(WidgetState.selected) ? Colors.white : null,
      ),
      trackColor: WidgetStateProperty.resolveWith(
        (Set<WidgetState> states) =>
            states.contains(WidgetState.selected) ? p.secondary : null,
      ),
    ),
    progressIndicatorTheme: ProgressIndicatorThemeData(color: p.primary),
    listTileTheme: ListTileThemeData(iconColor: p.muted),
    dividerTheme: DividerThemeData(color: p.border, thickness: 0.5),
  );
}

ThemeData ratelTheme() => _buildTheme(_light);
ThemeData ratelDarkTheme() => _buildTheme(_dark);
