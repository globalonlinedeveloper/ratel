import 'package:flutter/material.dart';
import 'ratel_mascot.dart';
import 'mascot_anim.dart';
import '../theme.dart';
import '../app_state.dart';
import 'streak_flame.dart';

/// A welcome-back prompt to restore a recently-broken streak (costs a freeze).
/// Shows only when a repair is available; reactive to AppState.
class StreakRepairCard extends StatefulWidget {
  const StreakRepairCard({super.key});

  @override
  State<StreakRepairCard> createState() => _StreakRepairCardState();
}

class _StreakRepairCardState extends State<StreakRepairCard> {
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    appState.addListener(_onChange);
  }

  @override
  void dispose() {
    appState.removeListener(_onChange);
    super.dispose();
  }

  void _onChange() {
    if (mounted) setState(() {});
  }

  Future<void> _repair() async {
    setState(() => _busy = true);
    final ok = await appState.repairStreak();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(ok ? 'Streak restored! 🔥' : 'Could not repair right now')));
    setState(() => _busy = false);
  }

  @override
  Widget build(BuildContext context) {
    if (!appState.canRepair) return const SizedBox.shrink();
    final n = appState.brokenStreak;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: RatelColors.coral.withValues(alpha: 0.10),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: RatelColors.coral.withValues(alpha: 0.45)),
        ),
        child: Row(
          children: [
            const RatelActionAnim(
                action: 'crying',
                fallbackPose: RatelPose.oops,
                size: 54),
            const SizedBox(width: 10),
            StreakFlame(streak: n, size: 22),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Welcome back! Repair your $n-day streak?',
                      style: const TextStyle(
                          fontWeight: FontWeight.w700, fontSize: 13.5)),
                  const Text('Uses 1 streak freeze.',
                      style: TextStyle(
                          color: RatelColors.textMuted, fontSize: 12)),
                ],
              ),
            ),
            const SizedBox(width: 8),
            FilledButton(
              onPressed: _busy ? null : _repair,
              child: Text(_busy ? '…' : 'Repair'),
            ),
          ],
        ),
      ),
    );
  }
}
