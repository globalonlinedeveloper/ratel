import 'package:flutter/material.dart';
import '../../../core/i18n/strings.dart';
import '../../../core/theme/tokens.dart';
import '../../../design_system/components/ratel_button.dart';

/// English Score — mock Page-6 · screen 2 (0–160 score, exam map, sub-skills).
/// Design-only (no backend yet).
class EnglishScoreScreen extends StatelessWidget {
  const EnglishScoreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final tk = context.tokens;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Navigator.of(context).canPop()
            ? IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => Navigator.of(context).maybePop())
            : null,
      ),
      body: SafeArea(
        child: Align(alignment: Alignment.topCenter,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(RatelSpacing.md, 0, RatelSpacing.md, RatelSpacing.md),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Center(
                    child: Column(
                      children: <Widget>[
                        Text(S.t('score_value', '95'), style: TextStyle(color: tk.primary, fontSize: 40, fontWeight: FontWeight.w600)),
                        Text(S.t('score_range', 'English Score · 0–160'), style: TextStyle(color: tk.textMuted, fontSize: 11)),
                        const SizedBox(height: 3),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: RatelSpacing.sm + 2, vertical: 2),
                          decoration: BoxDecoration(color: tk.successBg, borderRadius: BorderRadius.circular(tk.radiusPill)),
                          child: Text(S.t('score_cefr', 'B1 · Independent'), style: TextStyle(color: tk.success, fontSize: 11)),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: RatelSpacing.md),
                  Row(
                    children: <Widget>[
                      Text(
                        S.t('score_rough_guide', 'Rough guide'),
                        style: TextStyle(
                          color: tk.textMuted,
                          fontSize: 9,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: RatelSpacing.md, vertical: RatelSpacing.sm),
                    decoration: BoxDecoration(color: tk.surface2, borderRadius: BorderRadius.circular(tk.radiusSm)),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        for (final String e in <String>['≈ IELTS 5.5', '≈ TOEFL 65', '≈ DET 95'])
                          Text(e, style: TextStyle(color: tk.textMuted, fontSize: 9)),
                      ],
                    ),
                  ),
                  const SizedBox(height: RatelSpacing.sm),
                  Container(
                    padding: const EdgeInsets.all(RatelSpacing.sm + 2),
                    decoration: BoxDecoration(
                      color: tk.infoBg,
                      borderRadius: BorderRadius.circular(tk.radiusSm),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Icon(Icons.info_outline, size: 14, color: tk.info),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            S.t(
                              'score_disclaimer',
                              'Internal estimate to track progress — not an '
                              'official IELTS/TOEFL/DET certificate.',
                            ),
                            style: TextStyle(
                              color: tk.info,
                              fontSize: 10,
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: RatelSpacing.md),
                  SizedBox(
                    height: 36,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: <Widget>[
                        for (final double h in <double>[0.4, 0.55, 0.5, 0.7, 0.65, 0.85])
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 2),
                              child: Container(height: 36 * h, decoration: BoxDecoration(color: tk.success, borderRadius: BorderRadius.circular(2))),
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: RatelSpacing.xs),
                  Text(S.t('score_trend', '12-week trend'), style: TextStyle(color: tk.textMuted, fontSize: 9)),
                  const SizedBox(height: RatelSpacing.sm),
                  _Skill(label: S.t('score_reading', 'Reading'), value: 0.78, color: tk.primary),
                  const SizedBox(height: 6),
                  _Skill(label: S.t('score_listening', 'Listening'), value: 0.64, color: tk.info),
                  const SizedBox(height: 6),
                  _Skill(label: S.t('score_speaking', 'Speaking'), value: 0.52, color: tk.hearts),
                  const SizedBox(height: 6),
                  _Skill(label: S.t('score_writing', 'Writing'), value: 0.60, color: RatelSociety.purple),
                  const SizedBox(height: RatelSpacing.md),
                  RatelButton.filled(icon: Icons.share_outlined, label: S.t('score_cta', 'Share score card'), onPressed: () {}),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Skill extends StatelessWidget {
  const _Skill({required this.label, required this.value, required this.color});

  final String label;
  final double value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final tk = context.tokens;
    return Row(
      children: <Widget>[
        SizedBox(width: 62, child: Text(label, style: TextStyle(color: tk.textMuted, fontSize: 10))),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(tk.radiusPill),
            child: LinearProgressIndicator(value: value, minHeight: 6, backgroundColor: tk.border, valueColor: AlwaysStoppedAnimation<Color>(color)),
          ),
        ),
      ],
    );
  }
}
