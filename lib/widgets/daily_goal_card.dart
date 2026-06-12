import 'package:flutter/material.dart';
import '../strings.dart';
import 'ratel_mascot.dart';
import 'mascot_anim.dart';
import '../theme.dart';
import '../app_state.dart';

/// Today's progress toward the daily XP goal (profiles.daily_goal_xp + today's
/// xp_events, loaded in AppState.sync). Reads live from [appState].
class DailyGoalCard extends StatelessWidget {
  const DailyGoalCard({super.key});

  @override
  Widget build(BuildContext context) {
    final goal = appState.dailyGoalXp <= 0 ? 50 : appState.dailyGoalXp;
    final today = appState.todayXp;
    final pct = (today / goal).clamp(0.0, 1.0);
    final met = today >= goal;
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.surfaceC,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: context.borderC),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              met
                  ? const RatelActionAnim(
                      action: 'honeyjar',
                      fallbackPose: RatelPose.celebrate,
                      size: 36)
                  : const Icon(Icons.flag,
                      color: RatelColors.honey, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(S.instance.t('dg_title', 'Daily goal'),
                    style: const TextStyle(
                        fontWeight: FontWeight.w700, fontSize: 16)),
              ),
              Text('$today / $goal XP',
                  style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: met ? RatelColors.teal : RatelColors.textMuted)),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: pct,
              minHeight: 10,
              backgroundColor: context.borderC,
              color: met ? RatelColors.teal : RatelColors.honey,
            ),
          ),
          const SizedBox(height: 6),
          Text(
              met
                  ? S.instance.t('goal_reached', 'Goal reached — nice work!')
                  : S.instance
                      .t('earn_more', 'Earn {n} more XP today')
                      .replaceAll('{n}', '${goal - today}'),
              style: const TextStyle(color: RatelColors.textMuted, fontSize: 13)),
        ],
      ),
    );
  }
}
