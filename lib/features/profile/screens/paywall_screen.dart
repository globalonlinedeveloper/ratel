import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/i18n/strings.dart';
import '../../../core/theme/tokens.dart';
import '../../../design_system/components/ratel_button.dart';
import '../../../design_system/components/ratel_link.dart';

/// Paywall — mock Page-6 · screen 10 (store-safe Super upsell, single CTA).
/// Design-only (no backend/payments yet).
class PaywallScreen extends StatelessWidget {
  const PaywallScreen({super.key});

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
        child: Align(alignment: Alignment.topCenter,
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
                  Center(
                    child: Column(
                      children: <Widget>[
                        Icon(Icons.bolt, size: 26, color: tk.brand),
                        Text(
                          S.t('paywall_title', 'Ratel Super'),
                          style: TextStyle(
                            color: tk.text,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: RatelSpacing.md),
                  _Plan(
                    name: S.t('paywall_free', 'Free'),
                    price: S.t('paywall_free_price', '₹0'),
                  ),
                  const SizedBox(height: RatelSpacing.sm),
                  _Plan(
                    name: S.t('paywall_super', 'Super · yearly'),
                    price: S.t('paywall_super_price', '₹999/yr'),
                    sub: S.t(
                      'paywall_super_sub',
                      'unlimited energy · AI · no ads',
                    ),
                    selected: true,
                  ),
                  const SizedBox(height: RatelSpacing.sm),
                  _Plan(
                    name: S.t('paywall_family', 'Family · 6 seats'),
                    price: S.t('paywall_family_price', '₹1,799/yr'),
                  ),
                  const SizedBox(height: RatelSpacing.sm),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: RatelSpacing.md,
                      vertical: RatelSpacing.sm,
                    ),
                    decoration: BoxDecoration(
                      color: tk.surface2,
                      borderRadius: BorderRadius.circular(tk.radiusSm),
                    ),
                    child: Text.rich(
                      TextSpan(
                        children: <TextSpan>[
                          TextSpan(
                            text: S.t(
                              'paywall_terms_a',
                              'Free for 14 days, then ',
                            ),
                          ),
                          TextSpan(
                            text: S.t('paywall_terms_b', '₹999/year'),
                            style: const TextStyle(fontWeight: FontWeight.w700),
                          ),
                          TextSpan(
                            text: S.t(
                              'paywall_terms_c',
                              ' starting 30 Jun 2026. Auto-renews yearly; cancel anytime in Settings.',
                            ),
                          ),
                        ],
                        style: TextStyle(
                          color: tk.textMuted,
                          fontSize: 10,
                          height: 1.5,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: RatelSpacing.md),
                  RatelButton.filled(
                    label: S.t('paywall_cta', 'Start free trial'),
                    onPressed: () => context.push('/checkout'),
                  ),
                  const SizedBox(height: RatelSpacing.sm),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      RatelLink(
                        label: S.t('paywall_restore', 'Restore'),
                        onTap: () {},
                        fontSize: 10,
                      ),
                      const SizedBox(width: RatelSpacing.md),
                      RatelLink(
                        label: S.t('paywall_tos', 'Terms'),
                        onTap: () {},
                        fontSize: 10,
                      ),
                      const SizedBox(width: RatelSpacing.md),
                      RatelLink(
                        label: S.t('paywall_privacy', 'Privacy'),
                        onTap: () {},
                        fontSize: 10,
                      ),
                    ],
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

class _Plan extends StatelessWidget {
  const _Plan({
    required this.name,
    required this.price,
    this.sub,
    this.selected = false,
  });

  final String name;
  final String price;
  final String? sub;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final tk = context.tokens;
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: RatelSpacing.md,
        vertical: RatelSpacing.sm + 2,
      ),
      decoration: BoxDecoration(
        color: selected ? tk.successBg : Colors.transparent,
        border: Border.all(
          color: selected ? tk.primary : tk.border,
          width: selected ? 2 : tk.hairline,
        ),
        borderRadius: BorderRadius.circular(tk.radiusMd),
      ),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  name,
                  style: TextStyle(
                    color: selected ? tk.success : tk.text,
                    fontSize: 12.5,
                    fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                  ),
                ),
                if (sub != null)
                  Text(
                    sub!,
                    style: TextStyle(
                      color: selected ? tk.success : tk.textMuted,
                      fontSize: 9,
                    ),
                  ),
              ],
            ),
          ),
          Text(
            price,
            style: TextStyle(
              color: selected ? tk.success : tk.textMuted,
              fontSize: 12,
              fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}
