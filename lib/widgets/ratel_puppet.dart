import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import '../theme.dart';
import 'ratel_mascot.dart';

/// States the code-rigged puppet can express in real time.
enum PuppetState {
  idle,
  listening,
  talking,
  celebrate,
  wave,
  walk,
  dance,
}

/// Placement of one body part inside the puppet box (all fractions of the
/// box size). Calibrated with tool/anim/puppet_preview.py renders once the
/// generated parts arrive — the same numbers drive preview and runtime.
class PartSpec {
  const PartSpec({
    required this.cx,
    required this.cy,
    required this.w,
    required this.aspect,
    required this.pivotX,
    required this.pivotY,
  });
  final double cx; // part center x
  final double cy; // part center y
  final double w; // part width
  final double aspect; // part height / width
  final double pivotX; // rotation pivot inside the part (0..1)
  final double pivotY;
}

/// Calibrated against the generated parts via tool/anim previews
/// (2026-06-10). Order in the map = paint order (first = back).
const Map<String, PartSpec> kRatelRig = {
  'tail': PartSpec(
      cx: .74, cy: .66, w: .34, aspect: .786, pivotX: .15, pivotY: .85),
  'leg_left': PartSpec(
      cx: .620, cy: .835, w: .265, aspect: .874, pivotX: .50, pivotY: .06),
  'leg_right': PartSpec(
      cx: .379, cy: .835, w: .261, aspect: .888, pivotX: .50, pivotY: .06),
  'torso': PartSpec(
      cx: .503, cy: .562, w: .436, aspect: .883, pivotX: .50, pivotY: .90),
  'arm_left': PartSpec(
      cx: .685, cy: .565, w: .17, aspect: 1.899, pivotX: .50, pivotY: .10),
  'arm_right': PartSpec(
      cx: .315, cy: .565, w: .17, aspect: 1.899, pivotX: .50, pivotY: .10),
  'head': PartSpec(
      cx: .50, cy: .30, w: .50, aspect: .937, pivotX: .50, pivotY: .85),
};

/// Real-time skeletal mascot: breathing, blinking, tail wag, head tilt,
/// waving, celebrate bounce and mouth-flap talking — all tweened by code at
/// the display refresh rate (the Duolingo architecture, hand-rolled).
/// Falls back to the static [RatelMascot] when the puppet assets are not
/// bundled or reduce-motion is on, so it can never break a screen.
class RatelPuppet extends StatefulWidget {
  const RatelPuppet({
    super.key,
    this.state = PuppetState.idle,
    this.size = 120,
  });

  final PuppetState state;
  final double size;

  @override
  State<RatelPuppet> createState() => _RatelPuppetState();
}

class _RatelPuppetState extends State<RatelPuppet>
    with TickerProviderStateMixin {
  // Per-instance (NOT static): a static future created inside one
  // widget-test's fake-async zone never completes and would poison
  // every later test. The AssetBundle caches the bytes anyway.
  Future<bool>? _assetsOk;

  late final AnimationController _breath = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 2600))
    ..repeat(reverse: true);
  late final AnimationController _wag = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 3200))
    ..repeat(reverse: true);
  late final AnimationController _blink = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 3700))
    ..repeat();
  late final AnimationController _gesture = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 700));
  late final AnimationController _talk = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 360));
  late final AnimationController _gait = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 660));

  @override
  void initState() {
    super.initState();
    _assetsOk ??= rootBundle
        .load('assets/puppet/torso.webp')
        .then((_) => true)
        .catchError((_) => false);
    _syncState();
  }

  @override
  void didUpdateWidget(covariant RatelPuppet old) {
    super.didUpdateWidget(old);
    if (old.state != widget.state) _syncState();
  }

  void _syncState() {
    if (widget.state == PuppetState.talking) {
      _talk.repeat();
    } else {
      _talk.stop();
    }
    if (widget.state == PuppetState.wave ||
        widget.state == PuppetState.celebrate) {
      _gesture.repeat(reverse: true);
    } else {
      _gesture.animateTo(0, duration: const Duration(milliseconds: 250));
    }
    if (widget.state == PuppetState.walk ||
        widget.state == PuppetState.dance) {
      _gait.repeat();
    } else {
      _gait.stop();
    }
  }

  @override
  void dispose() {
    _breath.dispose();
    _gait.dispose();
    _wag.dispose();
    _blink.dispose();
    _gesture.dispose();
    _talk.dispose();
    super.dispose();
  }

  String _headAsset() {
    if (widget.state == PuppetState.talking && _talk.value > 0.5) {
      return 'assets/puppet/head_talk.webp';
    }
    // A 120ms blink at the end of each blink cycle.
    if (_blink.value > 0.965) return 'assets/puppet/head_blink.webp';
    return 'assets/puppet/head_neutral.webp';
  }

  double _angleFor(String part) {
    final double g = Curves.easeInOut.transform(_gesture.value);
    final double sway = math.sin(_breath.value * math.pi);
    final double step = math.sin(_gait.value * 2 * math.pi);
    final bool dancing = widget.state == PuppetState.dance;
    final bool walking = widget.state == PuppetState.walk;
    switch (part) {
      case 'leg_left':
        if (walking) return 0.24 * step;
        if (dancing) return 0.15 * step;
        return 0;
      case 'leg_right':
        if (walking) return -0.24 * step;
        if (dancing) return -0.15 * step;
        return 0;
      case 'tail':
        return 0.14 * math.sin(_wag.value * math.pi) - 0.05;
      case 'head':
        if (widget.state == PuppetState.listening) return 0.12;
        if (dancing) return 0.08 * step;
        return 0.025 * sway;
      case 'arm_right':
        if (widget.state == PuppetState.wave) return 0.5 + 1.4 * g;
        if (widget.state == PuppetState.celebrate) return 0.8 + 1.4 * g;
        if (walking) return 0.17 * step;
        if (dancing) return 0.9 + 0.25 * step;
        return 0.04 * sway;
      case 'arm_left':
        if (widget.state == PuppetState.celebrate) return -0.8 - 1.4 * g;
        if (walking) return -0.17 * step;
        if (dancing) return -0.9 + 0.25 * step;
        return -0.04 * sway;
      default:
        return 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _assetsOk,
      builder: (context, snap) {
        if (snap.data != true || context.reduceMotion) {
          return RatelMascot(
              pose: widget.state == PuppetState.celebrate
                  ? RatelPose.celebrate
                  : RatelPose.idle,
              size: widget.size);
        }
        final double s = widget.size;
        return SizedBox(
          width: s,
          height: s,
          child: AnimatedBuilder(
            animation: Listenable.merge(
                [_breath, _wag, _blink, _gesture, _talk, _gait]),
            builder: (context, _) {
              final double breathe = 1 + 0.015 * _breath.value;
              double bounce = widget.state == PuppetState.celebrate
                  ? -4.0 * Curves.easeInOut.transform(_gesture.value)
                  : 0;
              if (widget.state == PuppetState.walk) {
                bounce = -1.5 *
                    math.sin(_gait.value * 4 * math.pi).abs();
              } else if (widget.state == PuppetState.dance) {
                bounce = -3.5 *
                    math.sin(_gait.value * 4 * math.pi).abs();
              }
              return Transform.translate(
                offset: Offset(0, bounce),
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    for (final entry in kRatelRig.entries)
                      _part(entry.key, entry.value, s, breathe),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _part(String name, PartSpec p, double s, double breathe) {
    final String asset = name == 'head'
        ? _headAsset()
        : 'assets/puppet/$name.webp';
    final double w = p.w * s;
    final double h = w * p.aspect * (name == 'torso' ? breathe : 1);
    return Positioned(
      left: p.cx * s - w / 2,
      top: p.cy * s - w * p.aspect / 2,
      child: Transform.rotate(
        angle: _angleFor(name),
        alignment: FractionalOffset(p.pivotX, p.pivotY),
        child: Image.asset(asset,
            width: w,
            height: h,
            filterQuality: FilterQuality.medium,
            errorBuilder: (_, _, _) => SizedBox(width: w, height: h)),
      ),
    );
  }
}
