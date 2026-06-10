import 'package:flutter/material.dart';
import 'ratel_mascot.dart';
import 'mascot_anim.dart';
import '../theme.dart';
import '../app_state.dart';

/// A compact, in-app reminder at the top of the Learn screen, driven by the
/// DB-backed streak + daily-goal data. Shows only when there's something to
/// act on — a streak about to lapse, or XP still owed today — and hides once
/// the daily goal is met. (The web substitute for a push reminder.)
class DailyNudge extends StatelessWidget {
  const DailyNudge({super.key});

  @override
  Widget build(BuildContext context) {
    final goal = appState.dailyGoalXp <= 0 ? 50 : appState.dailyGoalXp;
    final today = appState.todayXp;
    final streak = appState.streak;
    bool atRisk = false;

    IconData icon;
    Color color;
    String text;
    if (streak > 0 && today == 0) {
      atRisk = true;
      icon = Icons.local_fire_department;
      color = RatelColors.coral;
      text = 'Keep your $streak-day streak alive — finish a lesson today.';
    } else if (today < goal) {
      icon = Icons.bolt;
      color = RatelColors.honey;
      text = '${goal - today} XP to reach today\'s goal.';
    } else {
      return const SizedBox.shrink(); // goal met — nothing to nudge
    }

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.45)),
      ),
      child: Row(
        children: [
          atRisk
              ? const RatelActionAnim(
                  action: 'sleeping',
                  fallbackPose: RatelPose.think,
                  size: 44)
              : Icon(icon, color: color, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(text,
                style: TextStyle(
                    color: context.textC,
                    fontWeight: FontWeight.w500,
                    fontSize: 13.5)),
          ),
        ],
      ),
    );
  }
}
