import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/i18n/strings.dart';
import '../../../core/theme/tokens.dart';
import '../../../design_system/components/ratel_button.dart';
import '../../../design_system/components/ratel_medallion.dart';
import '../../../design_system/components/ratel_select_field.dart';

/// Language picker — mock Page-2 · screen 1. Full locale + learning-target
/// pickers (fixes the old hardcoded EN/TA toggle). Design-only (no backend).
class LanguagePickerScreen extends StatelessWidget {
  const LanguagePickerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final tk = context.tokens;
    final TextStyle label = TextStyle(
      color: tk.textMuted,
      fontSize: 12,
      fontWeight: FontWeight.w600,
    );
    final TextStyle hint = TextStyle(color: tk.textMuted, fontSize: 10, height: 1.4);
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
                  Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        RatelMedallion(
                          icon: Icons.sentiment_satisfied_alt,
                          background: tk.warningBg,
                          foreground: tk.brand,
                          size: 54,
                          iconSize: 30,
                        ),
                        const SizedBox(height: RatelSpacing.sm),
                        Text(
                          S.t('ob_lang_welcome', 'Welcome to Ratel'),
                          style: TextStyle(
                            color: tk.text,
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: RatelSpacing.lg),
                  Text(S.t('ob_lang_speak', 'I speak'), style: label),
                  const SizedBox(height: RatelSpacing.xs),
                  RatelSelectField(
                    label: S.t('ob_lang_speak_value', 'தமிழ் · Tamil'),
                    active: true,
                    onTap: () {},
                  ),
                  const SizedBox(height: RatelSpacing.xs),
                  Text(
                    S.t('ob_lang_speak_hint', 'Full 44+ locale picker (was a 2-option EN/TA toggle)'),
                    style: hint,
                  ),
                  const SizedBox(height: RatelSpacing.md),
                  Text(S.t('ob_lang_learn', 'I want to learn'), style: label),
                  const SizedBox(height: RatelSpacing.xs),
                  RatelSelectField(
                    label: S.t('ob_lang_learn_value', 'English'),
                    leadingIcon: Icons.flag_outlined,
                    onTap: () {},
                  ),
                  const SizedBox(height: RatelSpacing.xs),
                  Text(
                    S.t('ob_lang_learn_hint', 'New — multi-target (English, Spanish, French…)'),
                    style: hint,
                  ),
                  const SizedBox(height: RatelSpacing.lg),
                  RatelButton.filled(
                    label: S.t('ob_lang_cta', 'Continue'),
                    onPressed: () => context.push('/onboarding/motivation'),
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
