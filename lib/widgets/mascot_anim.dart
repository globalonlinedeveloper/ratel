import 'package:flutter/material.dart';
import '../theme.dart';
import 'ratel_mascot.dart';

/// Plays a bundled AI-generated mascot action loop (animated WebP).
/// Falls back to a static pose under reduce-motion or if the asset is
/// missing, so it can never break a screen.
class RatelActionAnim extends StatelessWidget {
  const RatelActionAnim({
    super.key,
    required this.action,
    required this.fallbackPose,
    this.size = 96,
  });

  /// One of: karate, crying, sleeping, thumbsup.
  final String action;
  final RatelPose fallbackPose;
  final double size;

  @override
  Widget build(BuildContext context) {
    if (context.reduceMotion) {
      return RatelMascot(pose: fallbackPose, size: size);
    }
    return Image.asset(
      'assets/images/ratel-$action-anim.webp',
      width: size,
      height: size,
      filterQuality: FilterQuality.medium,
      errorBuilder: (_, __, ___) =>
          RatelMascot(pose: fallbackPose, size: size),
    );
  }
}
