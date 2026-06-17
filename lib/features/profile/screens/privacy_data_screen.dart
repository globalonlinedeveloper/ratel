import 'package:flutter/material.dart';
import '../../../core/i18n/strings.dart';
import '../../../core/theme/tokens.dart';
import '../../../design_system/components/ratel_toggle_row.dart';

/// Privacy & data — mock Page-6 · screen 7 (default-off consent + export/delete).
/// Design-only (no backend yet).
class PrivacyDataScreen extends StatefulWidget {
  const PrivacyDataScreen({super.key});

  @override
  State<PrivacyDataScreen> createState() => _PrivacyDataScreenState();
}

class _PrivacyDataScreenState extends State<PrivacyDataScreen> {
  bool _analytics = false;
  bool _ads = false;
  bool _personalization = true;

  @override
  Widget build(BuildContext context) {
    final tk = context.tokens;
    Widget dataRow(IconData icon, String label, Color color) => Container(
          height: 40,
          padding: const EdgeInsets.symmetric(horizontal: RatelSpacing.md),
          decoration: BoxDecoration(border: Border.all(color: tk.border, width: tk.hairline), borderRadius: BorderRadius.circular(tk.radiusMd)),
          child: Row(
            children: <Widget>[
              Icon(icon, size: 16, color: color),
              const SizedBox(width: RatelSpacing.sm),
              Text(label, style: TextStyle(color: color, fontSize: 12)),
            ],
          ),
        );
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
                  Text(S.t('pd_title', 'Privacy & data'), style: TextStyle(color: tk.text, fontSize: 15, fontWeight: FontWeight.w600)),
                  const SizedBox(height: RatelSpacing.sm),
                  Text(S.t('pd_consent', 'Consent — all off by default'), style: TextStyle(color: tk.textMuted, fontSize: 10, fontWeight: FontWeight.w600)),
                  const SizedBox(height: RatelSpacing.sm),
                  RatelToggleRow(label: S.t('pd_analytics', 'Analytics'), subtitle: S.t('pd_analytics_sub', 'improve the app'), value: _analytics, onChanged: (bool v) => setState(() => _analytics = v)),
                  const SizedBox(height: RatelSpacing.md),
                  RatelToggleRow(label: S.t('pd_ads', 'Personalized ads'), subtitle: S.t('pd_ads_sub', 'ATT / Play opt-in'), value: _ads, onChanged: (bool v) => setState(() => _ads = v)),
                  const SizedBox(height: RatelSpacing.md),
                  RatelToggleRow(label: S.t('pd_personal', 'Personalization'), subtitle: S.t('pd_personal_sub', 'tailor lessons'), value: _personalization, onChanged: (bool v) => setState(() => _personalization = v)),
                  const SizedBox(height: RatelSpacing.md),
                  dataRow(Icons.download, S.t('pd_export', 'Export my data'), tk.primary),
                  const SizedBox(height: RatelSpacing.sm),
                  dataRow(Icons.delete_outline, S.t('pd_delete', 'Delete my data'), tk.danger),
                  const SizedBox(height: RatelSpacing.sm),
                  Text(S.t('pd_note', 'DPDP / GDPR rights · consent receipt kept · respond ≤ 90 days'), style: TextStyle(color: tk.textMuted, fontSize: 9)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
