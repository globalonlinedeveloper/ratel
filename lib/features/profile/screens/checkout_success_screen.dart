import 'package:flutter/material.dart';
import '../../../core/i18n/strings.dart';
import '../../../core/theme/tokens.dart';
import '../../../design_system/components/ratel_button.dart';
import '../../../design_system/components/ratel_medallion.dart';

/// Checkout success — mock Page-6 · screen 11 (trial confirmed). Design-only.
class CheckoutSuccessScreen extends StatelessWidget {
  const CheckoutSuccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final tk = context.tokens;
    Widget summaryRow(String label, String value) => Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Text(label, style: TextStyle(color: tk.textMuted, fontSize: 11)),
            Text(value, style: TextStyle(color: tk.text, fontSize: 11)),
          ],
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
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(RatelSpacing.lg),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Center(child: RatelMedallion(icon: Icons.check_circle, background: tk.successBg, foreground: tk.success, size: 74, iconSize: 42)),
                  const SizedBox(height: RatelSpacing.md),
                  Text(S.t('checkout_title', "You're Super!"), textAlign: TextAlign.center, style: TextStyle(color: tk.text, fontSize: 18, fontWeight: FontWeight.w600)),
                  const SizedBox(height: RatelSpacing.xs),
                  Text(S.t('checkout_sub', 'Trial active until 30 Jun 2026.\nFirst charge ₹999 on that date.'), textAlign: TextAlign.center, style: TextStyle(color: tk.textMuted, fontSize: 12, height: 1.5)),
                  const SizedBox(height: RatelSpacing.md),
                  Container(
                    padding: const EdgeInsets.all(RatelSpacing.md),
                    decoration: BoxDecoration(color: tk.surface2, borderRadius: BorderRadius.circular(tk.radiusMd)),
                    child: Column(
                      children: <Widget>[
                        summaryRow(S.t('checkout_plan', 'Plan'), S.t('checkout_plan_v', 'Super · yearly')),
                        const SizedBox(height: 5),
                        summaryRow(S.t('checkout_next', 'Next charge'), S.t('checkout_next_v', '30 Jun 2026')),
                      ],
                    ),
                  ),
                  const SizedBox(height: RatelSpacing.md),
                  RatelButton.filled(label: S.t('checkout_cta', 'Start learning'), onPressed: () {}),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
