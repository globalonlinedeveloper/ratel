import 'package:flutter/material.dart';

import '../art.dart';
import 'mascot_anim.dart';
import 'ratel_art.dart';
import 'ratel_mascot.dart';

/// Lesson-complete hero badger. Inc 142 — the FIRST adoption of the remote
/// emotion-art set (Inc 140 resolver): when the `art_manifest` has the matching
/// emotion cell it renders that (cached remote image, bundled-static fallback);
/// offline or before the manifest loads it keeps the bundled action animation,
/// so there is never a regression. Rendered only when motion is allowed — the
/// caller shows a static pose under reduce-motion.
class CompletionMascot extends StatelessWidget {
  const CompletionMascot({super.key, required this.perfect, this.size = 132});

  final bool perfect;
  final double size;

  @override
  Widget build(BuildContext context) {
    final String emo = perfect ? 'emo_proud' : 'emo_excited';
    if (Art.instance.urlFor(emo) != null) {
      return RatelArt(
        emo,
        width: size,
        height: size,
        fallbackAsset:
            'assets/images/ratel-${perfect ? 'proud' : 'celebrate'}.webp',
      );
    }
    return RatelActionAnim(
      action: perfect ? 'perfect' : 'jump',
      fallbackPose: RatelPose.celebrate,
      size: size,
    );
  }
}
