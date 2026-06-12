import 'package:flutter/material.dart';
import '../theme.dart';
import '../app_state.dart';
import '../strings.dart';
import '../widgets/ratel_mascot.dart';
import 'placement_screen.dart';

/// First-run onboarding: a quick motivation + daily-goal commitment, then into
/// the first lesson (the guaranteed first win). Shown once (profiles.onboarded).
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  static const List<String> _motivations = [
    'Career', 'Travel', 'School', 'Family', 'Brain training', 'Just for fun'
  ];
  static const List<(int, String)> _goals = [
    (10, 'Casual'), (20, 'Regular'), (30, 'Serious'), (50, 'Intense')
  ];

  String? _motivation;
  int _goal = 20;
  bool _busy = false;

  Future<void> _start() async {
    setState(() => _busy = true);
    await appState.setDailyGoal(_goal);
    await appState.markOnboarded(); // home re-renders to the tabs via ListenableBuilder
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: ListView(
              padding: const EdgeInsets.all(24),
              children: [
                const SizedBox(height: 8),
                const Center(child: RatelMascot(pose: RatelPose.wave, size: 130)),
                const SizedBox(height: 8),
                Center(
                  child: SegmentedButton<String>(
                    showSelectedIcon: false,
                    style: const ButtonStyle(
                        visualDensity: VisualDensity.compact),
                    segments: const [
                      ButtonSegment(
                          value: 'en', label: Text('I speak English')),
                      ButtonSegment(
                          value: 'ta', label: Text('நான் தமிழ் பேசுகிறேன்')),
                    ],
                    selected: {S.instance.locale},
                    onSelectionChanged: (sel) async {
                      await S.instance.setLocale(sel.first);
                      if (mounted) setState(() {});
                    },
                  ),
                ),
                const SizedBox(height: 12),
                Text(S.instance.t('ob_title', 'Welcome to Ratel!'),
                    textAlign: TextAlign.center,
                    style:
                        TextStyle(fontSize: 24, fontFamily: kDisplayFont, fontWeight: FontWeight.w800)),
                Text(S.instance.t('ob_sub',
                        'Be fearless about English. Two quick questions.'),
                    textAlign: TextAlign.center,
                    style: TextStyle(color: RatelColors.textMuted)),
                const SizedBox(height: 24),
                Text(S.instance.t('ob_why', 'Why are you learning?'),
                    style: TextStyle(fontWeight: FontWeight.w700)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final m in _motivations)
                      ChoiceChip(
                        label: Text(S.instance.t(
                            'ob_m_${m.toLowerCase().replaceAll(' ', '_')}',
                            m)),
                        selected: _motivation == m,
                        onSelected: (_) => setState(() => _motivation = m),
                      ),
                  ],
                ),
                const SizedBox(height: 24),
                Text(S.instance.t('ob_goal', 'Set your daily goal'),
                    style: TextStyle(fontWeight: FontWeight.w700)),
                const SizedBox(height: 8),
                Column(
                  children: [
                    for (final g in _goals)
                      _goalTile(g.$1, g.$2),
                  ],
                ),
                const SizedBox(height: 24),
                FilledButton(
                  onPressed: _busy ? null : _start,
                  child: Text(_busy
                      ? S.instance.t('ob_setting_up', 'Setting up…')
                      : S.instance.t('ob_start', 'Start learning')),
                ),
                const SizedBox(height: 10),
                OutlinedButton(
                  onPressed: _busy
                      ? null
                      : () => Navigator.of(context).push(MaterialPageRoute(
                          builder: (_) => PlacementScreen(goal: _goal))),
                  child: Text(S.instance
                      .t('ob_know', 'I already know some English')),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _goalTile(int xp, String label) {
    final sel = _goal == xp;
    return GestureDetector(
      onTap: () => setState(() => _goal = xp),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: sel ? RatelColors.honey.withValues(alpha: 0.12) : context.surfaceC,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
              color: sel ? RatelColors.honey : context.borderC,
              width: sel ? 2 : 1),
        ),
        child: Row(
          children: [
            Icon(sel ? Icons.radio_button_checked : Icons.radio_button_unchecked,
                color: sel ? RatelColors.honey : RatelColors.textMuted, size: 20),
            const SizedBox(width: 12),
            Expanded(
                child: Text(
                    S.instance.t('ob_g_${label.toLowerCase()}', label),
                    style: const TextStyle(fontWeight: FontWeight.w600))),
            Text('$xp ${S.instance.t('xp_day', 'XP / day')}',
                style: const TextStyle(color: RatelColors.textMuted)),
          ],
        ),
      ),
    );
  }
}
