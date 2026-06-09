import 'package:flutter/widgets.dart';

/// Animates an integer when its value changes — a smooth "roll-up" instead
/// of a hard cut. Backed by TweenAnimationBuilder: when [value] changes, it
/// animates from the currently-displayed number to the new one. The first
/// build counts up from 0 (a pleasant on-mount flourish). Cheap — one tween,
/// only the Text rebuilds. Wrap in RepaintBoundary at hot use sites.
class RollingNumber extends StatelessWidget {
  const RollingNumber(
    this.value, {
    super.key,
    this.style,
    this.prefix = '',
    this.suffix = '',
    this.duration = const Duration(milliseconds: 600),
    this.curve = Curves.easeOutCubic,
  });

  final int value;
  final TextStyle? style;
  final String prefix;
  final String suffix;
  final Duration duration;
  final Curve curve;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: value.toDouble()),
      duration: duration,
      curve: curve,
      builder: (context, v, _) {
        return Text('$prefix${v.round()}$suffix', style: style);
      },
    );
  }
}
