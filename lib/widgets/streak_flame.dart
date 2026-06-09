import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../theme.dart';

/// A small animated flame whose flicker and size scale with the current
/// streak. At streak 0 it's a dim ember; it brightens and grows as the
/// streak climbs (capped so it never dominates the UI). GPU-cheap: one
/// repainting boundary, a single looping controller, no allocations per
/// frame beyond the Path.
class StreakFlame extends StatefulWidget {
  const StreakFlame({super.key, required this.streak, this.size = 20});

  final int streak;
  final double size;

  @override
  State<StreakFlame> createState() => _StreakFlameState();
}

class _StreakFlameState extends State<StreakFlame>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1100),
  )..repeat();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Intensity 0..1 from the streak (saturates around a 14-day streak).
    final intensity = (widget.streak / 14).clamp(0.0, 1.0);
    final grow = 1.0 + 0.35 * intensity; // up to +35% size on long streaks
    final dim = widget.streak <= 0;
    return RepaintBoundary(
      child: SizedBox(
        width: widget.size * grow,
        height: widget.size * grow * 1.25,
        child: AnimatedBuilder(
          animation: _c,
          builder: (context, _) {
            return CustomPaint(
              painter: _FlamePainter(
                t: _c.value,
                intensity: dim ? 0.0 : intensity,
                dim: dim,
              ),
            );
          },
        ),
      ),
    );
  }
}

class _FlamePainter extends CustomPainter {
  _FlamePainter({required this.t, required this.intensity, required this.dim});

  final double t; // 0..1 loop phase
  final double intensity; // 0..1
  final bool dim;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width, h = size.height;
    // Flicker: a couple of out-of-phase sines so it never looks periodic.
    final flick = 0.5 +
        0.5 *
            (0.6 * math.sin(t * 2 * math.pi) +
                0.4 * math.sin(t * 2 * math.pi * 2.3 + 1.3));
    final sway = math.sin(t * 2 * math.pi * 1.7) * w * 0.06;
    final tipY = h * (0.06 - 0.04 * flick);

    // Outer flame body (teardrop) — coral→honey gradient.
    final body = Path()
      ..moveTo(w * 0.5 + sway, tipY)
      ..cubicTo(w * 0.92, h * 0.34, w * 0.86, h * 0.78, w * 0.5, h * 0.96)
      ..cubicTo(w * 0.14, h * 0.78, w * 0.08, h * 0.34, w * 0.5 + sway, tipY)
      ..close();

    final base = dim ? const Color(0xFF9AA0A6) : RatelColors.coral;
    final hot = dim ? const Color(0xFFB9BEC4) : RatelColors.honey;
    final shader = LinearGradient(
      begin: Alignment.bottomCenter,
      end: Alignment.topCenter,
      colors: [base, hot],
    ).createShader(Rect.fromLTWH(0, 0, w, h));
    canvas.drawPath(body, Paint()..shader = shader);

    if (!dim) {
      // Inner brighter core that pulses with intensity + flicker.
      final core = Path()
        ..moveTo(w * 0.5 + sway * 0.5, h * 0.34)
        ..cubicTo(w * 0.70, h * 0.5, w * 0.66, h * 0.82, w * 0.5, h * 0.9)
        ..cubicTo(w * 0.34, h * 0.82, w * 0.30, h * 0.5, w * 0.5 + sway * 0.5,
            h * 0.34)
        ..close();
      final coreColor = Color.lerp(
          const Color(0xFFFFE08A), Colors.white, intensity * flick * 0.6)!;
      canvas.drawPath(
          core, Paint()..color = coreColor.withValues(alpha: 0.85));
    }
  }

  @override
  bool shouldRepaint(_FlamePainter old) =>
      old.t != t || old.intensity != intensity || old.dim != dim;
}
