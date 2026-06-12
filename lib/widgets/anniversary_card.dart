import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../app_state.dart';
import '../config.dart';
import '../theme.dart';
import 'mascot_anim.dart';
import 'ratel_mascot.dart';

/// Account-anniversary celebration (party hat) on the signup month-day.
/// Gated on todayXp > 0 so it never competes with the streak nudge
/// (one mascot loop per screen).
class AnniversaryCard extends StatelessWidget {
  const AnniversaryCard({super.key});

  int _years() {
    if (!Config.hasSupabase) return 0;
    try {
      final created = DateTime.tryParse(
          Supabase.instance.client.auth.currentUser?.createdAt ?? '');
      if (created == null) return 0;
      final now = DateTime.now();
      if (now.month != created.month || now.day != created.day) return 0;
      return now.year - created.year;
    } catch (_) {
      return 0;
    }
  }

  @override
  Widget build(BuildContext context) =>
      ListenableBuilder(listenable: appState, builder: (c, _) => _live(c));

  // Self-listening: const on Home + reads appState.todayXp (same freeze
  // class as DailyNudge — see QA #2 P2 / Inc 135).
  Widget _live(BuildContext context) {
    final int years = _years();
    if (years < 1 || appState.todayXp <= 0) {
      return const SizedBox.shrink();
    }
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: context.tintC(RatelColors.honey),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
            color: RatelColors.honey.withValues(alpha: 0.5)),
      ),
      child: Row(
        children: [
          const RatelActionAnim(
              action: 'partyhat',
              fallbackPose: RatelPose.celebrate,
              size: 56),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
                years == 1
                    ? 'One year with Ratel — fearless!'
                    : '$years years with Ratel — fearless!',
                style: const TextStyle(
                    fontFamily: kDisplayFont,
                    fontSize: 16,
                    fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }
}
