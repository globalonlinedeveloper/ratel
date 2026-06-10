import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../theme.dart';

/// A premium, web-safe "aurora": a soft base wash plus a few large,
/// slowly-drifting radial-gradient blobs. Pure CustomPainter (no fragment
/// shaders, so it renders identically on Flutter web/CanvasKit and mobile),
/// GPU-friendly, and deliberately subtle so it never competes with the
/// lesson content. Honours reduce-motion by freezing on a still frame.
class AuroraBackground extends StatefulWidget {
  const AuroraBackground({super.key, required this.child});

  final Widget child;

  @override
  State<AuroraBackground> createState() => _AuroraBackgroundState();
}

class _AuroraBackgroundState extends State<AuroraBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 22),
  );

  @override
  void initState() {
    super.initState();
    _c.repeat();
    reduceMotionNotifier.addListener(_onMotionPref);
  }

  void _onMotionPref() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    reduceMotionNotifier.removeListener(_onMotionPref);
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final reduceMotion = context.reduceMotion;
    if (reduceMotion && _c.isAnimating) {
      _c.stop();
    } else if (!reduceMotion && !_c.isAnimating) {
      _c.repeat();
    }
    return Stack(
      fit: StackFit.expand,
      children: [
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: context.isDark
                  ? const [
                      Color(0xFF171511),
                      Color(0xFF14130F),
                      Color(0xFF181410)
                    ]
                  : const [
                      Color(0xFFEDEAE0),
                      Color(0xFFE6E9E3),
                      Color(0xFFEBE5DC)
                    ],
            ),
          ),
        ),
        RepaintBoundary(
          child: AnimatedBuilder(
            animation: _c,
            builder: (context, _) => CustomPaint(
              painter: _AuroraPainter(reduceMotion ? 0.18 : _c.value),
            ),
          ),
        ),
        widget.child,
      ],
    );
  }
}

class _AuroraPainter extends CustomPainter {
  _AuroraPainter(this.t);

  final double t; // 0..1 loop phase

  void _blob(Canvas canvas, double cx, double cy, double r, Color c) {
    final rect = Rect.fromCircle(center: Offset(cx, cy), radius: r);
    final paint = Paint()
      ..shader = RadialGradient(
        colors: [c, c.withValues(alpha: 0)],
      ).createShader(rect);
    canvas.drawCircle(Offset(cx, cy), r, paint);
  }

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width, h = size.height;
    const tau = 2 * math.pi;
    // Three large, low-opacity blobs drifting on out-of-phase orbits.
    _blob(
        canvas,
        w * (0.30 + 0.15 * math.sin(t * tau)),
        h * (0.24 + 0.10 * math.cos(t * tau)),
        w * 0.55,
        RatelColors.honey.withValues(alpha: 0.10));
    _blob(
        canvas,
        w * (0.72 + 0.12 * math.cos(t * tau * 0.8)),
        h * (0.58 + 0.12 * math.sin(t * tau * 0.7)),
        w * 0.60,
        RatelColors.teal.withValues(alpha: 0.09));
    _blob(
        canvas,
        w * (0.50 + 0.10 * math.sin(t * tau * 1.3 + 1)),
        h * (0.86 + 0.08 * math.cos(t * tau)),
        w * 0.50,
        RatelColors.coral.withValues(alpha: 0.07));
  }

  @override
  bool shouldRepaint(_AuroraPainter old) => old.t != t;
}
