import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/i18n/strings.dart';
import '../../../core/theme/tokens.dart';
import '../../../design_system/components/ratel_button.dart';
import '../../../design_system/components/ratel_choice_chip.dart';

/// Motivation — mock Page-2 · screen 2. Persisted (the old code discarded it).
/// Design-only (no backend yet).
class MotivationScreen extends StatefulWidget {
  const MotivationScreen({super.key});

  @override
  State<MotivationScreen> createState() => _MotivationScreenState();
}

class _MotivationScreenState extends State<MotivationScreen> {
  static const List<String> _options = <String>[
    'Career',
    'Travel',
    'School',
    'Family',
    'Brain training',
    'Just for fun',
  ];
  String _selected = 'Career';

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
                    S.t('ob_motivation_title', 'Why are you learning?'),
                    style: TextStyle(
                      color: tk.text,
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: RatelSpacing.xs),
                  Text(
                    S.t(
                      'ob_motivation_sub',
                      "We'll tailor your home screen & reminders to this.",
                    ),
                    style: TextStyle(color: tk.textMuted, fontSize: 11),
                  ),
                  const SizedBox(height: RatelSpacing.md),
                  Wrap(
                    spacing: RatelSpacing.sm,
                    runSpacing: RatelSpacing.sm,
                    children: <Widget>[
                      for (final String option in _options)
                        RatelChoiceChip(
                          label: S.t('ob_motivation_$option', option),
                          selected: option == _selected,
                          onTap: () => setState(() => _selected = option),
                        ),
                    ],
                  ),
                  const SizedBox(height: RatelSpacing.sm),
                  Text(
                    S.t(
                      'ob_motivation_note',
                      'Today the code collects this then throws it away — we persist & use it.',
                    ),
                    style: TextStyle(color: tk.textMuted, fontSize: 10, height: 1.4),
                  ),
                  const SizedBox(height: RatelSpacing.lg),
                  RatelButton.filled(
                    label: S.t('ob_motivation_cta', 'Continue'),
                    onPressed: () => context.push('/onboarding/goal'),
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
