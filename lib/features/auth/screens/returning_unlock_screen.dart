import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/i18n/strings.dart';
import '../../../core/theme/tokens.dart';
import '../../../design_system/components/ratel_button.dart';
import '../../../design_system/components/ratel_link.dart';
import '../../../design_system/components/ratel_medallion.dart';

/// Returning-user unlock — mock Page-1 · screen 4 (biometric quick-unlock for a
/// known account). Design-only (no backend until phase 3).
class ReturningUnlockScreen extends StatelessWidget {
  const ReturningUnlockScreen({super.key});

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
                    child: _InitialsAvatar(
                      initials: S.t('unlock_initials', 'RS'),
                    ),
                  ),
                  const SizedBox(height: RatelSpacing.lg),
                  Text(
                    S.t('unlock_title', 'Welcome back, Raj'),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: tk.text,
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: RatelSpacing.xs),
                  Text(
                    S.t('unlock_sub', 'Unlock to continue your 7-day streak'),
                    textAlign: TextAlign.center,
                    style: TextStyle(color: tk.textMuted, fontSize: 13),
                  ),
                  const SizedBox(height: RatelSpacing.lg),
                  Center(
                    child: RatelMedallion(
                      icon: Icons.face,
                      background: tk.successBg,
                      foreground: tk.primary,
                      size: 72,
                      iconSize: 40,
                    ),
                  ),
                  const SizedBox(height: RatelSpacing.lg),
                  RatelButton.filled(
                    icon: Icons.fingerprint,
                    label: S.t('unlock_cta', 'Unlock with Face ID'),
                    onPressed: () {},
                  ),
                  const SizedBox(height: RatelSpacing.md),
                  Center(
                    child: RatelLink(
                      label: S.t('unlock_different', 'Use a different account'),
                      onTap: () => context.go('/auth'),
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

/// Round avatar showing the returning user's initials.
class _InitialsAvatar extends StatelessWidget {
  const _InitialsAvatar({required this.initials});

  final String initials;

  @override
  Widget build(BuildContext context) {
    final tk = context.tokens;
    return Container(
      width: 80,
      height: 80,
      alignment: Alignment.center,
      decoration: BoxDecoration(color: tk.warningBg, shape: BoxShape.circle),
      child: Text(
        initials,
        style: TextStyle(
          color: tk.brand,
          fontSize: 26,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
