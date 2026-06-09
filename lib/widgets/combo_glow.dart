import 'package:flutter/material.dart';
import '../theme.dart';

/// A warm screen-edge glow that brightens as the in-lesson correct-answer
/// combo climbs — the visual partner to the audio pitch-ladder. Deliberately
/// invisible until a real streak forms, capped low so it never competes with
/// the question. Pure CustomPainter (web-safe), non-interactive, and it ramps
/// instantly under reduce-motion.
class ComboGlow extends StatelessWidget {
  const ComboGlow({super.key, required this.combo, this.maxCombo = 5});

  final int combo;
  final int maxCombo;

  @override
  Widget build(BuildContext context) {
    final target = (combo / maxCombo).clamp(0.0, 1.0);
    final reduceMotion =
        MediaQuery.maybeOf(context)?.disableAnimations ?? false;
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: target),
      duration: Duration(milliseconds: reduceMotion ? 0 : 420),
      curve: Curves.easeOut,
      builder: (context, t, _) => CustomPaint(
        size: Size.infinite,
        painter: _ComboGlowPainter(t),
      ),
    );
  }
}

class _ComboGlowPainter extends CustomPainter {
  _ComboGlowPainter(this.t);

  final double t; // 0..1 intensity

  @override
  void paint(Canvas canvas, Size size) {
    if (t <= 0.01) return;
    final rect = Offset.zero & size;
    final color = Color.lerp(RatelColors.honey, RatelColors.coral, t)!;
    final glow = color.withValues(alpha: 0.30 * t);
    final paint = Paint()
      ..shader = RadialGradient(
        center: Alignment.center,
        radius: 0.95,
        colors: [const Color(0x00000000), glow],
        stops: const [0.62, 1.0],
      ).createShader(rect);
    canvas.drawRect(rect, paint);
  }

  @override
  bool shouldRepaint(_ComboGlowPainter old) => old.t != t;
}
