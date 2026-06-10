import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import '../theme.dart';
import 'ratel_mascot.dart';

/// States the code-rigged puppet can express in real time.
enum PuppetState { idle, listening, talking, celebrate, wave }

/// Placement of one body part inside the puppet box (all fractions of the
/// box size). Calibrated with tool/anim/puppet_preview.py renders once the
/// generated parts arrive — the same numbers drive preview and runtime.
class PartSpec {
  const PartSpec({
    required this.cx,
    required this.cy,
    required this.w,
    required this.pivotX,
    required this.pivotY,
  });
  final double cx; // part center x
  final double cy; // part center y
  final double w; // part width
  final double pivotX; // rotation pivot inside the part (0..1)
  final double pivotY;
}

/// PLACEHOLDER RIG — replaced by calibrated values when assets/puppet/
/// ships. Order in the map = paint order (first = back).
const Map<String, PartSpec> kRatelRig = {
  'tail': PartSpec(cx: .76, cy: .64, w: .36, pivotX: .12, pivotY: .82),
  'arm_left': PartSpec(cx: .69, cy: .54, w: .20, pivotX: .30, pivotY: .12),
  'body': PartSpec(cx: .50, cy: .64, w: .54, pivotX: .50, pivotY: .92),
  'head': PartSpec(cx: .50, cy: .27, w: .50, pivotX: .50, pivotY: .88),
  'arm_right': PartSpec(cx: .31, cy: .54, w: .20, pivotX: .70, pivotY: .12),
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
  static Future<bool>? _assetsOk;

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

  @override
  void initState() {
    super.initState();
    _assetsOk ??= rootBundle
        .load('assets/puppet/body.webp')
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
  }

  @override
  void dispose() {
    _breath.dispose();
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
    switch (part) {
      case 'tail':
        return 0.14 * math.sin(_wag.value * math.pi) - 0.05;
      case 'head':
        if (widget.state == PuppetState.listening) return 0.12;
        return 0.025 * sway;
      case 'arm_right':
        if (widget.state == PuppetState.wave) return -0.35 - 0.85 * g;
        if (widget.state == PuppetState.celebrate) return -0.6 - 0.9 * g;
        return -0.04 * sway;
      case 'arm_left':
        if (widget.state == PuppetState.celebrate) return 0.6 + 0.9 * g;
        return 0.04 * sway;
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
            animation:
                Listenable.merge([_breath, _wag, _blink, _gesture, _talk]),
            builder: (context, _) {
              final double breathe = 1 + 0.015 * _breath.value;
              final double bounce = widget.state == PuppetState.celebrate
                  ? -4.0 * Curves.easeInOut.transform(_gesture.value)
                  : 0;
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
    final double w = p.w * s * (name == 'body' ? breathe : 1);
    return Positioned(
      left: p.cx * s - w / 2,
      top: p.cy * s - w / 2,
      child: Transform.rotate(
        angle: _angleFor(name),
        alignment: FractionalOffset(p.pivotX, p.pivotY),
        child: Image.asset(asset,
            width: w,
            height: w,
            filterQuality: FilterQuality.medium,
            errorBuilder: (_, _, _) => SizedBox(width: w, height: w)),
      ),
    );
  }
}
