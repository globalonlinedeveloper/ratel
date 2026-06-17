import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/i18n/strings.dart';
import '../../../core/theme/tokens.dart';
import '../../../design_system/components/ratel_settings_row.dart';

/// Help & about — mock Page-6 · screen 9 (support + legal links). Design-only.
/// FAQ/Contact route to their screens; OSS uses Flutter's built-in
/// `showLicensePage` (auto-aggregates every dependency LICENSE). Terms/Privacy
/// wire in the next increment (P0-G2).
class HelpLegalScreen extends StatelessWidget {
  const HelpLegalScreen({super.key});

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
        child: Align(alignment: Alignment.topCenter,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(RatelSpacing.md, 0, RatelSpacing.md, RatelSpacing.md),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text(S.t('help_title', 'Help & about'), style: TextStyle(color: tk.text, fontSize: 16, fontWeight: FontWeight.w600)),
                  const SizedBox(height: RatelSpacing.sm),
                  RatelSettingsRow(icon: Icons.help_outline, iconColor: tk.primary, label: S.t('help_faq', 'FAQ & help centre'), onTap: () => context.push('/faq')),
                  RatelSettingsRow(icon: Icons.report_gmailerrorred, iconColor: tk.coral, label: S.t('help_contact', 'Contact & report a bug'), onTap: () => context.push('/contact')),
                  RatelSettingsRow(icon: Icons.description_outlined, iconColor: tk.info, label: S.t('help_terms', 'Terms of Service'), onTap: () => context.push('/terms')),
                  RatelSettingsRow(icon: Icons.lock_outline, iconColor: RatelSociety.purple, label: S.t('help_privacy', 'Privacy Policy'), onTap: () => context.push('/privacy-policy')),
                  RatelSettingsRow(icon: Icons.workspace_premium_outlined, iconColor: tk.textMuted, label: S.t('help_oss', 'Open-source licenses'), onTap: () => showLicensePage(context: context, applicationName: S.t('app_name', 'Ratel'), applicationVersion: S.t('app_version', '2.0')), divider: false),
                  const SizedBox(height: RatelSpacing.md),
                  Center(child: Text(S.t('help_version', 'Ratel v2.0 · made with care'), style: TextStyle(color: tk.textMuted, fontSize: 10))),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
