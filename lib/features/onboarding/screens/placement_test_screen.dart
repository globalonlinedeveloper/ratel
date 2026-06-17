import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/i18n/strings.dart';
import '../../../core/theme/tokens.dart';
import '../../../design_system/components/ratel_button.dart';
import '../../../design_system/components/ratel_option_tile.dart';

/// One placement question (a design-phase sample — answers are not graded yet).
class _PlacementQ {
  const _PlacementQ({
    required this.prompt,
    required this.sentence,
    required this.options,
  });

  final String prompt;
  final String sentence;
  final List<String> options;
}

/// Placement test — mock Page-2 · screen 7. A multi-step SAMPLE flow: five
/// fixed questions with a progress bar that advances on each answer, ending on
/// the level result. Design-only — real adaptive placement (a calibrated item
/// bank + CAT scoring) is deferred to a later phase, so answers aren't scored.
class PlacementTestScreen extends StatefulWidget {
  const PlacementTestScreen({super.key});

  @override
  State<PlacementTestScreen> createState() => _PlacementTestScreenState();
}

class _PlacementTestScreenState extends State<PlacementTestScreen> {
  int _step = 0;
  String? _selected;

  // Built per-build so localized prompts resolve through S.t (cheap — 5 items).
  List<_PlacementQ> get _questions => <_PlacementQ>[
        _PlacementQ(
          prompt: S.t('ob_placement_q', 'Choose the correct word'),
          sentence: S.t('ob_placement_sentence', 'She ___ to school every day.'),
          options: const <String>['goes', 'go', 'going'],
        ),
        _PlacementQ(
          prompt: S.t('ob_placement_q2', 'Pick the correct past tense'),
          sentence:
              S.t('ob_placement_sentence2', 'Yesterday they ___ a film.'),
          options: const <String>['watched', 'watch', 'watching'],
        ),
        _PlacementQ(
          prompt: S.t('ob_placement_q3', 'Choose the right article'),
          sentence:
              S.t('ob_placement_sentence3', 'I saw ___ elephant at the zoo.'),
          options: const <String>['an', 'a', 'the'],
        ),
        _PlacementQ(
          prompt: S.t('ob_placement_q4', 'Select the correct preposition'),
          sentence:
              S.t('ob_placement_sentence4', 'The keys are ___ the table.'),
          options: const <String>['on', 'in', 'at'],
        ),
        _PlacementQ(
          prompt: S.t('ob_placement_q5', 'Choose the best word'),
          sentence:
              S.t('ob_placement_sentence5', 'This book is more ___ than the last.'),
          options: const <String>['interesting', 'interest', 'interested'],
        ),
      ];

  void _advance(int total) {
    if (_step >= total - 1) {
      context.push('/onboarding/level');
      return;
    }
    setState(() {
      _step++;
      _selected = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final tk = context.tokens;
    final List<_PlacementQ> questions = _questions;
    final int total = questions.length;
    final _PlacementQ q = questions[_step];
    final bool last = _step >= total - 1;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Navigator.of(context).canPop()
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                tooltip: S.t('a11y_back', 'Back'),
                onPressed: () => Navigator.of(context).maybePop(),
              )
            : null,
      ),
      body: SafeArea(
        child: Align(
          alignment: Alignment.topCenter,
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
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(tk.radiusPill),
                          child: LinearProgressIndicator(
                            value: (_step + 1) / total,
                            minHeight: 7,
                            backgroundColor: tk.border,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(tk.primary),
                          ),
                        ),
                      ),
                      const SizedBox(width: RatelSpacing.sm),
                      Text(
                        '${_step + 1} / $total',
                        style: TextStyle(color: tk.textMuted, fontSize: 11),
                      ),
                    ],
                  ),
                  const SizedBox(height: RatelSpacing.md),
                  Text(
                    q.prompt,
                    style: TextStyle(
                      color: tk.text,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: RatelSpacing.sm),
                  Text(
                    q.sentence,
                    style: TextStyle(color: tk.textMuted, fontSize: 13),
                  ),
                  const SizedBox(height: RatelSpacing.md),
                  for (final String option in q.options) ...<Widget>[
                    RatelOptionTile(
                      title: option,
                      selected: option == _selected,
                      onTap: () => setState(() => _selected = option),
                    ),
                    const SizedBox(height: RatelSpacing.sm),
                  ],
                  const SizedBox(height: RatelSpacing.sm),
                  RatelButton.filled(
                    label: last
                        ? S.t('ob_placement_finish', 'See my level')
                        : S.t('ob_placement_next', 'Next'),
                    onPressed: _selected == null ? null : () => _advance(total),
                  ),
                  const SizedBox(height: RatelSpacing.md),
                  Text(
                    S.t(
                      'ob_placement_note',
                      'Sample questions — full adaptive test coming soon.',
                    ),
                    textAlign: TextAlign.center,
                    style: TextStyle(color: tk.textMuted, fontSize: 11),
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
