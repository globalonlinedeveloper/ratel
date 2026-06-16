import 'package:flutter/material.dart';
import '../theme.dart';

/// The learn/home top stats header: streak, gems, energy (+ optional hearts).
/// Supersedes the inline streak/gems/hearts rows in home_screen/learn_tab.
/// Pills wrap (never overflow) and tint via named/semantic tokens.
class RatelHeader extends StatelessWidget {
  const RatelHeader({
    super.key,
    required this.streak,
    required this.gems,
    required this.energy,
    this.hearts,
  });

  final int streak;
  final int gems;
  final int energy;
  final int? hearts;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return Wrap(
      spacing: RatelSpacing.sm,
      runSpacing: RatelSpacing.sm,
      children: [
        _Pill(
          icon: Icons.local_fire_department,
          value: '$streak',
          accent: RatelColors.coral,
        ),
        _Pill(icon: Icons.diamond, value: '$gems', accent: t.info),
        _Pill(icon: Icons.bolt, value: '$energy', accent: t.energy),
        if (hearts != null)
          _Pill(
            icon: Icons.favorite,
            value: '$hearts',
            accent: RatelColors.hearts,
          ),
      ],
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({required this.icon, required this.value, required this.accent});

  final IconData icon;
  final String value;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final bg = Color.alphaBlend(
      accent.withValues(alpha: context.isDark ? 0.22 : 0.12),
      context.surfaceC,
    );
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(context.tokens.radiusPill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: accent),
          const SizedBox(width: 4),
          Text(
            value,
            style: TextStyle(
              fontFamily: kBodyFont,
              fontWeight: FontWeight.w700,
              color: context.textC,
            ),
          ),
        ],
      ),
    );
  }
}
