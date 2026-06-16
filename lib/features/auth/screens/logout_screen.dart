import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/i18n/strings.dart';
import '../../../core/theme/tokens.dart';
import '../../../design_system/components/ratel_button.dart';

/// Logout confirm — mock Page-1 · screen 18 (bottom-sheet style confirmation).
/// Design-only (no backend yet).
class LogoutScreen extends StatelessWidget {
  const LogoutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final tk = context.tokens;
    return Scaffold(
      backgroundColor: tk.surface2,
      body: SafeArea(
        child: Column(
          children: <Widget>[
            const Spacer(),
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: tk.surface,
                border: Border(top: BorderSide(color: tk.border, width: tk.hairline)),
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
                      Center(
                        child: Container(
                          width: 36,
                          height: 4,
                          decoration: BoxDecoration(
                            color: tk.border,
                            borderRadius: BorderRadius.circular(tk.radiusPill),
                          ),
                        ),
                      ),
                      const SizedBox(height: RatelSpacing.md),
                      Text(
                        S.t('logout_title', 'Log out?'),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: tk.text,
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: RatelSpacing.xs),
                      Text(
                        S.t(
                          'logout_body',
                          'Your progress is saved to your account — log back in any time.',
                        ),
                        textAlign: TextAlign.center,
                        style: TextStyle(color: tk.textMuted, fontSize: 12, height: 1.5),
                      ),
                      const SizedBox(height: RatelSpacing.md),
                      RatelButton.filled(
                        label: S.t('logout_stay', 'Stay logged in'),
                        onPressed: () => Navigator.of(context).maybePop(),
                      ),
                      const SizedBox(height: RatelSpacing.sm),
                      RatelButton.dangerOutline(
                        label: S.t('logout_confirm', 'Log out'),
                        onPressed: () => context.go('/welcome'),
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
