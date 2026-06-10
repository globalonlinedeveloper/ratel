import 'package:flutter/material.dart';
import '../theme.dart';

/// Gentle attention pulse (scale 1.0 -> 1.05) for the "current" element.
/// Freezes under reduce-motion.
class Pulse extends StatefulWidget {
  const Pulse({super.key, required this.child});
  final Widget child;

  @override
  State<Pulse> createState() => _PulseState();
}

class _PulseState extends State<Pulse> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 1100));

  @override
  void initState() {
    super.initState();
    _c.repeat(reverse: true);
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool still = context.reduceMotion;
    if (still && _c.isAnimating) _c.stop();
    if (!still && !_c.isAnimating) _c.repeat(reverse: true);
    return ScaleTransition(
      scale: Tween<double>(begin: 1.0, end: 1.05)
          .animate(CurvedAnimation(parent: _c, curve: Curves.easeInOut)),
      child: widget.child,
    );
  }
}
