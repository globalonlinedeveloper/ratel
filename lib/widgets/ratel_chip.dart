import 'package:flutter/material.dart';
import '../theme.dart';
import 'ratel_tone.dart';

/// Selectable/labelled chip. Supersedes raw `Chip`/`FilterChip` and the inline
/// fix/badge chips. Selected = filled accent ([tone]); unselected = outlined
/// surface. Accent + contrast resolve through tokens (no raw hex at call site).
class RatelChip extends StatelessWidget {
  const RatelChip({
    super.key,
    required this.label,
    this.icon,
    this.selected = false,
    this.tone = RatelTone.primary,
    this.onTap,
  });

  final String label;
  final IconData? icon;
  final bool selected;
  final RatelTone tone;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final accent = context.toneFg(tone);
    final fg = selected ? _onAccent(accent) : context.textC;
    final radius = BorderRadius.circular(t.radiusPill);
    final chip = Container(
      padding: const EdgeInsets.symmetric(
        horizontal: RatelSpacing.md,
        vertical: RatelSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: selected ? accent : context.surfaceC,
        borderRadius: radius,
        border: Border.all(
          color: selected ? accent : context.borderC,
          width: t.hairline,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 16, color: fg),
            const SizedBox(width: 6),
          ],
          Flexible(
            child: Text(
              label,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: fg,
                fontWeight: FontWeight.w600,
                fontFamily: kBodyFont,
              ),
            ),
          ),
        ],
      ),
    );
    if (onTap == null) return chip;
    return InkWell(borderRadius: radius, onTap: onTap, child: chip);
  }

  /// Charcoal on light accents (gold/energy), white on dark accents (teal).
  static Color _onAccent(Color a) =>
      a.computeLuminance() > 0.5 ? RatelColors.charcoal : Colors.white;
}
