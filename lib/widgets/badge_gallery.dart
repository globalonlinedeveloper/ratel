import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../milestones.dart';
import '../theme.dart';

/// Earned/locked badge chips from the monthly systems (quests, perfect
/// weeks, the timed best). Icon-based; generated art swaps in later.
class BadgeGallery extends StatelessWidget {
  const BadgeGallery({super.key, this.badgesOverride});

  final List<MonthBadge>? badgesOverride; // test injection

  Future<List<MonthBadge>> _load() async {
    if (badgesOverride != null) return badgesOverride!;
    try {
      final p = await SharedPreferences.getInstance();
      return monthlyBadges(
        quests: p.getInt('mquest_count') ?? 0,
        weeks: p.getInt('pweek_count') ?? 0,
        best: p.getInt('timed_best') ?? 0,
      );
    } catch (_) {
      return monthlyBadges(quests: 0, weeks: 0, best: 0);
    }
  }

  static const _icons = {
    'Monthly Quester': Icons.emoji_events_outlined,
    'Quest Devotee': Icons.emoji_events,
    'Perfect Week': Icons.local_fire_department_outlined,
    'Week after Week': Icons.local_fire_department,
    'Quick Thinker': Icons.timer_outlined,
    'Lightning Badger': Icons.flash_on,
  };

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<MonthBadge>>(
      future: _load(),
      builder: (context, snap) {
        final badges = snap.data;
        if (badges == null) return const SizedBox.shrink();
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Monthly badges',
                  style: TextStyle(
                      fontWeight: FontWeight.w800, fontSize: 15)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final b in badges)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: b.earned
                            ? context.tintC(RatelColors.honey)
                            : context.surfaceC,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                            color: b.earned
                                ? RatelColors.honey
                                : context.faintBorderC),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(_icons[b.label] ?? Icons.star,
                              size: 16,
                              color: b.earned
                                  ? RatelColors.honey
                                  : RatelColors.textMuted),
                          const SizedBox(width: 6),
                          Text(b.label,
                              style: TextStyle(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w700,
                                  color: b.earned
                                      ? context.textC
                                      : RatelColors.textMuted)),
                        ],
                      ),
                    ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
