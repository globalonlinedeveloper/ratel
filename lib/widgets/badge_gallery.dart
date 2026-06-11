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

  static const _assets = {
    'Monthly Quester': 'assets/images/badge-quester.webp',
    'Quest Devotee': 'assets/images/badge-devotee.webp',
    'Perfect Week': 'assets/images/badge-pweek.webp',
    'Week after Week': 'assets/images/badge-wweek.webp',
    'Quick Thinker': 'assets/images/badge-quick.webp',
    'Lightning Badger': 'assets/images/badge-lightning.webp',
  };

  static const _grey = ColorFilter.matrix(<double>[
    0.2126, 0.7152, 0.0722, 0, 0,
    0.2126, 0.7152, 0.0722, 0, 0,
    0.2126, 0.7152, 0.0722, 0, 0,
    0, 0, 0, 1, 0,
  ]);

  /// Medallion art by label; greyscale+dim when locked; the old
  /// icon remains as the errorBuilder fallback.
  Widget _art(MonthBadge b) {
    final fallback = Icon(_icons[b.label] ?? Icons.star,
        size: 16,
        color: b.earned ? RatelColors.honey : RatelColors.textMuted);
    final path = _assets[b.label];
    if (path == null) return fallback;
    final img = Image.asset(path,
        width: 22, height: 22, errorBuilder: (_, __, ___) => fallback);
    if (b.earned) return img;
    return Opacity(
        opacity: 0.45,
        child: ColorFiltered(colorFilter: _grey, child: img));
  }

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
                          _art(b),
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
