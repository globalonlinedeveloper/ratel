import 'package:flutter/material.dart';

/// The eight Ratel animation states (each maps to an asset file).
enum RatelPose { idle, wave, celebrate, encourage, think, oops, speak, point }

/// Displays the fearless honey badger mascot in a given pose.
class RatelMascot extends StatelessWidget {
  final RatelPose pose;
  final double size;
  const RatelMascot({super.key, this.pose = RatelPose.idle, this.size = 96});

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 250),
      child: Image.asset(
        'assets/images/ratel-${pose.name}.png',
        key: ValueKey<RatelPose>(pose),
        height: size,
        fit: BoxFit.contain,
      ),
    );
  }
}
