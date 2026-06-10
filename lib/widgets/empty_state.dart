import 'package:flutter/material.dart';
import '../theme.dart';
import 'ratel_mascot.dart';

/// Mascot-led empty state: friendly, on-brand, never a bare "no data".
class RatelEmptyState extends StatelessWidget {
  const RatelEmptyState({
    super.key,
    this.pose = RatelPose.encourage,
    required this.title,
    required this.subtitle,
  });

  final RatelPose pose;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(28, 20, 28, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RatelMascot(pose: pose, size: 84),
            const SizedBox(height: 12),
            Text(title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                    fontFamily: kDisplayFont,
                    fontSize: 17,
                    fontWeight: FontWeight.w700)),
            const SizedBox(height: 6),
            Text(subtitle,
                textAlign: TextAlign.center,
                style: TextStyle(color: context.mutedC, fontSize: 13.5)),
          ],
        ),
      ),
    );
  }
}
