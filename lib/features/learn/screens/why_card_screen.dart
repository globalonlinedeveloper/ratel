import 'package:flutter/material.dart';
import '../../../core/i18n/strings.dart';
import '../../../core/theme/tokens.dart';
import '../../../design_system/components/ratel_button.dart';

/// Why-card · AI explain — mock Page-3 · screen 6 (grounded explanation of the
/// answer + follow-up). Design-only (no backend yet).
class WhyCardScreen extends StatelessWidget {
  const WhyCardScreen({super.key});

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
        child: Align(alignment: Alignment.topCenter,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(
              RatelSpacing.lg,
              0,
              RatelSpacing.lg,
              RatelSpacing.lg,
            ),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Icon(Icons.lightbulb_outline, size: 19, color: tk.brand),
                      const SizedBox(width: RatelSpacing.sm),
                      Text(
                        S.t('why_title', 'Why this answer?'),
                        style: TextStyle(
                          color: tk.text,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: RatelSpacing.md),
                  Container(
                    padding: const EdgeInsets.all(RatelSpacing.md),
                    decoration: BoxDecoration(
                      color: tk.surface2,
                      borderRadius: BorderRadius.circular(tk.radiusMd),
                    ),
                    child: Text(
                      S.t(
                        'why_body',
                        '"வேண்டும்" = "would like" (a polite request). "குடிக்கிறேன்" = "I drink" — states a fact, so it doesn\'t fit ordering.',
                      ),
                      style: TextStyle(color: tk.textMuted, fontSize: 12.5, height: 1.6),
                    ),
                  ),
                  const SizedBox(height: RatelSpacing.md),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: RatelSpacing.md,
                      vertical: RatelSpacing.sm,
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(color: tk.border, width: tk.hairline),
                      borderRadius: BorderRadius.circular(tk.radiusPill),
                    ),
                    child: Row(
                      children: <Widget>[
                        Icon(Icons.smart_toy_outlined, size: 17, color: tk.primary),
                        const SizedBox(width: RatelSpacing.sm),
                        Text(
                          S.t('why_followup', 'Ask a follow-up…'),
                          style: TextStyle(color: tk.textMuted, fontSize: 11.5),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: RatelSpacing.sm),
                  Row(
                    children: <Widget>[
                      Icon(Icons.verified_user_outlined, size: 12, color: tk.textMuted),
                      const SizedBox(width: RatelSpacing.xs),
                      Expanded(
                        child: Text(
                          S.t('why_grounded', 'grounded · fail-closed · AI-disclosed'),
                          style: TextStyle(color: tk.textMuted, fontSize: 9),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: RatelSpacing.lg),
                  RatelButton.filled(
                    label: S.t('why_cta', 'Got it'),
                    onPressed: () => Navigator.of(context).maybePop(),
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
