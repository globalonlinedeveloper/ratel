import 'package:flutter/material.dart';
import '../../../core/i18n/strings.dart';
import '../../../core/theme/tokens.dart';
import '../../../design_system/components/ratel_button.dart';
import '../../../design_system/components/ratel_medallion.dart';

/// Age check — mock Page-1 · screen 9 (privacy-preserving age gate). Design-only
/// (no backend yet); the year-of-birth select is presentational for now.
class AgeCheckScreen extends StatelessWidget {
  const AgeCheckScreen({super.key});

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
                    child: RatelMedallion(
                      icon: Icons.cake_outlined,
                      background: tk.warningBg,
                      foreground: tk.brand,
                    ),
                  ),
                  const SizedBox(height: RatelSpacing.lg),
                  Text(
                    S.t('age_title', 'How old are you?'),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: tk.text,
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: RatelSpacing.xs),
                  Text(
                    S.t('age_sub', 'This keeps Ratel safe and age-appropriate.'),
                    textAlign: TextAlign.center,
                    style: TextStyle(color: tk.textMuted, fontSize: 12, height: 1.5),
                  ),
                  const SizedBox(height: RatelSpacing.lg),
                  _SelectField(label: S.t('age_year', 'Year of birth')),
                  const SizedBox(height: RatelSpacing.sm),
                  Text(
                    S.t(
                      'age_note',
                      "Uses Apple/Google age signals where available — we don't store it.",
                    ),
                    textAlign: TextAlign.center,
                    style: TextStyle(color: tk.textMuted, fontSize: 10, height: 1.4),
                  ),
                  const SizedBox(height: RatelSpacing.lg),
                  RatelButton.filled(
                    label: S.t('age_cta', 'Continue'),
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

/// Presentational select row (bordered, trailing chevron) — design-only.
class _SelectField extends StatelessWidget {
  const _SelectField({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final tk = context.tokens;
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(tk.radiusMd),
      child: InkWell(
        onTap: () {},
        borderRadius: BorderRadius.circular(tk.radiusMd),
        child: Container(
          height: 48,
          padding: const EdgeInsets.symmetric(horizontal: RatelSpacing.md),
          decoration: BoxDecoration(
            border: Border.all(color: tk.border, width: tk.hairline),
            borderRadius: BorderRadius.circular(tk.radiusMd),
          ),
          child: Row(
            children: <Widget>[
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(color: tk.textMuted, fontSize: 13),
                ),
              ),
              Icon(Icons.expand_more, size: 18, color: tk.textMuted),
            ],
          ),
        ),
      ),
    );
  }
}
