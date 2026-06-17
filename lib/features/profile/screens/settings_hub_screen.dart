import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/i18n/strings.dart';
import '../../../core/theme/tokens.dart';
import '../../../design_system/components/ratel_settings_row.dart';

/// Settings hub — mock Page-6 · screen 4 (top-level settings list). Design-only.
class SettingsHubScreen extends StatelessWidget {
  const SettingsHubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final tk = context.tokens;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Navigator.of(context).canPop()
            ? IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => Navigator.of(context).maybePop())
            : null,
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(RatelSpacing.md, 0, RatelSpacing.md, RatelSpacing.md),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text(S.t('settings_title', 'Settings'), style: TextStyle(color: tk.text, fontSize: 16, fontWeight: FontWeight.w600)),
                  const SizedBox(height: RatelSpacing.sm),
                  RatelSettingsRow(icon: Icons.volume_up, iconColor: tk.primary, label: S.t('settings_audio', 'Audio')),
                  RatelSettingsRow(icon: Icons.school_outlined, iconColor: tk.info, label: S.t('settings_learning', 'Learning')),
                  RatelSettingsRow(icon: Icons.palette_outlined, iconColor: tk.hearts, label: S.t('settings_appearance', 'Appearance & language'), onTap: () => context.push('/appearance')),
                  RatelSettingsRow(icon: Icons.accessible, iconColor: RatelSociety.purple, label: S.t('settings_a11y', 'Accessibility'), onTap: () => context.push('/accessibility')),
                  RatelSettingsRow(icon: Icons.shield_outlined, iconColor: tk.primary, label: S.t('settings_privacy', 'Privacy & data'), onTap: () => context.push('/privacy-data')),
                  RatelSettingsRow(icon: Icons.notifications_none, iconColor: tk.brand, label: S.t('settings_notif', 'Notifications'), onTap: () => context.push('/notifications')),
                  RatelSettingsRow(icon: Icons.grid_view, iconColor: tk.info, label: S.t('settings_widgets', 'Widgets')),
                  RatelSettingsRow(icon: Icons.manage_accounts_outlined, iconColor: tk.textMuted, label: S.t('settings_account', 'Account'), divider: false),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
