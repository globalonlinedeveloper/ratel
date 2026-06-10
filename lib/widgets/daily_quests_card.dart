import 'package:flutter/material.dart';
import '../theme.dart';
import '../app_state.dart';
import '../daily_quests.dart';

/// Today's quests with live progress — a fresh daily checklist that gives a
/// concrete reason to play (the "action" in the habit loop).
class DailyQuestsCard extends StatelessWidget {
  const DailyQuestsCard({super.key});

  @override
  Widget build(BuildContext context) {
    final quests = questsForToday();
    final done = quests.where((q) => questDone(q, appState)).length;
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      padding: const EdgeInsets.all(14),
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
              const Icon(Icons.flag_circle, color: RatelColors.honey, size: 18),
              const SizedBox(width: 6),
              Text('Daily quests ($done/${quests.length})',
                  style:
                      const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
            ],
          ),
          const SizedBox(height: 8),
          for (final q in quests) _quest(q),
        ],
      ),
    );
  }

  Widget _quest(Quest q) {
    final p = questProgress(q, appState);
    final ok = p >= q.target;
    final frac = (p / q.target).clamp(0.0, 1.0);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          Icon(ok ? Icons.check_circle : q.icon,
              size: 18, color: ok ? RatelColors.teal : RatelColors.textMuted),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(q.title,
                    style: const TextStyle(
                        fontWeight: FontWeight.w500, fontSize: 13.5)),
                const SizedBox(height: 4),
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: frac,
                    minHeight: 7,
                    backgroundColor: context.borderC,
                    color: ok ? RatelColors.teal : RatelColors.honey,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text('${p.clamp(0, q.target)}/${q.target}',
              style:
                  const TextStyle(color: RatelColors.textMuted, fontSize: 12)),
        ],
      ),
    );
  }
}
