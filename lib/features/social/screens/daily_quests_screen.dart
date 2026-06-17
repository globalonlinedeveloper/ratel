import 'package:flutter/material.dart';
import '../../../core/i18n/strings.dart';
import '../../../core/theme/tokens.dart';
import '../../../design_system/components/ratel_button.dart';

/// Daily quests — mock Page-5 · screen 3 (daily/weekly/monthly + co-op).
/// Design-only (no backend yet).
class DailyQuestsScreen extends StatelessWidget {
  const DailyQuestsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final tk = context.tokens;
    Widget tab(String label, bool active) => Expanded(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 3),
            padding: const EdgeInsets.symmetric(vertical: RatelSpacing.xs + 2),
            decoration: BoxDecoration(color: active ? tk.primary : tk.surface2, borderRadius: BorderRadius.circular(tk.radiusSm)),
            child: Text(label, textAlign: TextAlign.center, style: TextStyle(color: active ? Colors.white : tk.text, fontSize: 11)),
          ),
        );
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Navigator.of(context).canPop()
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => Navigator.of(context).maybePop(),
              )
            : null,
      ),
      body: SafeArea(
        child: Align(alignment: Alignment.topCenter,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(RatelSpacing.md, 0, RatelSpacing.md, RatelSpacing.md),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      tab(S.t('quests_daily', 'Daily'), true),
                      tab(S.t('quests_weekly', 'Weekly'), false),
                      tab(S.t('quests_monthly', 'Monthly'), false),
                    ],
                  ),
                  const SizedBox(height: RatelSpacing.md),
                  _Quest(icon: Icons.bolt, color: tk.primary, label: S.t('quests_q1', 'Earn 30 XP'), value: 0.6, count: '18/30'),
                  const SizedBox(height: RatelSpacing.sm),
                  _Quest(icon: Icons.mic, color: tk.hearts, label: S.t('quests_q2', '2 speaking drills'), value: 0.5, count: '1/2'),
                  const SizedBox(height: RatelSpacing.sm),
                  Container(
                    padding: const EdgeInsets.all(RatelSpacing.md),
                    decoration: BoxDecoration(color: tk.warningBg, border: Border.all(color: tk.brand, width: 1.5), borderRadius: BorderRadius.circular(tk.radiusMd)),
                    child: Row(
                      children: <Widget>[
                        Icon(Icons.groups, size: 18, color: tk.warning),
                        const SizedBox(width: RatelSpacing.sm),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(S.t('quests_friends', 'Friends Quest · 100 gems'), style: TextStyle(color: tk.warning, fontSize: 12, fontWeight: FontWeight.w600)),
                              Text(S.t('quests_friends_sub', 'co-op · auto-matched if no friends'), style: TextStyle(color: tk.warning, fontSize: 10)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: RatelSpacing.md),
                  RatelButton.filled(label: S.t('quests_cta', 'Start a quest'), onPressed: () {}),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Quest extends StatelessWidget {
  const _Quest({required this.icon, required this.color, required this.label, required this.value, required this.count});

  final IconData icon;
  final Color color;
  final String label;
  final double value;
  final String count;

  @override
  Widget build(BuildContext context) {
    final tk = context.tokens;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: RatelSpacing.md, vertical: RatelSpacing.sm),
      decoration: BoxDecoration(color: tk.surface2, borderRadius: BorderRadius.circular(tk.radiusMd)),
      child: Row(
        children: <Widget>[
          Icon(icon, size: 16, color: color),
          const SizedBox(width: RatelSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(label, style: TextStyle(color: tk.text, fontSize: 11.5)),
                const SizedBox(height: 4),
                ClipRRect(
                  borderRadius: BorderRadius.circular(tk.radiusPill),
                  child: LinearProgressIndicator(value: value, minHeight: 5, backgroundColor: tk.border, valueColor: AlwaysStoppedAnimation<Color>(color)),
                ),
              ],
            ),
          ),
          const SizedBox(width: RatelSpacing.sm),
          Text(count, style: TextStyle(color: tk.textMuted, fontSize: 10)),
        ],
      ),
    );
  }
}
