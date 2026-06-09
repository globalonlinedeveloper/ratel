import 'dart:math' as math;
import 'package:flutter/material.dart';

/// The eight Ratel animation states (each maps to an asset file).
enum RatelPose { idle, wave, celebrate, encourage, think, oops, speak, point }

/// The fearless honey badger mascot — alive with idle breathing and a
/// squash-and-stretch "pop" whenever the pose changes. Pure Flutter, GPU-light.
class RatelMascot extends StatefulWidget {
  final RatelPose pose;
  final double size;
  const RatelMascot({super.key, this.pose = RatelPose.idle, this.size = 96});

  @override
  State<RatelMascot> createState() => _RatelMascotState();
}

class _RatelMascotState extends State<RatelMascot>
    with TickerProviderStateMixin {
  late final AnimationController _breath;
  late final AnimationController _pop;

  @override
  void initState() {
    super.initState();
    _breath = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 2600))
      ..repeat(reverse: true);
    _pop = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 480), value: 1);
  }

  @override
  void didUpdateWidget(RatelMascot oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.pose != widget.pose) _pop.forward(from: 0);
  }

  @override
  void dispose() {
    _breath.dispose();
    _pop.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: Listenable.merge([_breath, _pop]),
        builder: (context, child) {
          final breath = math.sin(_breath.value * math.pi); // 0..1..0
          // Single tall pulse on pose change, settling back to rest.
          final stretch = math.sin(_pop.value * math.pi) * (1 - _pop.value);
          final scaleX = (1 - 0.012 * breath) - 0.10 * stretch;
          final scaleY = (1 + 0.020 * breath) + 0.18 * stretch;
          return Transform.translate(
            offset: Offset(0, -2.0 * breath),
            child: Transform.scale(
              scaleX: scaleX,
              scaleY: scaleY,
              alignment: Alignment.bottomCenter,
              child: child,
            ),
          );
        },
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 220),
          child: Image.asset(
            'assets/images/ratel-${widget.pose.name}.webp',
            key: ValueKey<RatelPose>(widget.pose),
            height: widget.size,
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }
}
