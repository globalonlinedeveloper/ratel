import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/i18n/strings.dart';
import '../../../core/theme/tokens.dart';
import '../../../design_system/components/ratel_button.dart';
import '../../../design_system/components/ratel_select_field.dart';
import '../../../design_system/components/ratel_settings_row.dart';

/// Account screen (`/account`) — mock Page-6. The hub for profile edits,
/// security, data export, and the existing Logout/Delete flows. Design-only:
/// the edit / change-password / export actions are phase-3 stubs
/// (`onPressed: () {}`); Logout/Delete link the real existing screens.
class AccountScreen extends StatelessWidget {
  const AccountScreen({super.key});

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
        child: Align(
          alignment: Alignment.topCenter,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(
              RatelSpacing.md,
              0,
              RatelSpacing.md,
              RatelSpacing.md,
            ),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text(
                    S.t('account_title', 'Account'),
                    style: TextStyle(
                      color: tk.text,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: RatelSpacing.sm),
                  const _Caption('account_sec_profile', 'Profile'),
                  const SizedBox(height: RatelSpacing.xs),
                  RatelSelectField(
                    leadingIcon: Icons.alternate_email,
                    label: S.t('account_email', 'Email · raj@example.com'),
                    onTap: () {},
                  ),
                  const SizedBox(height: RatelSpacing.sm),
                  RatelSelectField(
                    leadingIcon: Icons.person_outline,
                    label: S.t('account_username', 'Username · raj_learns'),
                    onTap: () {},
                  ),
                  const SizedBox(height: RatelSpacing.md),
                  const _Caption('account_sec_security', 'Security'),
                  const SizedBox(height: RatelSpacing.xs),
                  RatelButton.neutral(
                    icon: Icons.lock_outline,
                    label: S.t('account_change_pw', 'Change password'),
                    onPressed: () {},
                  ),
                  const SizedBox(height: RatelSpacing.md),
                  const _Caption('account_sec_data', 'Your data'),
                  const SizedBox(height: RatelSpacing.xs),
                  RatelButton.neutral(
                    icon: Icons.download_outlined,
                    label: S.t('account_export', 'Export my data'),
                    onPressed: () {},
                  ),
                  const SizedBox(height: RatelSpacing.xs),
                  Text(
                    S.t(
                      'account_export_note',
                      'We email a copy of your learning data within 30 days.',
                    ),
                    style: TextStyle(
                      color: tk.textMuted,
                      fontSize: 10,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: RatelSpacing.md),
                  const _Caption('account_sec_session', 'Session'),
                  const SizedBox(height: RatelSpacing.xs),
                  RatelSettingsRow(
                    icon: Icons.logout,
                    iconColor: tk.textMuted,
                    label: S.t('account_logout', 'Log out'),
                    onTap: () => context.push('/logout'),
                  ),
                  RatelSettingsRow(
                    icon: Icons.delete_outline,
                    iconColor: tk.danger,
                    label: S.t('account_delete', 'Delete account'),
                    onTap: () => context.push('/delete'),
                    divider: false,
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

/// Small muted section caption.
class _Caption extends StatelessWidget {
  const _Caption(this.keyName, this.fallback);

  final String keyName;
  final String fallback;

  @override
  Widget build(BuildContext context) {
    final tk = context.tokens;
    return Text(
      S.t(keyName, fallback),
      style: TextStyle(
        color: tk.textMuted,
        fontSize: 10,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}
