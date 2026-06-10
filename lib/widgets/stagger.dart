import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../theme.dart';

/// Staggered entrance (fade + small slide-up) for list items. The delay is
/// driven by an Interval on one controller (no timers), capped so deep lists
/// never feel slow. Instant under reduce-motion; never blocks hit-testing.
class StaggeredIn extends StatefulWidget {
  const StaggeredIn({super.key, required this.index, required this.child});
  final int index;
  final Widget child;

  @override
  State<StaggeredIn> createState() => _StaggeredInState();
}

class _StaggeredInState extends State<StaggeredIn>
    with SingleTickerProviderStateMixin {
  static const int _stepMs = 45;
  static const int _showMs = 240;
  late final int _delayMs = math.min(widget.index, 8) * _stepMs;
  late final AnimationController _c = AnimationController(
      vsync: this, duration: Duration(milliseconds: _delayMs + _showMs));
  late final Animation<double> _t = CurvedAnimation(
    parent: _c,
    curve: Interval(_delayMs / (_delayMs + _showMs), 1, curve: Curves.easeOut),
  );

  @override
  void initState() {
    super.initState();
    _c.forward();
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (context.reduceMotion) return widget.child;
    return FadeTransition(
      opacity: _t,
      child: SlideTransition(
        position: Tween<Offset>(begin: const Offset(0, 0.06), end: Offset.zero)
            .animate(_t),
        child: widget.child,
      ),
    );
  }
}
