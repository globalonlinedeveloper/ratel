import 'package:flutter/material.dart';
import '../../../core/i18n/strings.dart';
import '../../../core/theme/tokens.dart';
import '../../../design_system/components/ratel_button.dart';
import '../../../design_system/components/ratel_medallion.dart';

/// Wrong feedback — mock Page-3 · screen 7 (incorrect-answer sheet with the
/// correction and a "Why?"). Design-only (no backend/haptics yet).
class WrongFeedbackScreen extends StatelessWidget {
  const WrongFeedbackScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final tk = context.tokens;
    return Scaffold(
      backgroundColor: tk.surface2,
      body: SafeArea(
        child: Column(
          children: <Widget>[
            const Spacer(),
            Padding(
              padding: const EdgeInsets.all(RatelSpacing.md),
              child: Column(
                children: <Widget>[
                  RatelMedallion(
                    icon: Icons.close,
                    background: tk.dangerBg,
                    foreground: tk.danger,
                    size: 54,
                    iconSize: 28,
                  ),
                  const SizedBox(height: RatelSpacing.sm),
                  Text(
                    S.t(
                      'wrong_note',
                      'coral shake · heavy haptic · −1 energy\npartial credit shown when close',
                    ),
                    textAlign: TextAlign.center,
                    style: TextStyle(color: tk.textMuted, fontSize: 10, height: 1.4),
                  ),
                ],
              ),
            ),
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: tk.dangerBg,
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(tk.radiusLg + 4),
                ),
              ),
              padding: const EdgeInsets.fromLTRB(
                RatelSpacing.lg,
                RatelSpacing.lg,
                RatelSpacing.lg,
                RatelSpacing.xl,
              ),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 440),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Text(
                        S.t('wrong_title', 'Almost — wrong verb'),
                        style: TextStyle(
                          color: tk.danger,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: RatelSpacing.sm),
                      Text.rich(
                        TextSpan(
                          children: <TextSpan>[
                            TextSpan(text: S.t('wrong_correct_prefix', 'Correct: எனக்கு ஒரு காபி ')),
                            TextSpan(
                              text: S.t('wrong_correct_word', 'வேண்டும்'),
                              style: const TextStyle(decoration: TextDecoration.underline),
                            ),
                          ],
                          style: TextStyle(color: tk.danger, fontSize: 12),
                        ),
                      ),
                      const SizedBox(height: RatelSpacing.md),
                      Row(
                        children: <Widget>[
                          Expanded(
                            child: RatelButton.dangerOutline(
                              icon: Icons.lightbulb_outline,
                              label: S.t('wrong_why', 'Why?'),
                              onPressed: () {},
                            ),
                          ),
                          const SizedBox(width: RatelSpacing.sm),
                          Expanded(
                            child: RatelButton.dangerFilled(
                              label: S.t('wrong_continue', 'Continue'),
                              onPressed: () => Navigator.of(context).maybePop(),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
