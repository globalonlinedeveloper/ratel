import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../config.dart';
import '../milestones.dart';
import '../strings.dart';
import '../theme.dart';

/// Month grid of practice days (from xp_events) — makes the streak VISIBLE.
/// [activeDays] is injectable for tests; in the app it loads itself.
class StreakCalendar extends StatefulWidget {
  const StreakCalendar({super.key, this.activeDays});

  final Set<int>? activeDays; // day-of-month numbers (test injection)

  @override
  State<StreakCalendar> createState() => _StreakCalendarState();
}

class _StreakCalendarState extends State<StreakCalendar> {
  Set<int> _active = {};

  @override
  void initState() {
    super.initState();
    if (widget.activeDays != null) {
      _active = widget.activeDays!;
    } else {
      _load();
    }
  }

  Future<void> _load() async {
    if (!Config.hasSupabase) return;
    try {
      final c = Supabase.instance.client;
      final uid = c.auth.currentUser?.id;
      if (uid == null) return;
      final now = DateTime.now();
      final first = DateTime(now.year, now.month, 1);
      final rows = await c
          .from('xp_events')
          .select('created_at')
          .eq('user_id', uid)
          .gte('created_at', first.toIso8601String());
      final days = <int>{};
      for (final r in rows) {
        final d = DateTime.tryParse((r['created_at'] ?? '').toString());
        if (d != null) days.add(d.toLocal().day);
      }
      if (mounted) setState(() => _active = days);
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final daysInMonth = DateTime(now.year, now.month + 1, 0).day;
    final leading = DateTime(now.year, now.month, 1).weekday % 7; // Sun=0
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 8),
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
              const Icon(Icons.calendar_month,
                  size: 18, color: RatelColors.coral),
              const SizedBox(width: 8),
              Text(
                  S.instance
                      .t('month_practice', '{m} practice')
                      .replaceAll('{m}',
                          monthNameFor(now, S.instance.locale)),
                  style: const TextStyle(
                      fontWeight: FontWeight.w700, fontSize: 14)),
            ],
          ),
          const SizedBox(height: 10),
          GridView.count(
            crossAxisCount: 7,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 4,
            crossAxisSpacing: 4,
            children: [
              for (final d in const ['S', 'M', 'T', 'W', 'T', 'F', 'S'])
                Center(
                    child: Text(d,
                        style: const TextStyle(
                            fontSize: 10, color: RatelColors.textMuted))),
              for (int i = 0; i < leading; i++) const SizedBox.shrink(),
              for (int day = 1; day <= daysInMonth; day++)
                _DayCell(
                    day: day,
                    active: _active.contains(day),
                    isToday: day == now.day),
            ],
          ),
        ],
      ),
    );
  }
}

class _DayCell extends StatelessWidget {
  const _DayCell(
      {required this.day, required this.active, required this.isToday});

  final int day;
  final bool active;
  final bool isToday;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: active ? RatelColors.coral : Colors.transparent,
        shape: BoxShape.circle,
        border: isToday && !active
            ? Border.all(color: RatelColors.coral, width: 1.5)
            : null,
      ),
      alignment: Alignment.center,
      child: Text('$day',
          style: TextStyle(
              fontSize: 10,
              fontWeight: active ? FontWeight.w700 : FontWeight.w400,
              color: active ? Colors.white : context.textC)),
    );
  }
}
