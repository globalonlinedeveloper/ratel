import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/i18n/strings.dart';
import '../../../core/theme/tokens.dart';
import '../../../design_system/components/ratel_button.dart';
import '../../../design_system/components/ratel_medallion.dart';

/// Social-auth consent — mock Page-1 · screen 7 (what Ratel receives from the
/// social provider, before account creation). Design-only (no backend yet).
class SocialConsentScreen extends StatelessWidget {
  const SocialConsentScreen({super.key});

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
                    child: RatelMedallion(
                      icon: Icons.verified_user,
                      background: tk.infoBg,
                      foreground: tk.info,
                    ),
                  ),
                  const SizedBox(height: RatelSpacing.md),
                  Text(
                    S.t('consent_title', 'Ratel will receive'),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: tk.text,
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: RatelSpacing.lg),
                  _ConsentRow(label: S.t('consent_name', 'Your name')),
                  const SizedBox(height: RatelSpacing.md),
                  _ConsentRow(
                    label: S.t('consent_email', 'Your email address'),
                  ),
                  const SizedBox(height: RatelSpacing.md),
                  _ConsentRow(
                    label: S.t('consent_photo', 'Your profile photo'),
                  ),
                  const SizedBox(height: RatelSpacing.lg),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: RatelSpacing.md,
                      vertical: RatelSpacing.sm + 2,
                    ),
                    decoration: BoxDecoration(
                      color: tk.surface2,
                      borderRadius: BorderRadius.circular(tk.radiusMd),
                    ),
                    child: Text(
                      S.t(
                        'consent_note',
                        'Used only to create your account. We never post for you.',
                      ),
                      style: TextStyle(
                        color: tk.textMuted,
                        fontSize: 12,
                        height: 1.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: RatelSpacing.lg),
                  RatelButton.filled(
                    label: S.t('consent_allow', 'Allow & continue'),
                    onPressed: () {},
                  ),
                  const SizedBox(height: RatelSpacing.md),
                  Center(
                    child: TextButton(
                      onPressed: () => context.canPop()
                          ? context.pop()
                          : context.go('/auth'),
                      child: Text(
                        S.t('consent_cancel', 'Cancel'),
                        style: TextStyle(color: tk.textMuted, fontSize: 13),
                      ),
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

/// One granted-permission row: a success check + the data label.
class _ConsentRow extends StatelessWidget {
  const _ConsentRow({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final tk = context.tokens;
    return Row(
      children: <Widget>[
        Icon(Icons.check, size: 18, color: tk.success),
        const SizedBox(width: RatelSpacing.md),
        Expanded(
          child: Text(
            label,
            style: TextStyle(color: tk.text, fontSize: 13),
          ),
        ),
      ],
    );
  }
}
