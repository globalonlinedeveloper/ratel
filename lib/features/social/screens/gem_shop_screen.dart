import 'package:flutter/material.dart';
import '../../../core/i18n/strings.dart';
import '../../../core/theme/tokens.dart';

/// Gem shop — mock Page-5 · screen 6 (spend gems / top up, no random loot).
/// Design-only (no backend/payments yet).
class GemShopScreen extends StatelessWidget {
  const GemShopScreen({super.key});

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
                  Row(
                    children: <Widget>[
                      Expanded(child: Text(S.t('shop_title', 'Shop'), style: TextStyle(color: tk.text, fontSize: 16, fontWeight: FontWeight.w600))),
                      Icon(Icons.diamond_outlined, size: 16, color: tk.info),
                      const SizedBox(width: 3),
                      Text(S.t('shop_balance', '320'), style: TextStyle(color: tk.info, fontSize: 13)),
                    ],
                  ),
                  const SizedBox(height: RatelSpacing.sm),
                  _ShopRow(icon: Icons.ac_unit, color: tk.info, name: S.t('shop_i1', 'Streak freeze'), sub: S.t('shop_i1s', 'protect a missed day'), price: '200'),
                  const SizedBox(height: RatelSpacing.sm),
                  _ShopRow(icon: Icons.bolt, color: tk.brand, name: S.t('shop_i2', 'Energy refill'), sub: S.t('shop_i2s', 'full bar'), price: '750'),
                  const SizedBox(height: RatelSpacing.sm),
                  _ShopRow(icon: Icons.checkroom, color: tk.hearts, name: S.t('shop_i3', 'Badger outfit'), sub: S.t('shop_i3s', 'cosmetic only'), price: '500'),
                  const SizedBox(height: RatelSpacing.md),
                  Text(S.t('shop_topup', 'Top up gems'), style: TextStyle(color: tk.textMuted, fontSize: 10, fontWeight: FontWeight.w600)),
                  const SizedBox(height: RatelSpacing.sm),
                  Row(
                    children: <Widget>[
                      Expanded(child: _Pack(amount: '500', price: '₹99', highlight: false)),
                      const SizedBox(width: RatelSpacing.sm),
                      Expanded(child: _Pack(amount: '1,200', price: '₹199', highlight: true)),
                    ],
                  ),
                  const SizedBox(height: RatelSpacing.sm),
                  Text(S.t('shop_note', 'No paid random loot · everything earnable free'), textAlign: TextAlign.center, style: TextStyle(color: tk.textMuted, fontSize: 9)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ShopRow extends StatelessWidget {
  const _ShopRow({required this.icon, required this.color, required this.name, required this.sub, required this.price});

  final IconData icon;
  final Color color;
  final String name;
  final String sub;
  final String price;

  @override
  Widget build(BuildContext context) {
    final tk = context.tokens;
    return Container(
      padding: const EdgeInsets.all(RatelSpacing.sm + 2),
      decoration: BoxDecoration(border: Border.all(color: tk.border, width: tk.hairline), borderRadius: BorderRadius.circular(tk.radiusMd)),
      child: Row(
        children: <Widget>[
          Icon(icon, size: 19, color: color),
          const SizedBox(width: RatelSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(name, style: TextStyle(color: tk.text, fontSize: 12)),
                Text(sub, style: TextStyle(color: tk.textMuted, fontSize: 10)),
              ],
            ),
          ),
          Text(price, style: TextStyle(color: tk.info, fontSize: 11)),
        ],
      ),
    );
  }
}

class _Pack extends StatelessWidget {
  const _Pack({required this.amount, required this.price, required this.highlight});

  final String amount;
  final String price;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    final tk = context.tokens;
    return Container(
      padding: const EdgeInsets.all(RatelSpacing.sm + 2),
      decoration: BoxDecoration(
        border: Border.all(color: highlight ? tk.primary : tk.border, width: highlight ? 1.5 : tk.hairline),
        borderRadius: BorderRadius.circular(tk.radiusMd),
      ),
      child: Column(
        children: <Widget>[
          Text(amount, style: TextStyle(color: tk.text, fontSize: 13, fontWeight: FontWeight.w600)),
          Text(price, style: TextStyle(color: tk.primary, fontSize: 10)),
        ],
      ),
    );
  }
}
