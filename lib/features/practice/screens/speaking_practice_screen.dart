import 'package:flutter/material.dart';
import '../../../core/i18n/strings.dart';
import '../../../core/theme/tokens.dart';
import '../../../design_system/components/ratel_button.dart';

/// Speaking practice — mock Page-4 · screen 6 (per-word + phoneme score with a
/// minimal-pair tip). Design-only (no backend/mic yet).
class SpeakingPracticeScreen extends StatelessWidget {
  const SpeakingPracticeScreen({super.key});

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
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 440),
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(RatelSpacing.md, 0, RatelSpacing.md, RatelSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Text(S.t('speak_title', 'Say this sentence'), style: TextStyle(color: tk.text, fontSize: 15, fontWeight: FontWeight.w600)),
                  const SizedBox(height: RatelSpacing.sm),
                  Text.rich(
                    TextSpan(
                      children: <TextSpan>[
                        const TextSpan(text: "I'd "),
                        TextSpan(text: S.t('speak_w1', 'like'), style: TextStyle(color: tk.primary)),
                        const TextSpan(text: ' a '),
                        TextSpan(text: S.t('speak_w2', 'cup'), style: TextStyle(color: tk.win)),
                        const TextSpan(text: ' of '),
                        TextSpan(text: S.t('speak_w3', 'coffee'), style: TextStyle(color: tk.primary)),
                      ],
                      style: TextStyle(color: tk.text, fontSize: 17),
                    ),
                  ),
                  const SizedBox(height: RatelSpacing.xs),
                  Text(S.t('speak_legend', 'green = clear · amber = improve (per-word + phoneme)'), style: TextStyle(color: tk.textMuted, fontSize: 10)),
                  const SizedBox(height: RatelSpacing.sm),
                  const _Waveform(),
                  const SizedBox(height: RatelSpacing.sm),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: RatelSpacing.md, vertical: RatelSpacing.sm),
                    decoration: BoxDecoration(color: tk.warningBg, borderRadius: BorderRadius.circular(tk.radiusMd)),
                    child: Text.rich(
                      TextSpan(
                        children: <TextSpan>[
                          TextSpan(text: S.t('speak_pair_label', 'Minimal pair: '), style: const TextStyle(fontWeight: FontWeight.w700)),
                          TextSpan(text: S.t('speak_pair_body', 'cup /kʌp/ vs cap /kæp/ — round your mouth a little less.')),
                        ],
                        style: TextStyle(color: tk.warning, fontSize: 11),
                      ),
                    ),
                  ),
                  const SizedBox(height: RatelSpacing.md),
                  Center(
                    child: Column(
                      children: <Widget>[
                        Container(
                          width: 64,
                          height: 64,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(color: tk.primary, shape: BoxShape.circle),
                          child: const Icon(Icons.mic, size: 30, color: Colors.white),
                        ),
                        const SizedBox(height: RatelSpacing.xs),
                        Text(S.t('speak_retry', 'Tap to retry'), style: TextStyle(color: tk.textMuted, fontSize: 10)),
                      ],
                    ),
                  ),
                  const SizedBox(height: RatelSpacing.md),
                  RatelButton.filled(label: S.t('speak_cta', 'See my score'), onPressed: () {}),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Waveform extends StatelessWidget {
  const _Waveform();

  @override
  Widget build(BuildContext context) {
    final tk = context.tokens;
    const List<double> heights = <double>[0.25, 0.6, 0.95, 0.7, 1.0, 0.5, 0.35];
    const int amberIndex = 3;
    return SizedBox(
      height: 58,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: <Widget>[
          for (int i = 0; i < heights.length; i++) ...<Widget>[
            Container(
              width: 4,
              height: 58 * heights[i],
              decoration: BoxDecoration(color: i == amberIndex ? tk.win : tk.primary, borderRadius: BorderRadius.circular(2)),
            ),
            if (i != heights.length - 1) const SizedBox(width: 3),
          ],
        ],
      ),
    );
  }
}
