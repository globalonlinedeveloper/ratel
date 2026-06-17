import 'package:flutter/material.dart';
import '../../../core/i18n/strings.dart';
import '../../../core/theme/tokens.dart';
import '../../../design_system/components/ratel_button.dart';

/// Pronunciation results — mock Page-4 · screen 7 (phoneme breakdown + metric
/// bars + tip). Design-only (no backend yet).
class PronunciationResultsScreen extends StatelessWidget {
  const PronunciationResultsScreen({super.key});

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
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: Text(S.t('pron_title', 'Your pronunciation'), style: TextStyle(color: tk.text, fontSize: 15, fontWeight: FontWeight.w600)),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: RatelSpacing.sm, vertical: 3),
                        decoration: BoxDecoration(color: tk.successBg, borderRadius: BorderRadius.circular(tk.radiusPill)),
                        child: Text(S.t('pron_cefr', 'B1'), style: TextStyle(color: tk.success, fontSize: 12)),
                      ),
                    ],
                  ),
                  const SizedBox(height: RatelSpacing.sm),
                  Wrap(
                    spacing: 7,
                    children: <Widget>[
                      _Syl(text: S.t('pron_s1', 'cof'), color: tk.primary),
                      _Syl(text: S.t('pron_s2', 'fee'), color: tk.win, underline: true),
                      _Syl(text: S.t('pron_s3', 'cup'), color: tk.primary),
                      _Syl(text: S.t('pron_s4', 'th'), color: tk.danger, underline: true),
                      _Syl(text: S.t('pron_s5', 'ree'), color: tk.primary),
                    ],
                  ),
                  const SizedBox(height: RatelSpacing.xs),
                  Text(S.t('pron_hint', 'tap any sound to replay · /θ/ needs work'), style: TextStyle(color: tk.textMuted, fontSize: 9.5)),
                  const SizedBox(height: RatelSpacing.sm),
                  _Metric(label: S.t('pron_m1', 'Pronunciation'), value: 0.72, color: tk.primary),
                  const SizedBox(height: RatelSpacing.sm),
                  _Metric(label: S.t('pron_m2', 'Intonation'), value: 0.60, color: tk.info),
                  const SizedBox(height: RatelSpacing.sm),
                  _Metric(label: S.t('pron_m3', 'Fluency'), value: 0.80, color: tk.hearts),
                  const SizedBox(height: RatelSpacing.sm),
                  _Metric(label: S.t('pron_m4', 'Stress'), value: 0.55, color: tk.coral),
                  const SizedBox(height: RatelSpacing.sm),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: RatelSpacing.md, vertical: RatelSpacing.sm),
                    decoration: BoxDecoration(color: tk.surface2, borderRadius: BorderRadius.circular(tk.radiusMd)),
                    child: Text.rich(
                      TextSpan(
                        children: <TextSpan>[
                          TextSpan(text: S.t('pron_tip_label', 'Tip: '), style: const TextStyle(fontWeight: FontWeight.w700)),
                          TextSpan(text: S.t('pron_tip_body', 'for /θ/, put your tongue between your teeth and blow gently.')),
                        ],
                        style: TextStyle(color: tk.textMuted, fontSize: 11),
                      ),
                    ),
                  ),
                  const SizedBox(height: RatelSpacing.md),
                  RatelButton.filled(label: S.t('pron_cta', 'Drill the /θ/ sound'), onPressed: () {}),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Syl extends StatelessWidget {
  const _Syl({required this.text, required this.color, this.underline = false});

  final String text;
  final Color color;
  final bool underline;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        color: color,
        fontSize: 18,
        decoration: underline ? TextDecoration.underline : null,
        decorationColor: color,
        decorationThickness: 2,
      ),
    );
  }
}

class _Metric extends StatelessWidget {
  const _Metric({required this.label, required this.value, required this.color});

  final String label;
  final double value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final tk = context.tokens;
    return Row(
      children: <Widget>[
        SizedBox(
          width: 74,
          child: Text(label, style: TextStyle(color: tk.textMuted, fontSize: 11)),
        ),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(tk.radiusPill),
            child: LinearProgressIndicator(
              value: value,
              minHeight: 7,
              backgroundColor: tk.border,
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
        ),
      ],
    );
  }
}
