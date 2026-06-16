import 'package:flutter/material.dart';
import '../../../core/i18n/strings.dart';
import '../../../core/theme/tokens.dart';
import '../../../design_system/components/ratel_button.dart';

/// Privacy choices — mock Page-1 · screen 8 (granular, unbundled consent
/// toggles, nothing pre-ticked beyond essentials). Design-only (no backend).
class PrivacyChoicesScreen extends StatefulWidget {
  const PrivacyChoicesScreen({super.key});

  @override
  State<PrivacyChoicesScreen> createState() => _PrivacyChoicesScreenState();
}

class _PrivacyChoicesScreenState extends State<PrivacyChoicesScreen> {
  bool _emails = true;
  bool _ads = false;

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
                  Text(
                    S.t('privacy_title', 'Your privacy choices'),
                    style: TextStyle(
                      color: tk.text,
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: RatelSpacing.xs),
                  Text(
                    S.t(
                      'privacy_sub',
                      'Granular, unbundled, change anytime. No pre-ticked boxes.',
                    ),
                    style: TextStyle(color: tk.textMuted, fontSize: 11),
                  ),
                  const SizedBox(height: RatelSpacing.md),
                  _ToggleRow(
                    title: S.t('privacy_essential', 'Essential'),
                    subtitle: S.t('privacy_essential_sub', 'Required to run the app'),
                    value: true,
                    onChanged: null,
                  ),
                  const SizedBox(height: RatelSpacing.md),
                  _ToggleRow(
                    switchKey: const ValueKey<String>('priv_emails'),
                    title: S.t('privacy_emails', 'Product emails'),
                    subtitle: S.t('privacy_emails_sub', 'Tips & streak reminders'),
                    value: _emails,
                    onChanged: (bool v) => setState(() => _emails = v),
                  ),
                  const SizedBox(height: RatelSpacing.md),
                  _ToggleRow(
                    switchKey: const ValueKey<String>('priv_ads'),
                    title: S.t('privacy_ads', 'Personalized ads'),
                    subtitle: S.t('privacy_ads_sub', 'Off by default'),
                    value: _ads,
                    onChanged: (bool v) => setState(() => _ads = v),
                  ),
                  const SizedBox(height: RatelSpacing.lg),
                  RatelButton.filled(
                    label: S.t('privacy_save', 'Save preferences'),
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

/// One labelled consent toggle inside a hairline-bordered card.
class _ToggleRow extends StatelessWidget {
  const _ToggleRow({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
    this.switchKey,
  });

  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool>? onChanged;
  final Key? switchKey;

  @override
  Widget build(BuildContext context) {
    final tk = context.tokens;
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: RatelSpacing.md,
        vertical: RatelSpacing.md,
      ),
      decoration: BoxDecoration(
        border: Border.all(color: tk.border, width: tk.hairline),
        borderRadius: BorderRadius.circular(tk.radiusMd),
      ),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  title,
                  style: TextStyle(
                    color: tk.text,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(color: tk.textMuted, fontSize: 11),
                ),
              ],
            ),
          ),
          Switch(key: switchKey, value: value, onChanged: onChanged),
        ],
      ),
    );
  }
}
