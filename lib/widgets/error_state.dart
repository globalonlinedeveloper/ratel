import 'package:flutter/material.dart';
import 'ratel_mascot.dart';
import '../theme.dart';

/// Mascot-led error state: a friendly "something went wrong" with a retry —
/// never a raw/blank error screen. The third of the three mandatory
/// data-screen states (loading = `skeleton.dart`, empty = `RatelEmptyState`,
/// error = this), per the Standardization Master Plan (Pillar A).
///
/// Pass localized copy (`S.t(...)`) at the call site when adopting on a
/// screen (Phase 1); the English defaults keep it usable as a drop-in.
class ErrorState extends StatelessWidget {
  const ErrorState({
    super.key,
    this.pose = RatelPose.oops,
    this.title = 'Something went wrong',
    this.message = 'That did not load. Give it another try.',
    this.retryLabel = 'Try again',
    required this.onRetry,
  });

  final RatelPose pose;
  final String title;
  final String message;
  final String retryLabel;
  final VoidCallback onRetry;

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
            Text(message,
                textAlign: TextAlign.center,
                style: TextStyle(color: context.mutedC, fontSize: 13.5)),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh, size: 18),
              label: Text(retryLabel),
            ),
          ],
        ),
      ),
    );
  }
}
