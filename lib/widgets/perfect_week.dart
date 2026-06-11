import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../app_state.dart';
import '../config.dart';
import '../milestones.dart';
import '../theme.dart';

/// Seven straight days at or above the daily goal -> +20 gems, once per
/// week. Hidden unless earned and unclaimed (no guilt when it isn't).
class PerfectWeekCard extends StatefulWidget {
  const PerfectWeekCard({super.key, this.dailyXp});

  final List<int>? dailyXp; // test injection (oldest..today, 7 entries)

  @override
  State<PerfectWeekCard> createState() => _PerfectWeekCardState();
}

class _PerfectWeekCardState extends State<PerfectWeekCard> {
  bool _earned = false;
  bool _claimedNow = false;

  @override
  void initState() {
    super.initState();
    _check();
  }

  Future<void> _check() async {
    try {
      final p = await SharedPreferences.getInstance();
      if (p.getString('pweek_done') == weekKey(DateTime.now())) return;
      List<int>? sums = widget.dailyXp;
      if (sums == null) {
        if (!Config.hasSupabase) return;
        final c = Supabase.instance.client;
        final uid = c.auth.currentUser?.id;
        if (uid == null) return;
        final since = DateTime.now()
            .subtract(const Duration(days: 7))
            .toIso8601String();
        final rows = await c
            .from('xp_events')
            .select('amount, created_at')
            .eq('user_id', uid)
            .gte('created_at', since)
            .timeout(const Duration(seconds: 5));
        final byDay = <String, int>{};
        for (final r in rows) {
          final d = (r['created_at'] ?? '').toString().substring(0, 10);
          byDay[d] = (byDay[d] ?? 0) +
              ((r['amount'] as num?)?.toInt() ?? 0);
        }
        sums = [
          for (int i = 6; i >= 0; i--)
            byDay[DateTime.now()
                    .subtract(Duration(days: i))
                    .toIso8601String()
                    .substring(0, 10)] ??
                0,
        ];
      }
      if (mounted &&
          perfectWeek(sums, appState.dailyGoalXp)) {
        setState(() => _earned = true);
      }
    } catch (_) {}
  }

  Future<void> _claim() async {
    appState.addGems(20);
    setState(() {
      _claimedNow = true;
    });
    try {
      final p = await SharedPreferences.getInstance();
      await p.setString('pweek_done', weekKey(DateTime.now()));
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    if (!_earned) return const SizedBox.shrink();
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: context.tintC(RatelColors.coral),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: context.faintBorderC),
      ),
      child: Row(
        children: [
          const Icon(Icons.local_fire_department,
              color: RatelColors.coral),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
                _claimedNow
                    ? 'Perfect Week claimed — +20 gems!'
                    : 'PERFECT WEEK! 7 days on goal.',
                style: const TextStyle(fontWeight: FontWeight.w800)),
          ),
          if (!_claimedNow)
            FilledButton(
              style: FilledButton.styleFrom(
                  backgroundColor: RatelColors.coral,
                  visualDensity: VisualDensity.compact),
              onPressed: _claim,
              child: const Text('+20 gems'),
            ),
        ],
      ),
    );
  }
}
