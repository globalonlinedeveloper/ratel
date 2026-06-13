import 'package:flutter/material.dart';
import '../app_state.dart';
import '../score.dart';
import '../strings.dart';
import '../theme.dart';

/// A no-cost analytics card: overall accuracy + the SKILLS (curriculum nodes)
/// the signed-in learner is weakest at, computed from their own attempts
/// (Inc 151 — node-scoped, replacing the per-lesson `my_weak_areas` RPC so it
/// stays consistent with the node-based English Score). Renders nothing when
/// signed out or with no graded attempts yet.
class WeakAreasSummary extends StatelessWidget {
  const WeakAreasSummary({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: appState,
      builder: (context, _) {
        final tally = appState.nodeTally;
        var total = 0, correct = 0;
        for (final t in tally.values) {
          total += t.total;
          correct += t.correct;
        }
        if (total == 0) return const SizedBox.shrink();
        final acc = (correct * 100 / total).round();
        final weak = weakNodes(tally).take(3).toList();
        return Container(
          margin: const EdgeInsets.fromLTRB(16, 4, 16, 8),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: context.surfaceC,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: context.borderC),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(S.instance.t('wa_title', 'Your accuracy'),
                  style: const TextStyle(
                      fontWeight: FontWeight.w700, fontSize: 16)),
              const SizedBox(height: 4),
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text('$acc%',
                      style: TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.w800,
                          color: acc >= 80
                              ? RatelColors.teal
                              : (acc >= 60
                                  ? RatelColors.honey
                                  : RatelColors.coral))),
                  const SizedBox(width: 8),
                  Text(
                      S.instance
                          .t('wa_over', 'over {n} answers')
                          .replaceAll('{n}', '$total'),
                      style: const TextStyle(color: RatelColors.textMuted)),
                ],
              ),
              if (weak.isNotEmpty) ...[
                const SizedBox(height: 12),
                Text(S.instance.t('wa_work', 'Work on these:'),
                    style: const TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 6),
                ...weak.map((node) {
                  final t = tally[node]!;
                  final a = (t.correct * 100 / t.total).round();
                  final w = t.total - t.correct;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Row(
                      children: [
                        const Icon(Icons.trending_up,
                            color: RatelColors.coral, size: 16),
                        const SizedBox(width: 6),
                        Expanded(
                            child: Text(nodeLabel(node),
                                style: const TextStyle(
                                    fontWeight: FontWeight.w500))),
                        Text(
                            S.instance
                                .t('wa_missed', '{a}% · {n} missed')
                                .replaceAll('{a}', '$a')
                                .replaceAll('{n}', '$w'),
                            style: const TextStyle(
                                color: RatelColors.textMuted, fontSize: 13)),
                      ],
                    ),
                  );
                }),
              ],
            ],
          ),
        );
      },
    );
  }
}
