import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../app_state.dart';
import '../milestones.dart';
import '../theme.dart';

/// One free chest per day on the Learn screen. Claimed state morphs in
/// place for the session and hides on the next build day-checked.
class DailyChestCard extends StatefulWidget {
  const DailyChestCard({super.key});

  @override
  State<DailyChestCard> createState() => _DailyChestCardState();
}

class _DailyChestCardState extends State<DailyChestCard> {
  bool _loaded = false;
  bool _claimedToday = true; // assume claimed until prefs say otherwise
  bool _justClaimed = false;
  int _paid = 0;
  String _bonus = '';

  static String _today() =>
      DateTime.now().toIso8601String().substring(0, 10);

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final p = await SharedPreferences.getInstance();
      final bool claimed = p.getString('daily_chest_day') == _today();
      if (mounted) {
        setState(() {
          _claimedToday = claimed;
          _loaded = true;
        });
      }
    } catch (_) {}
  }

  Future<void> _claim() async {
    final (int gems, String bonus) = dailyChestReward(DateTime.now());
    setState(() {
      _claimedToday = true;
      _justClaimed = true;
      _paid = gems;
      _bonus = bonus;
    });
    appState.addGems(gems);
    try {
      final p = await SharedPreferences.getInstance();
      await p.setString('daily_chest_day', _today());
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    if (!_loaded || (_claimedToday && !_justClaimed)) {
      return const SizedBox.shrink();
    }
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: context.tintC(RatelColors.honey),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: context.faintBorderC),
      ),
      child: _justClaimed
          ? Row(
              children: [
                const Icon(Icons.diamond, color: RatelColors.teal),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                      '+$_paid gems!'
                      '${_bonus.isEmpty ? '' : ' $_bonus'}'
                      ' See you tomorrow.',
                      style:
                          const TextStyle(fontWeight: FontWeight.w700)),
                ),
              ],
            )
          : InkWell(
              onTap: _claim,
              borderRadius: BorderRadius.circular(14),
              child: const Row(
                children: [
                  Icon(Icons.redeem, color: RatelColors.honey),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text('Daily chest — tap to open!',
                        style: TextStyle(fontWeight: FontWeight.w700)),
                  ),
                  Icon(Icons.chevron_right, color: RatelColors.textMuted),
                ],
              ),
            ),
    );
  }
}
