import 'package:flutter/material.dart';
import '../theme.dart';

/// Semantic tone for kit surfaces (cards, chips, bars, stat tiles). Resolves
/// through [RatelTokens] semantic colors + win/energy — never raw hex at the
/// call site (the design-system color contract). win/energy/primary have no
/// dedicated container token, so their background is the fg washed over the
/// surface, matching the existing `tintC` pattern (readable in both modes).
enum RatelTone {
  surface,
  page,
  primary,
  success,
  warning,
  danger,
  info,
  win,
  energy,
}

extension RatelToneResolve on BuildContext {
  /// Foreground (text / icon / fill) color for [tone].
  Color toneFg(RatelTone tone) {
    final t = tokens;
    switch (tone) {
      case RatelTone.surface:
      case RatelTone.page:
        return textC;
      case RatelTone.primary:
        return Theme.of(this).colorScheme.primary;
      case RatelTone.success:
        return t.success;
      case RatelTone.warning:
        return t.warning;
      case RatelTone.danger:
        return t.danger;
      case RatelTone.info:
        return t.info;
      case RatelTone.win:
        return t.win;
      case RatelTone.energy:
        return t.energy;
    }
  }

  /// Container/background color for [tone] (cards, filled chips).
  Color toneContainer(RatelTone tone) {
    final t = tokens;
    switch (tone) {
      case RatelTone.surface:
        return surfaceC;
      case RatelTone.page:
        return isDark ? RatelColorsDark.page : RatelColors.page;
      case RatelTone.success:
        return t.successBg;
      case RatelTone.warning:
        return t.warningBg;
      case RatelTone.danger:
        return t.dangerBg;
      case RatelTone.info:
        return t.infoBg;
      case RatelTone.primary:
      case RatelTone.win:
      case RatelTone.energy:
        return Color.alphaBlend(
          toneFg(tone).withValues(alpha: isDark ? 0.22 : 0.12),
          surfaceC,
        );
    }
  }

  /// Hairline/border color for [tone].
  Color toneBorder(RatelTone tone) {
    switch (tone) {
      case RatelTone.surface:
      case RatelTone.page:
        return borderC;
      default:
        return toneFg(tone);
    }
  }
}
