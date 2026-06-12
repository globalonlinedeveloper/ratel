import 'package:in_app_review/in_app_review.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../app_state.dart';
import '../milestones.dart';
import '../strings.dart';
import '../theme.dart';
import 'mascot_anim.dart';
import 'ratel_mascot.dart';

/// One-time celebration card for landmark streak days (7/30/100/365).
/// Listens to appState (the streak lands async after lesson complete)
/// and shows each milestone exactly once (persisted flag).
class StreakMilestoneCard extends StatefulWidget {
  const StreakMilestoneCard({super.key});

  @override
  State<StreakMilestoneCard> createState() => _StreakMilestoneCardState();
}

class _StreakMilestoneCardState extends State<StreakMilestoneCard> {
  int? _show;
  bool _checking = false;

  @override
  void initState() {
    super.initState();
    appState.addListener(_eval);
    _eval();
  }

  @override
  void dispose() {
    appState.removeListener(_eval);
    super.dispose();
  }

  Future<void> _eval() async {
    final int? m = milestoneFor(appState.streak);
    if (m == null || _show == m || _checking) return;
    _checking = true;
    try {
      final prefs = await SharedPreferences.getInstance();
      if (prefs.getBool('ms_done_$m') ?? false) return;
      await prefs.setBool('ms_done_$m', true);
      if (mounted) setState(() => _show = m);
      if (m == 7 && !(prefs.getBool('review_asked') ?? false)) {
        await prefs.setBool('review_asked', true);
        Future.delayed(const Duration(milliseconds: 1600), () async {
          if (!mounted) return;
          // sentiment gate: only happy learners meet the store prompt
          final happy = await showDialog<bool>(
            context: context,
            builder: (ctx) => AlertDialog(
              title: Text(S.instance.t('rate_ask', 'Enjoying Ratel so far?')),
              actions: [
                TextButton(
                    onPressed: () => Navigator.of(ctx).pop(false),
                    child: Text(S.instance.t('rate_no', 'Not yet'))),
                FilledButton(
                    onPressed: () => Navigator.of(ctx).pop(true),
                    child: Text(S.instance.t('rate_yes', 'Loving it!'))),
              ],
            ),
          );
          if (happy != true) return;
          try {
            final review = InAppReview.instance;
            if (await review.isAvailable()) {
              await review.requestReview(); // the happiest moment
            }
          } catch (_) {}
        });
      }
    } catch (_) {
    } finally {
      _checking = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_show == null) return const SizedBox.shrink();
    return Container(
      margin: const EdgeInsets.fromLTRB(24, 10, 24, 0),
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
              action: 'flex', fallbackPose: RatelPose.celebrate, size: 64),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                    S.instance
                        .t('ms_days', '{n}-day streak!')
                        .replaceAll('{n}', '$_show'),
                    style: const TextStyle(
                        fontFamily: kDisplayFont,
                        fontSize: 17,
                        fontWeight: FontWeight.w800)),
                Text(S.instance.t('ms_body', 'Fearless. Keep the fire going.'),
                    style: TextStyle(color: context.mutedC, fontSize: 13)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
