import 'package:flutter/material.dart';
import '../theme.dart';
import '../app_state.dart';
import '../achievements.dart';

/// A grid of milestone badges, earned ones in colour and locked ones greyed.
/// Computed live from [appState] — zero DB cost.
class AchievementsView extends StatelessWidget {
  const AchievementsView({super.key});

  @override
  Widget build(BuildContext context) {
    final earned = achievements.where((a) => isEarned(a, appState)).length;
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
          Text('Achievements ($earned/${achievements.length})',
              style:
                  const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            runSpacing: 12,
            children: [for (final a in achievements) _badge(a)],
          ),
        ],
      ),
    );
  }

  Widget _badge(Achievement a) {
    final on = isEarned(a, appState);
    final color = on ? RatelColors.honey : const Color(0xFFBFBFBF);
    return Tooltip(
      message: '${a.title} — ${a.description}',
      child: SizedBox(
        width: 64,
        child: Column(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: on
                    ? RatelColors.honey.withValues(alpha: 0.14)
                    : const Color(0xFFF0F0F0),
                shape: BoxShape.circle,
                border: Border.all(color: color, width: 2),
              ),
              child: Icon(on ? a.icon : Icons.lock_outline,
                  color: color, size: 24),
            ),
            const SizedBox(height: 4),
            Text(a.title,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                    fontSize: 11,
                    height: 1.1,
                    color: on ? RatelColors.charcoal : RatelColors.textMuted,
                    fontWeight: on ? FontWeight.w600 : FontWeight.w400)),
          ],
        ),
      ),
    );
  }
}
