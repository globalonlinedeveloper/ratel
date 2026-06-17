import 'package:flutter/material.dart';

/// Ratel design tokens — the ONLY file where raw hex colours live (charter §0.3).
/// Sourced from the redesign mocks (Ratel-UI-Screens). teal = primary/action,
/// honey = brand/wordmark only, win/energy gold = reward + energy economy.

const String kDisplayFont = 'Baloo2'; // headings (font assets added later; falls back)
const String kBodyFont = 'NunitoSans'; // body copy

/// Light-mode anchors + shared accents.
class RatelColors {
  RatelColors._();
  static const Color background = Color(0xFFFFFFFF);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surface2 = Color(0xFFF4F4F1);
  static const Color page = Color(0xFFECEAE2);
  static const Color text = Color(0xFF2C2C2A);
  static const Color textSecondary = Color(0xFF5F5E5A);
  static const Color textMuted = Color(0xFF888780);
  static const Color teal = Color(0xFF0F6E56);
  static const Color honey = Color(0xFFC77D2E);
  static const Color coral = Color(0xFFD85A30);
  static const Color win = Color(0xFFEF9F27);
  static const Color energy = Color(0xFFEF9F27);
  static const Color hearts = Color(0xFFD4537E);
  static const Color info = Color(0xFF185FA5);
  static const Color infoBg = Color(0xFFE6F1FB);
  static const Color success = Color(0xFF0F6E56);
  static const Color successBg = Color(0xFFE1F5EE);
  static const Color warning = Color(0xFF854F0B);
  static const Color warningBg = Color(0xFFFAEEDA);
  static const Color danger = Color(0xFFA32D2D);
  static const Color dangerBg = Color(0xFFFCEBEB);
  static const Color border = Color(0xFFE3E1DA);
}

/// Dark-mode palette.
class RatelColorsDark {
  RatelColorsDark._();
  static const Color background = Color(0xFF201E1C);
  static const Color surface = Color(0xFF191817);
  static const Color surface2 = Color(0xFF34312C);
  static const Color page = Color(0xFF34312C);
  static const Color text = Color(0xFFECEAE2);
  static const Color textSecondary = Color(0xFFA5A29B);
  static const Color textMuted = Color(0xFF807D77);
  static const Color teal = Color(0xFF27AE83);
  static const Color honey = Color(0xFFD08A3C);
  static const Color coral = Color(0xFFD85A30);
  static const Color win = Color(0xFFEF9F27);
  static const Color energy = Color(0xFFEF9F27);
  static const Color hearts = Color(0xFFD4537E);
  static const Color info = Color(0xFF5FA0E0);
  static const Color infoBg = Color(0xFF1E2E3F);
  static const Color success = Color(0xFF27AE83);
  static const Color successBg = Color(0xFF1B3A30);
  static const Color warning = Color(0xFFD08A3C);
  static const Color warningBg = Color(0xFF3A301F);
  static const Color danger = Color(0xFFE06A66);
  static const Color dangerBg = Color(0xFF3A1F1F);
  static const Color border = Color(0xFF383530);
}

/// Immersive AI voice-call palette (forced dark, theme-independent). Lives in
/// the design system — the only place these raw values are allowed (§0.3).
class RatelCall {
  RatelCall._();
  static const Color bg = Color(0xFF10302A);
  static const Color avatar = Color(0xFF1D9E75);
  static const Color wave = Color(0xFF5DCAA5);
  static const Color caption = Color(0xFF9FE1CB);
}

/// Streak-Society / "kind-by-design" purple accents (gamification surfaces).
/// Raw values allowed only here in the design system (§0.3).
class RatelSociety {
  RatelSociety._();
  static const Color purple = Color(0xFF7B5EA7);
  static const Color purpleDeep = Color(0xFF534AB7);
  static const Color purpleText = Color(0xFF3C3489);
  static const Color purpleBg = Color(0xFFEEEDFE);
}

/// Spacing scale (4/8/12/16/24).
class RatelSpacing {
  RatelSpacing._();
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 24;
}

/// Brightness-aware non-colour + semantic tokens carried on the theme.
@immutable
class RatelTokens extends ThemeExtension<RatelTokens> {
  const RatelTokens({
    this.radiusSm = 8,
    this.radiusMd = 12,
    this.radiusLg = 16,
    this.radiusPill = 999,
    this.hairline = 0.5,
    required this.primary,
    required this.brand,
    required this.coral,
    required this.win,
    required this.energy,
    required this.hearts,
    required this.text,
    required this.textMuted,
    required this.surface,
    required this.surface2,
    required this.page,
    required this.border,
    required this.info,
    required this.infoBg,
    required this.success,
    required this.successBg,
    required this.warning,
    required this.warningBg,
    required this.danger,
    required this.dangerBg,
  });

  final double radiusSm;
  final double radiusMd;
  final double radiusLg;
  final double radiusPill;
  final double hairline;
  final Color primary;
  final Color brand;
  final Color coral;
  final Color win;
  final Color energy;
  final Color hearts;
  final Color text;
  final Color textMuted;
  final Color surface;
  final Color surface2;
  final Color page;
  final Color border;
  final Color info;
  final Color infoBg;
  final Color success;
  final Color successBg;
  final Color warning;
  final Color warningBg;
  final Color danger;
  final Color dangerBg;

  static const RatelTokens light = RatelTokens(
    primary: RatelColors.teal,
    brand: RatelColors.honey,
    coral: RatelColors.coral,
    win: RatelColors.win,
    energy: RatelColors.energy,
    hearts: RatelColors.hearts,
    text: RatelColors.text,
    textMuted: RatelColors.textMuted,
    surface: RatelColors.surface,
    surface2: RatelColors.surface2,
    page: RatelColors.page,
    border: RatelColors.border,
    info: RatelColors.info,
    infoBg: RatelColors.infoBg,
    success: RatelColors.success,
    successBg: RatelColors.successBg,
    warning: RatelColors.warning,
    warningBg: RatelColors.warningBg,
    danger: RatelColors.danger,
    dangerBg: RatelColors.dangerBg,
  );

  static const RatelTokens dark = RatelTokens(
    primary: RatelColorsDark.teal,
    brand: RatelColorsDark.honey,
    coral: RatelColorsDark.coral,
    win: RatelColorsDark.win,
    energy: RatelColorsDark.energy,
    hearts: RatelColorsDark.hearts,
    text: RatelColorsDark.text,
    textMuted: RatelColorsDark.textMuted,
    surface: RatelColorsDark.surface,
    surface2: RatelColorsDark.surface2,
    page: RatelColorsDark.page,
    border: RatelColorsDark.border,
    info: RatelColorsDark.info,
    infoBg: RatelColorsDark.infoBg,
    success: RatelColorsDark.success,
    successBg: RatelColorsDark.successBg,
    warning: RatelColorsDark.warning,
    warningBg: RatelColorsDark.warningBg,
    danger: RatelColorsDark.danger,
    dangerBg: RatelColorsDark.dangerBg,
  );

  @override
  RatelTokens copyWith({
    double? radiusSm,
    double? radiusMd,
    double? radiusLg,
    double? radiusPill,
    double? hairline,
    Color? primary,
    Color? brand,
    Color? coral,
    Color? win,
    Color? energy,
    Color? hearts,
    Color? text,
    Color? textMuted,
    Color? surface,
    Color? surface2,
    Color? page,
    Color? border,
    Color? info,
    Color? infoBg,
    Color? success,
    Color? successBg,
    Color? warning,
    Color? warningBg,
    Color? danger,
    Color? dangerBg,
  }) {
    return RatelTokens(
      radiusSm: radiusSm ?? this.radiusSm,
      radiusMd: radiusMd ?? this.radiusMd,
      radiusLg: radiusLg ?? this.radiusLg,
      radiusPill: radiusPill ?? this.radiusPill,
      hairline: hairline ?? this.hairline,
      primary: primary ?? this.primary,
      brand: brand ?? this.brand,
      coral: coral ?? this.coral,
      win: win ?? this.win,
      energy: energy ?? this.energy,
      hearts: hearts ?? this.hearts,
      text: text ?? this.text,
      textMuted: textMuted ?? this.textMuted,
      surface: surface ?? this.surface,
      surface2: surface2 ?? this.surface2,
      page: page ?? this.page,
      border: border ?? this.border,
      info: info ?? this.info,
      infoBg: infoBg ?? this.infoBg,
      success: success ?? this.success,
      successBg: successBg ?? this.successBg,
      warning: warning ?? this.warning,
      warningBg: warningBg ?? this.warningBg,
      danger: danger ?? this.danger,
      dangerBg: dangerBg ?? this.dangerBg,
    );
  }

  @override
  RatelTokens lerp(covariant RatelTokens? other, double t) {
    if (other == null) return this;
    return RatelTokens(
      radiusSm: _d(radiusSm, other.radiusSm, t),
      radiusMd: _d(radiusMd, other.radiusMd, t),
      radiusLg: _d(radiusLg, other.radiusLg, t),
      radiusPill: _d(radiusPill, other.radiusPill, t),
      hairline: _d(hairline, other.hairline, t),
      primary: Color.lerp(primary, other.primary, t)!,
      brand: Color.lerp(brand, other.brand, t)!,
      coral: Color.lerp(coral, other.coral, t)!,
      win: Color.lerp(win, other.win, t)!,
      energy: Color.lerp(energy, other.energy, t)!,
      hearts: Color.lerp(hearts, other.hearts, t)!,
      text: Color.lerp(text, other.text, t)!,
      textMuted: Color.lerp(textMuted, other.textMuted, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      surface2: Color.lerp(surface2, other.surface2, t)!,
      page: Color.lerp(page, other.page, t)!,
      border: Color.lerp(border, other.border, t)!,
      info: Color.lerp(info, other.info, t)!,
      infoBg: Color.lerp(infoBg, other.infoBg, t)!,
      success: Color.lerp(success, other.success, t)!,
      successBg: Color.lerp(successBg, other.successBg, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      warningBg: Color.lerp(warningBg, other.warningBg, t)!,
      danger: Color.lerp(danger, other.danger, t)!,
      dangerBg: Color.lerp(dangerBg, other.dangerBg, t)!,
    );
  }

  static double _d(double a, double b, double t) => a + (b - a) * t;
}

/// Ergonomic token + brightness access from a BuildContext.
extension RatelThemeX on BuildContext {
  bool get isDark => Theme.of(this).brightness == Brightness.dark;
  RatelTokens get tokens =>
      Theme.of(this).extension<RatelTokens>() ?? RatelTokens.light;
  Color get textC => tokens.text;
  Color get mutedC => tokens.textMuted;
  Color get surfaceC => tokens.surface;
  Color get surface2C => tokens.surface2;
  Color get pageC => tokens.page;
  Color get borderC => tokens.border;
  Color get primaryC => tokens.primary;
  Color get brandC => tokens.brand;
  Color get winC => tokens.win;
  Color get energyC => tokens.energy;
}
