import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/i18n/strings.dart';
import '../../../core/theme/tokens.dart';
import '../../../design_system/components/ratel_button.dart';
import '../../../design_system/components/ratel_option_tile.dart';

/// Daily goal — mock Page-2 · screen 3 (pace selection). Design-only.
class DailyGoalScreen extends StatefulWidget {
  const DailyGoalScreen({super.key});

  @override
  State<DailyGoalScreen> createState() => _DailyGoalScreenState();
}

class _DailyGoalScreenState extends State<DailyGoalScreen> {
  static const List<(String, String)> _goals = <(String, String)>[
    ('Regular', '20 XP / day'),
    ('Casual', '10 XP / day'),
    ('Serious', '30 XP / day'),
    ('Intense', '50 XP / day'),
  ];
  String _selected = 'Regular';

  @override
  Widget build(BuildContext context) {
    final tk = context.tokens;
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
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(
              RatelSpacing.xl,
              0,
              RatelSpacing.xl,
              RatelSpacing.xl,
            ),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text(
                    S.t('ob_goal_title', 'Set your daily goal'),
                    style: TextStyle(
                      color: tk.text,
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: RatelSpacing.md),
                  for (final (String name, String xp) in _goals) ...<Widget>[
                    RatelOptionTile(
                      title: S.t('ob_goal_$name', name),
                      trailing: S.t('ob_goal_${name}_xp', xp),
                      selected: name == _selected,
                      onTap: () => setState(() => _selected = name),
                    ),
                    const SizedBox(height: RatelSpacing.sm),
                  ],
                  const SizedBox(height: RatelSpacing.sm),
                  RatelButton.filled(
                    label: S.t('ob_goal_cta', 'Continue'),
                    onPressed: () => context.push('/onboarding/referral'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
