import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/i18n/strings.dart';
import '../../../core/theme/tokens.dart';
import '../../../design_system/components/ratel_button.dart';

/// Lesson complete — mock Page-3 · screen 8 (win band, stats, AI debrief,
/// streak). Design-only (no backend yet).
class LessonCompleteScreen extends StatelessWidget {
  const LessonCompleteScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final tk = context.tokens;
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 440),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Container(
                  color: tk.win,
                  padding: const EdgeInsets.symmetric(
                    vertical: RatelSpacing.lg,
                  ),
                  child: Column(
                    children: <Widget>[
                      Icon(Icons.emoji_events, size: 28, color: tk.text),
                      const SizedBox(height: RatelSpacing.xs),
                      Text(
                        S.t('complete_title', 'Lesson complete!'),
                        style: TextStyle(
                          color: tk.text,
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(RatelSpacing.md),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        Row(
                          children: <Widget>[
                            _stat(
                              tk,
                              '+18',
                              S.t('complete_xp', 'XP'),
                              tk.brand,
                            ),
                            const SizedBox(width: RatelSpacing.sm),
                            _stat(
                              tk,
                              '92%',
                              S.t('complete_acc', 'accuracy'),
                              tk.success,
                            ),
                            const SizedBox(width: RatelSpacing.sm),
                            _stat(
                              tk,
                              'B1',
                              S.t('complete_speak', 'speaking'),
                              tk.info,
                            ),
                          ],
                        ),
                        const SizedBox(height: RatelSpacing.sm),
                        Container(
                          padding: const EdgeInsets.all(RatelSpacing.sm + 2),
                          decoration: BoxDecoration(
                            color: tk.successBg,
                            borderRadius: BorderRadius.circular(tk.radiusSm),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Row(
                                children: <Widget>[
                                  Icon(
                                    Icons.auto_awesome,
                                    size: 15,
                                    color: tk.success,
                                  ),
                                  const SizedBox(width: RatelSpacing.xs),
                                  Text(
                                    S.t('complete_debrief', 'AI debrief'),
                                    style: TextStyle(
                                      color: tk.success,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 3),
                              Text(
                                S.t(
                                  'complete_debrief_body',
                                  'Great ordering phrases. Practice the "வே" sound next.',
                                ),
                                style: TextStyle(
                                  color: tk.success,
                                  fontSize: 10.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: RatelSpacing.sm),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: RatelSpacing.sm + 2,
                            vertical: RatelSpacing.sm,
                          ),
                          decoration: BoxDecoration(
                            color: tk.warningBg,
                            borderRadius: BorderRadius.circular(tk.radiusSm),
                          ),
                          child: Row(
                            children: <Widget>[
                              Icon(
                                Icons.local_fire_department,
                                size: 16,
                                color: tk.coral,
                              ),
                              const SizedBox(width: RatelSpacing.sm),
                              Text(
                                S.t(
                                  'complete_streak',
                                  '8-day streak · Society +1',
                                ),
                                style: TextStyle(
                                  color: tk.warning,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(RatelSpacing.md),
                  child: Row(
                    children: <Widget>[
                      Expanded(
                        child: RatelButton.outline(
                          icon: Icons.share_outlined,
                          label: S.t('complete_share', 'Share'),
                          onPressed: () {},
                        ),
                      ),
                      const SizedBox(width: RatelSpacing.sm),
                      Expanded(
                        child: RatelButton.filled(
                          label: S.t('complete_continue', 'Continue'),
                          onPressed: () => context.go('/app'),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _stat(RatelTokens tk, String value, String label, Color color) =>
      Expanded(
        child: Container(
          padding: const EdgeInsets.all(RatelSpacing.sm),
          decoration: BoxDecoration(
            color: tk.surface2,
            borderRadius: BorderRadius.circular(tk.radiusSm),
          ),
          child: Column(
            children: <Widget>[
              Text(
                value,
                style: TextStyle(
                  color: color,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 2),
              Text(label, style: TextStyle(color: tk.textMuted, fontSize: 9)),
            ],
          ),
        ),
      );
}
