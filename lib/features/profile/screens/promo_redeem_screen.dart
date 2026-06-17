import 'package:flutter/material.dart';
import '../../../core/i18n/strings.dart';
import '../../../core/theme/tokens.dart';
import '../../../design_system/components/ratel_button.dart';
import '../../../design_system/components/ratel_medallion.dart';

/// Promo / redeem — mock Page-6 · screen 14 (enter a gift/promo code).
/// Design-only (no backend yet).
class PromoRedeemScreen extends StatelessWidget {
  const PromoRedeemScreen({super.key});

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
            padding: const EdgeInsets.fromLTRB(RatelSpacing.xl, 0, RatelSpacing.xl, RatelSpacing.xl),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Center(child: RatelMedallion(icon: Icons.confirmation_number_outlined, background: tk.warningBg, foreground: tk.brand)),
                  const SizedBox(height: RatelSpacing.md),
                  Text(S.t('promo_title', 'Redeem a code'), textAlign: TextAlign.center, style: TextStyle(color: tk.text, fontSize: 17, fontWeight: FontWeight.w600)),
                  const SizedBox(height: RatelSpacing.xs),
                  Text(S.t('promo_sub', 'Have a promo or gift code? Enter it below.'), textAlign: TextAlign.center, style: TextStyle(color: tk.textMuted, fontSize: 12, height: 1.5)),
                  const SizedBox(height: RatelSpacing.lg),
                  Container(
                    height: 46,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(border: Border.all(color: tk.border, width: tk.hairline), borderRadius: BorderRadius.circular(tk.radiusMd)),
                    child: Text(S.t('promo_code', 'CODE'), style: TextStyle(color: tk.textMuted, fontSize: 15, letterSpacing: 2)),
                  ),
                  const SizedBox(height: RatelSpacing.xs),
                  Text(S.t('promo_note', 'via App Store Offer Codes / Play promo — entitlement stays server-verified'), textAlign: TextAlign.center, style: TextStyle(color: tk.textMuted, fontSize: 9)),
                  const SizedBox(height: RatelSpacing.lg),
                  RatelButton.filled(label: S.t('promo_cta', 'Redeem'), onPressed: () {}),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
