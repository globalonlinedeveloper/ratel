import 'package:flutter/material.dart';
import '../../../core/i18n/strings.dart';
import '../../../core/theme/tokens.dart';
import '../../../design_system/components/lesson_top_bar.dart';
import '../../../design_system/components/ratel_button.dart';
import '../../../design_system/components/ratel_field.dart';

/// Lesson · listen — mock Page-3 · screen 5 (type what you hear, with a11y
/// affordances). Design-only (no backend/audio yet).
class LessonListenScreen extends StatefulWidget {
  const LessonListenScreen({super.key});

  @override
  State<LessonListenScreen> createState() => _LessonListenScreenState();
}

class _LessonListenScreenState extends State<LessonListenScreen> {
  final TextEditingController _answer = TextEditingController();

  @override
  void dispose() {
    _answer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tk = context.tokens;
    return Scaffold(
      body: SafeArea(
        child: Align(alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 440),
            child: Padding(
              padding: const EdgeInsets.all(RatelSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  LessonTopBar(
                    progress: 0.30,
                    energy: 18,
                    onClose: () => Navigator.of(context).maybePop(),
                  ),
                  const SizedBox(height: RatelSpacing.md),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
                          Text(
                            S.t('lesson_listen_title', 'Type what you hear'),
                            style: TextStyle(
                              color: tk.text,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: RatelSpacing.md),
                          Center(
                            child: Column(
                              children: <Widget>[
                                Container(
                                  width: 70,
                                  height: 70,
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    color: tk.primary,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(Icons.volume_up, size: 36, color: Colors.white),
                                ),
                                const SizedBox(height: RatelSpacing.md),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    _MiniAction(icon: Icons.slow_motion_video, label: S.t('lesson_listen_slower', 'Slower')),
                                    const SizedBox(width: RatelSpacing.lg),
                                    _MiniAction(icon: Icons.closed_caption_outlined, label: S.t('lesson_listen_cc', 'Captions')),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: RatelSpacing.md),
                          RatelField(
                            controller: _answer,
                            hint: S.t('lesson_listen_input', 'Type what you hear'),
                          ),
                          const SizedBox(height: RatelSpacing.sm),
                          Row(
                            children: <Widget>[
                              Icon(Icons.accessible, size: 12, color: tk.textMuted),
                              const SizedBox(width: RatelSpacing.xs),
                              Expanded(
                                child: Text(
                                  S.t('lesson_listen_a11y', 'captions · dyslexia font · no-time-pressure (WCAG 2.2 / ADA)'),
                                  style: TextStyle(color: tk.textMuted, fontSize: 9),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  RatelButton.filled(
                    label: S.t('lesson_check', 'Check'),
                    onPressed: () {},
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

/// Small teal text action with a leading icon (Slower / Captions).
class _MiniAction extends StatelessWidget {
  const _MiniAction({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final tk = context.tokens;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Icon(icon, size: 14, color: tk.primary),
        const SizedBox(width: RatelSpacing.xs),
        Text(label, style: TextStyle(color: tk.primary, fontSize: 11)),
      ],
    );
  }
}
