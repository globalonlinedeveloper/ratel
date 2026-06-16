import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/i18n/strings.dart';
import '../../../core/theme/tokens.dart';
import '../../../design_system/components/ratel_button.dart';

/// Auth hub — mock Page-1 · screen 3 (passkey-first + social/email options).
/// Design-only (no backend until phase 3): passkey/social options are inert
/// for now; "Use email" and "Try it free" route to the existing screens.
class AuthHubScreen extends StatelessWidget {
  const AuthHubScreen({super.key});

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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          color: tk.warningBg,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.sentiment_satisfied_alt,
                          size: 24,
                          color: tk.brand,
                        ),
                      ),
                      const _LanguageChip(),
                    ],
                  ),
                  const SizedBox(height: RatelSpacing.lg),
                  Text(
                    S.t('auth_title', 'Sign in'),
                    style: TextStyle(
                      color: tk.text,
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: RatelSpacing.md),
                  RatelButton.filled(
                    icon: Icons.fingerprint,
                    label: S.t('auth_passkey', 'Sign in with a passkey'),
                    onPressed: () {},
                  ),
                  const SizedBox(height: RatelSpacing.sm),
                  RatelButton.neutral(
                    icon: Icons.g_mobiledata,
                    label: S.t('auth_google', 'Continue with Google'),
                    onPressed: () {},
                  ),
                  const SizedBox(height: RatelSpacing.sm),
                  RatelButton.neutral(
                    icon: Icons.apple,
                    label: S.t('auth_apple', 'Continue with Apple'),
                    onPressed: () {},
                  ),
                  const SizedBox(height: RatelSpacing.sm),
                  RatelButton.neutral(
                    icon: Icons.phone_iphone,
                    label: S.t('auth_phone', 'Continue with phone'),
                    onPressed: () {},
                  ),
                  const SizedBox(height: RatelSpacing.sm),
                  RatelButton.neutral(
                    icon: Icons.mail_outline,
                    label: S.t('auth_email', 'Use email'),
                    onPressed: () => context.push('/login'),
                  ),
                  const SizedBox(height: RatelSpacing.md),
                  RatelButton.outline(
                    icon: Icons.bolt,
                    label: S.t('auth_try_free', 'Try it free'),
                    onPressed: () => context.push('/signup'),
                  ),
                  const SizedBox(height: RatelSpacing.lg),
                  Text(
                    S.t(
                      'auth_footer',
                      'Passkey-first · Credential Manager · Terms & Privacy',
                    ),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: tk.textMuted,
                      fontSize: 11,
                      height: 1.4,
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

/// Compact language selector chip (design-only).
class _LanguageChip extends StatelessWidget {
  const _LanguageChip();

  @override
  Widget build(BuildContext context) {
    final tk = context.tokens;
    return Material(
      color: Colors.transparent,
      shape: StadiumBorder(side: BorderSide(color: tk.border)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {},
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: RatelSpacing.sm,
            vertical: 5,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Icon(Icons.language, size: 14, color: tk.textMuted),
              const SizedBox(width: 4),
              Text(
                S.t('auth_lang', 'EN'),
                style: TextStyle(
                  color: tk.textMuted,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Icon(Icons.expand_more, size: 14, color: tk.textMuted),
            ],
          ),
        ),
      ),
    );
  }
}
