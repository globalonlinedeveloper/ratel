import 'dart:math';
import 'package:flutter/material.dart';

/// A one-shot confetti burst. Drop it in a [Stack] above your content; it
/// animates once on mount, then rests. Pure Flutter — no packages, and it
/// ignores pointers so buttons underneath stay tappable.
class ConfettiBurst extends StatefulWidget {
  final int count;
  final Duration duration;
  const ConfettiBurst({
    super.key,
    this.count = 90,
    this.duration = const Duration(milliseconds: 1500),
  });

  @override
  State<ConfettiBurst> createState() => _ConfettiBurstState();
}

class _ConfettiBurstState extends State<ConfettiBurst>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c;
  late final List<_Particle> _particles;

  @override
  void initState() {
    super.initState();
    final rnd = Random();
    const colors = [
      Color(0xFFC77D2E), // honey
      Color(0xFF1D9E75), // teal
      Color(0xFFD85A30), // coral
      Color(0xFFD4537E), // hearts pink
      Color(0xFFF2C14E), // gold
      Color(0xFF378ADD), // blue
    ];
    _particles = List.generate(widget.count, (_) {
      final angle = rnd.nextDouble() * 2 * pi;
      final speed = 0.55 + rnd.nextDouble() * 0.95;
      return _Particle(
        vx: cos(angle) * speed,
        vy: sin(angle) * speed - (0.55 + rnd.nextDouble() * 0.7),
        color: colors[rnd.nextInt(colors.length)],
        size: 6 + rnd.nextDouble() * 9,
        rot: rnd.nextDouble() * 2 * pi,
        spin: (rnd.nextDouble() - 0.5) * 0.5,
      );
    });
    _c = AnimationController(vsync: this, duration: widget.duration)..forward();
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: AnimatedBuilder(
        animation: _c,
        builder: (context, _) => CustomPaint(
          painter: _ConfettiPainter(_particles, _c.value),
          size: Size.infinite,
        ),
      ),
    );
  }
}

class _Particle {
  final double vx, vy, size, rot, spin;
  final Color color;
  _Particle({
    required this.vx,
    required this.vy,
    required this.color,
    required this.size,
    required this.rot,
    required this.spin,
  });
}

class _ConfettiPainter extends CustomPainter {
  final List<_Particle> particles;
  final double t; // 0..1 animation progress
  _ConfettiPainter(this.particles, this.t);

  @override
  void paint(Canvas canvas, Size size) {
    final origin = Offset(size.width / 2, size.height * 0.30);
    final spread = size.shortestSide * 0.95;
    const gravity = 2.3;
    final paint = Paint();
    for (final p in particles) {
      final dx = p.vx * t * spread;
      final dy = (p.vy * t + 0.5 * gravity * t * t) * spread;
      final pos = origin + Offset(dx, dy);
      paint.color = p.color.withValues(alpha: (1.0 - t).clamp(0.0, 1.0));
      canvas.save();
      canvas.translate(pos.dx, pos.dy);
      canvas.rotate(p.rot + p.spin * t * 28);
      canvas.drawRect(
        Rect.fromCenter(
            center: Offset.zero, width: p.size, height: p.size * 0.6),
        paint,
      );
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _ConfettiPainter old) => old.t != t;
}
