import 'package:flutter/material.dart';
import '../theme.dart';
import 'ratel_tone.dart';

/// Token-driven linear progress bar. Supersedes raw `LinearProgressIndicator`.
/// [value] is clamped to 0..1; [tone] sets the fill (default primary/teal).
class RatelProgressBar extends StatelessWidget {
  const RatelProgressBar({
    super.key,
    required this.value,
    this.tone = RatelTone.primary,
    this.height = 8,
  });

  final double value;
  final RatelTone tone;
  final double height;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final v = value.clamp(0.0, 1.0).toDouble();
    final radius = BorderRadius.circular(t.radiusPill);
    final track = context.isDark
        ? RatelColorsDark.surface2
        : RatelColors.surface2;
    return ClipRRect(
      borderRadius: radius,
      child: Stack(
        children: [
          Container(height: height, color: track),
          FractionallySizedBox(
            widthFactor: v,
            child: Container(
              height: height,
              decoration: BoxDecoration(
                color: context.toneFg(tone),
                borderRadius: radius,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
