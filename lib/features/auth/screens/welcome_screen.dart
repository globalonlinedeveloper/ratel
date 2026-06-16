import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/i18n/strings.dart';
import '../../../core/theme/tokens.dart';
import '../../../design_system/components/ratel_button.dart';
import '../../../design_system/components/ratel_link.dart';

/// Welcome — mock Page-1 · screen 2 (value prop + social proof + entry points).
/// Design-only (no backend until phase 3).
class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final tk = context.tokens;
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(RatelSpacing.xl),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Center(
                    child: Container(
                      width: 112,
                      height: 112,
                      decoration: BoxDecoration(
                        color: tk.successBg,
                        borderRadius: BorderRadius.circular(tk.radiusLg),
                      ),
                      child: Icon(
                        Icons.rocket_launch,
                        size: 56,
                        color: tk.primary,
                      ),
                    ),
                  ),
                  const SizedBox(height: RatelSpacing.xl),
                  Text(
                    S.t('welcome_headline', 'Learn by doing,\n5 minutes a day'),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: tk.text,
                      fontSize: 23,
                      fontWeight: FontWeight.w800,
                      height: 1.25,
                    ),
                  ),
                  const SizedBox(height: RatelSpacing.lg),
                  const _SocialProof(),
                  const SizedBox(height: RatelSpacing.xl),
                  const _Dots(),
                  const SizedBox(height: RatelSpacing.xl),
                  RatelButton.filled(
                    label: S.t('welcome_cta', 'Get started'),
                    onPressed: () => context.push('/auth'),
                  ),
                  const SizedBox(height: RatelSpacing.md),
                  Center(
                    child: RatelLink(
                      label: S.t(
                        'welcome_have_account',
                        'I already have an account',
                      ),
                      onTap: () => context.push('/login'),
                    ),
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

/// Star rating + learner/language counts (social proof row).
class _SocialProof extends StatelessWidget {
  const _SocialProof();

  @override
  Widget build(BuildContext context) {
    final tk = context.tokens;
    final TextStyle muted = TextStyle(color: tk.textMuted, fontSize: 12);
    return Wrap(
      alignment: WrapAlignment.center,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: <Widget>[
        Icon(Icons.star, size: 14, color: tk.brand),
        const SizedBox(width: 3),
        Text(
          S.t('welcome_rating', '4.8'),
          style: TextStyle(
            color: tk.brand,
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
        ),
        Text('  ·  ', style: muted),
        Text(S.t('welcome_learners', '2M+ learners'), style: muted),
        Text('  ·  ', style: muted),
        Text(S.t('welcome_languages', '40 languages'), style: muted),
      ],
    );
  }
}

/// Carousel position dots (middle active) — decorative.
class _Dots extends StatelessWidget {
  const _Dots();

  @override
  Widget build(BuildContext context) {
    final tk = context.tokens;
    Widget dot(bool active) => Container(
          width: active ? 20 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: active ? tk.primary : tk.border,
            borderRadius: BorderRadius.circular(tk.radiusPill),
          ),
        );
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        dot(false),
        const SizedBox(width: 7),
        dot(true),
        const SizedBox(width: 7),
        dot(false),
      ],
    );
  }
}
