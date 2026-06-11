import 'dart:async';

import 'package:flutter/material.dart';

import '../app_state.dart';
import '../screens/paywall_screen.dart';
import '../theme.dart';
import '../widgets/mascot_anim.dart';
import '../widgets/transitions.dart';
import '../widgets/ratel_mascot.dart';

/// Out-of-hearts bottom sheet: regeneration countdown + PRACTICE to earn a
/// heart (kind path) + Pro (unlimited). Replaces the old hard dead end.
Future<void> showHeartsSheet(BuildContext context,
    {VoidCallback? onPractice}) {
  return showModalBottomSheet(
    context: context,
    showDragHandle: true,
    builder: (ctx) => _HeartsSheet(onPractice: onPractice),
  );
}

class _HeartsSheet extends StatefulWidget {
  const _HeartsSheet({this.onPractice});

  final VoidCallback? onPractice;

  @override
  State<_HeartsSheet> createState() => _HeartsSheetState();
}

class _HeartsSheetState extends State<_HeartsSheet> {
  Timer? _tick;

  @override
  void initState() {
    super.initState();
    appState.applyHeartRegen();
    _tick = Timer.periodic(const Duration(seconds: 1), (_) {
      appState.applyHeartRegen();
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _tick?.cancel();
    super.dispose();
  }

  String _fmt(Duration d) {
    final h = d.inHours;
    final m = d.inMinutes % 60;
    final s = d.inSeconds % 60;
    return h > 0
        ? '$h:${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}'
        : '$m:${s.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final next = appState.nextHeartIn;
    if (appState.hearts > 0) {
      // regenerated while the sheet was open — let them through
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) Navigator.of(context).maybePop();
      });
    }
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 4, 24, 28),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const RatelActionAnim(
              action: 'tired', fallbackPose: RatelPose.oops, size: 84),
          const SizedBox(height: 10),
          const Text("You're out of hearts",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
          const SizedBox(height: 6),
          Text(
              next == null
                  ? 'Hearts are back!'
                  : 'Next heart in ${_fmt(next)}',
              style: const TextStyle(color: RatelColors.textMuted)),
          const SizedBox(height: 18),
          FilledButton.icon(
            style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(48)),
            onPressed: () {
              Navigator.of(context).pop();
              widget.onPractice?.call();
            },
            icon: const Icon(Icons.fitness_center),
            label: const Text('Practice mistakes — earn a heart'),
          ),
          const SizedBox(height: 10),
          OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
                minimumSize: const Size.fromHeight(48)),
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context)
                  .push(ratelRoute(const PaywallScreen()));
            },
            icon: const Icon(Icons.favorite, color: RatelColors.hearts),
            label: const Text('Ratel Pro — unlimited hearts'),
          ),
        ],
      ),
    );
  }
}
