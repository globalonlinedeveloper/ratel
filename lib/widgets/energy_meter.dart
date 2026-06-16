import 'package:flutter/material.dart';
import '../theme.dart';

/// Amber/gold energy fuel gauge — the new economy surface replacing hearts.
/// Shows [current]/[max] as pips, with an optional refill countdown hint.
class EnergyMeter extends StatelessWidget {
  const EnergyMeter({
    super.key,
    required this.current,
    required this.max,
    this.refillAt,
    this.showLabel = true,
  });

  final int current;
  final int max;
  final DateTime? refillAt;
  final bool showLabel;

  @override
  Widget build(BuildContext context) {
    final gold = context.tokens.energy;
    final empty = context.isDark
        ? RatelColorsDark.surface2
        : RatelColors.surface2;
    final cur = current.clamp(0, max);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.bolt, size: 18, color: gold),
        const SizedBox(width: 6),
        for (var i = 0; i < max; i++)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 1.5),
            child: Container(
              width: 10,
              height: 14,
              decoration: BoxDecoration(
                color: i < cur ? gold : empty,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ),
        if (showLabel) ...[
          const SizedBox(width: 8),
          Text(
            '$cur/$max',
            style: TextStyle(
              fontFamily: kBodyFont,
              fontWeight: FontWeight.w700,
              color: context.textC,
            ),
          ),
        ],
        if (refillAt != null) ...[
          const SizedBox(width: 8),
          Text(
            _refill(refillAt!),
            style: TextStyle(
              fontFamily: kBodyFont,
              fontSize: 12,
              color: context.mutedC,
            ),
          ),
        ],
      ],
    );
  }

  static String _refill(DateTime at) {
    final d = at.difference(DateTime.now());
    if (d.isNegative) return 'Full';
    final m = d.inMinutes;
    final s = d.inSeconds % 60;
    return 'Full in $m:${s.toString().padLeft(2, '0')}';
  }
}
