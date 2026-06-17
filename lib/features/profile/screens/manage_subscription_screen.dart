import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/i18n/strings.dart';
import '../../../core/theme/tokens.dart';

/// Manage subscription — mock Page-6 · screen 12 (status + easy cancel route).
/// Design-only (no backend yet).
class ManageSubscriptionScreen extends StatelessWidget {
  const ManageSubscriptionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final tk = context.tokens;
    Widget detail(String label, String value, Color valueColor) => Container(
          padding: const EdgeInsets.symmetric(vertical: 4),
          decoration: BoxDecoration(border: Border(bottom: BorderSide(color: tk.border, width: tk.hairline))),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text(label, style: TextStyle(color: tk.textMuted, fontSize: 11)),
              Text(value, style: TextStyle(color: valueColor, fontSize: 11)),
            ],
          ),
        );
    Widget linkRow(IconData icon, String label) => Container(
          height: 42,
          alignment: Alignment.center,
          decoration: BoxDecoration(border: Border.all(color: tk.border, width: tk.hairline), borderRadius: BorderRadius.circular(tk.radiusMd)),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Icon(icon, size: 15, color: tk.textMuted),
              const SizedBox(width: RatelSpacing.sm),
              Text(label, style: TextStyle(color: tk.text, fontSize: 12.5)),
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
                  Text(S.t('sub_title', 'Your subscription'), style: TextStyle(color: tk.text, fontSize: 15, fontWeight: FontWeight.w600)),
                  const SizedBox(height: RatelSpacing.sm),
                  Container(
                    padding: const EdgeInsets.all(RatelSpacing.md),
                    decoration: BoxDecoration(color: tk.successBg, borderRadius: BorderRadius.circular(tk.radiusLg)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(S.t('sub_plan', 'Ratel Super · yearly'), style: TextStyle(color: tk.success, fontSize: 14, fontWeight: FontWeight.w600)),
                        const SizedBox(height: 3),
                        Text(S.t('sub_renews', '₹999/yr · renews 30 Jun 2027'), style: TextStyle(color: tk.success, fontSize: 11)),
                      ],
                    ),
                  ),
                  const SizedBox(height: RatelSpacing.md),
                  detail(S.t('sub_status', 'Status'), S.t('sub_status_v', 'Active'), tk.success),
                  const SizedBox(height: RatelSpacing.xs),
                  detail(S.t('sub_billed', 'Billed via'), S.t('sub_billed_v', 'App Store'), tk.text),
                  const SizedBox(height: RatelSpacing.md),
                  linkRow(Icons.open_in_new, S.t('sub_manage', 'Manage in App Store')),
                  const SizedBox(height: RatelSpacing.sm),
                  linkRow(Icons.restore, S.t('sub_restore', 'Restore purchases')),
                  const SizedBox(height: RatelSpacing.md),
                  Center(
                    child: TextButton(
                      onPressed: () => context.push('/cancel'),
                      child: Text(S.t('sub_cancel', 'Cancel subscription'), style: TextStyle(color: tk.danger, fontSize: 12)),
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
