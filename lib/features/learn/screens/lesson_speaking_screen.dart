import 'package:flutter/material.dart';
import '../../../core/i18n/strings.dart';
import '../../../core/theme/tokens.dart';
import '../../../design_system/components/lesson_top_bar.dart';
import '../../../design_system/components/ratel_button.dart';

/// Lesson · speaking — mock Page-3 · screen 3 (pronounce the sentence, phoneme
/// score waveform). Design-only (no backend/mic yet).
class LessonSpeakingScreen extends StatelessWidget {
  const LessonSpeakingScreen({super.key});

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
                    progress: 0.62,
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
                            S.t('lesson_speak_title', 'Say this sentence'),
                            style: TextStyle(
                              color: tk.text,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: RatelSpacing.sm),
                          Text.rich(
                            TextSpan(
                              children: <TextSpan>[
                                const TextSpan(text: "I'd "),
                                TextSpan(
                                  text: S.t('lesson_speak_w1', 'like'),
                                  style: TextStyle(color: tk.primary),
                                ),
                                const TextSpan(text: ' a '),
                                TextSpan(
                                  text: S.t('lesson_speak_w2', 'coffee'),
                                  style: TextStyle(color: tk.win),
                                ),
                              ],
                              style: TextStyle(color: tk.text, fontSize: 16),
                            ),
                          ),
                          const SizedBox(height: RatelSpacing.xs),
                          Text(
                            S.t('lesson_speak_legend', 'green = great · amber = try again (phoneme score)'),
                            style: TextStyle(color: tk.textMuted, fontSize: 10),
                          ),
                          const SizedBox(height: RatelSpacing.md),
                          const _Waveform(),
                          const SizedBox(height: RatelSpacing.lg),
                          Center(
                            child: Column(
                              children: <Widget>[
                                Container(
                                  width: 66,
                                  height: 66,
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    color: tk.primary,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(Icons.mic, size: 32, color: Colors.white),
                                ),
                                const SizedBox(height: RatelSpacing.sm),
                                Text(
                                  S.t('lesson_speak_tap', 'Tap to speak · or skip'),
                                  style: TextStyle(color: tk.textMuted, fontSize: 11),
                                ),
                              ],
                            ),
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

/// Decorative phoneme-score waveform (one amber bar = a weaker sound).
class _Waveform extends StatelessWidget {
  const _Waveform();

  @override
  Widget build(BuildContext context) {
    final tk = context.tokens;
    const List<double> heights = <double>[0.2, 0.55, 0.9, 0.6, 1.0, 0.45, 0.3];
    const int amberIndex = 4;
    return SizedBox(
      height: 54,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: <Widget>[
          for (int i = 0; i < heights.length; i++) ...<Widget>[
            Container(
              width: 4,
              height: 54 * heights[i],
              decoration: BoxDecoration(
                color: i == amberIndex ? tk.win : tk.primary,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            if (i != heights.length - 1) const SizedBox(width: 3),
          ],
        ],
      ),
    );
  }
}
