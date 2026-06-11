import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../app_state.dart';
import '../config.dart';
import '../flags.dart';
import '../milestones.dart';
import '../strings.dart';
import '../theme.dart';

/// One month-long arc: 'Earn N XP in June'. Pays +30 gems once per
/// month; shows quietly-proud done copy afterwards for the session.
class MonthlyQuestCard extends StatefulWidget {
  const MonthlyQuestCard({super.key, this.monthXp});

  final int? monthXp; // test injection

  @override
  State<MonthlyQuestCard> createState() => _MonthlyQuestCardState();
}

class _MonthlyQuestCardState extends State<MonthlyQuestCard> {
  int? _xp;
  bool _paidBefore = true; // assume paid until prefs say otherwise
  bool _justPaid = false;

  int get _goal => Flags.instance.intOf('monthly_xp_goal', 1000);

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final p = await SharedPreferences.getInstance();
      final bool paid =
          p.getString('mquest_done') == monthKey(DateTime.now());
      int? xp = widget.monthXp;
      if (xp == null) {
        if (!Config.hasSupabase) return;
        final c = Supabase.instance.client;
        final uid = c.auth.currentUser?.id;
        if (uid == null) return;
        final start =
            DateTime(DateTime.now().year, DateTime.now().month, 1)
                .toIso8601String();
        final rows = await c
            .from('xp_events')
            .select('amount')
            .eq('user_id', uid)
            .gte('created_at', start)
            .timeout(const Duration(seconds: 5));
        xp = 0;
        for (final r in rows) {
          xp = xp! + ((r['amount'] as num?)?.toInt() ?? 0);
        }
      }
      if (mounted) {
        setState(() {
          _xp = xp;
          _paidBefore = paid;
        });
      }
    } catch (_) {}
  }

  Future<void> _claim() async {
    appState.addGems(30);
    setState(() => _justPaid = true);
    try {
      final p = await SharedPreferences.getInstance();
      await p.setString('mquest_done', monthKey(DateTime.now()));
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final xp = _xp;
    if (xp == null || (_paidBefore && !_justPaid)) {
      return const SizedBox.shrink();
    }
    final bool earned = xp >= _goal;
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: context.tintC(RatelColors.honey),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: context.faintBorderC),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.emoji_events_outlined,
                  color: RatelColors.honey, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                    _justPaid
                        ? 'Monthly quest complete — +30 gems!'
                        : S.instance
                            .t('monthly_quest_title',
                                '{month} quest: earn {goal} XP')
                            .replaceAll('{month}',
                                monthName(DateTime.now()))
                            .replaceAll('{goal}', '$_goal'),
                    style:
                        const TextStyle(fontWeight: FontWeight.w800)),
              ),
              if (earned && !_justPaid)
                FilledButton(
                  style: FilledButton.styleFrom(
                      backgroundColor: RatelColors.honey,
                      visualDensity: VisualDensity.compact),
                  onPressed: _claim,
                  child: const Text('+30 gems'),
                ),
            ],
          ),
          if (!_justPaid) ...[
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: (xp / _goal).clamp(0.0, 1.0),
                minHeight: 6,
                backgroundColor: context.tintC(RatelColors.honey),
                color: RatelColors.honey,
              ),
            ),
            const SizedBox(height: 4),
            Text('$xp / $_goal XP',
                style: const TextStyle(
                    color: RatelColors.textMuted, fontSize: 11.5)),
          ],
        ],
      ),
    );
  }
}
