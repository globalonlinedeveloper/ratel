import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/i18n/strings.dart';
import '../../../core/theme/tokens.dart';
import '../../../design_system/components/lesson_top_bar.dart';
import '../../../design_system/components/ratel_button.dart';
import '../../../design_system/components/ratel_option_tile.dart';

/// Lesson · choice — mock Page-3 · screen 2 (select the translation). Audio
/// prompt + multiple-choice. Design-only (no backend yet).
class LessonChoiceScreen extends StatefulWidget {
  const LessonChoiceScreen({super.key});

  @override
  State<LessonChoiceScreen> createState() => _LessonChoiceScreenState();
}

class _LessonChoiceScreenState extends State<LessonChoiceScreen> {
  static const List<String> _options = <String>[
    'எனக்கு ஒரு காபி வேண்டும்',
    'எனக்கு தண்ணீர் வேண்டும்',
    'நான் காபி குடிக்கிறேன்',
  ];
  String _answer = _options.first;

  @override
  Widget build(BuildContext context) {
    final tk = context.tokens;
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 440),
            child: Padding(
              padding: const EdgeInsets.all(RatelSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  LessonTopBar(
                    progress: 0.55,
                    energy: 18,
                    onClose: () => Navigator.of(context).maybePop(),
                  ),
                  const SizedBox(height: RatelSpacing.md),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
                          Row(
                            children: <Widget>[
                              Expanded(
                                child: Text(
                                  S.t(
                                    'lesson_choice_q',
                                    'Select the translation',
                                  ),
                                  style: TextStyle(
                                    color: tk.text,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              Icon(
                                Icons.lightbulb_outline,
                                size: 16,
                                color: tk.textMuted,
                              ),
                              const SizedBox(width: RatelSpacing.sm),
                              Icon(
                                Icons.flag_outlined,
                                size: 16,
                                color: tk.textMuted,
                              ),
                              const SizedBox(width: RatelSpacing.sm),
                              Icon(
                                Icons.accessible,
                                size: 16,
                                color: tk.textMuted,
                              ),
                            ],
                          ),
                          const SizedBox(height: RatelSpacing.sm),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: RatelSpacing.md,
                              vertical: RatelSpacing.sm,
                            ),
                            decoration: BoxDecoration(
                              color: tk.surface2,
                              borderRadius: BorderRadius.circular(tk.radiusMd),
                            ),
                            child: Row(
                              children: <Widget>[
                                Icon(
                                  Icons.volume_up,
                                  size: 18,
                                  color: tk.primary,
                                ),
                                const SizedBox(width: RatelSpacing.sm),
                                Expanded(
                                  child: Text(
                                    S.t(
                                      'lesson_choice_prompt',
                                      "I'd like a coffee",
                                    ),
                                    style: TextStyle(
                                      color: tk.text,
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                                Icon(
                                  Icons.skip_next,
                                  size: 16,
                                  color: tk.textMuted,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: RatelSpacing.xs),
                          Text(
                            S.t(
                              'lesson_choice_hint',
                              'combo ×3 · tap any word for a hint',
                            ),
                            style: TextStyle(color: tk.textMuted, fontSize: 9),
                          ),
                          const SizedBox(height: RatelSpacing.md),
                          for (final String option in _options) ...<Widget>[
                            RatelOptionTile(
                              title: option,
                              selected: option == _answer,
                              onTap: () => setState(() => _answer = option),
                            ),
                            const SizedBox(height: RatelSpacing.sm),
                          ],
                        ],
                      ),
                    ),
                  ),
                  RatelButton.filled(
                    label: S.t('lesson_check', 'Check'),
                    onPressed: () => context.push('/complete'),
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
