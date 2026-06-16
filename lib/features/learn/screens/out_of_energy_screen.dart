import 'package:flutter/material.dart';
import '../../../core/i18n/strings.dart';
import '../../../core/theme/tokens.dart';
import '../../../design_system/components/ratel_medallion.dart';

/// Out of energy — mock Page-3 · screen 9 (refill options bottom sheet).
/// Design-only (no backend/monetization yet).
class OutOfEnergyScreen extends StatelessWidget {
  const OutOfEnergyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final tk = context.tokens;
    return Scaffold(
      backgroundColor: tk.surface2,
      body: SafeArea(
        child: Column(
          children: <Widget>[
            const Spacer(),
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: tk.surface,
                border: Border(top: BorderSide(color: tk.border, width: tk.hairline)),
                borderRadius: BorderRadius.vertical(top: Radius.circular(tk.radiusLg + 4)),
              ),
              padding: const EdgeInsets.fromLTRB(
                RatelSpacing.lg,
                RatelSpacing.lg,
                RatelSpacing.lg,
                RatelSpacing.xl,
              ),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 440),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Center(
                        child: Container(
                          width: 36,
                          height: 4,
                          decoration: BoxDecoration(
                            color: tk.border,
                            borderRadius: BorderRadius.circular(tk.radiusPill),
                          ),
                        ),
                      ),
                      const SizedBox(height: RatelSpacing.md),
                      Center(
                        child: Column(
                          children: <Widget>[
                            RatelMedallion(
                              icon: Icons.flash_off,
                              background: tk.warningBg,
                              foreground: tk.brand,
                              size: 52,
                              iconSize: 28,
                            ),
                            const SizedBox(height: RatelSpacing.sm),
                            Text(
                              S.t('energy_title', 'Out of energy'),
                              style: TextStyle(color: tk.text, fontSize: 16, fontWeight: FontWeight.w600),
                            ),
                            const SizedBox(height: RatelSpacing.xs),
                            Text(
                              S.t('energy_sub', 'Refills 1 every 15 min — or top up now.'),
                              textAlign: TextAlign.center,
                              style: TextStyle(color: tk.textMuted, fontSize: 11),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: RatelSpacing.md),
                      Container(
                        padding: const EdgeInsets.all(RatelSpacing.md),
                        decoration: BoxDecoration(
                          border: Border.all(color: tk.primary, width: 1.5),
                          borderRadius: BorderRadius.circular(tk.radiusMd),
                        ),
                        child: Row(
                          children: <Widget>[
                            Icon(Icons.gps_fixed, size: 18, color: tk.primary),
                            const SizedBox(width: RatelSpacing.sm),
                            Expanded(
                              child: Text(
                                S.t('energy_practice', 'Practice to earn energy'),
                                style: TextStyle(color: tk.success, fontSize: 12.5),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: RatelSpacing.sm),
                      Row(
                        children: <Widget>[
                          Expanded(
                            child: _OptionPill(
                              icon: Icons.play_arrow,
                              label: S.t('energy_ad', 'Watch ad +5'),
                            ),
                          ),
                          const SizedBox(width: RatelSpacing.sm),
                          Expanded(
                            child: _OptionPill(
                              icon: Icons.diamond_outlined,
                              label: S.t('energy_gems', '750 gems'),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: RatelSpacing.sm),
                      Material(
                        color: tk.win,
                        borderRadius: BorderRadius.circular(tk.radiusMd),
                        clipBehavior: Clip.antiAlias,
                        child: InkWell(
                          onTap: () {},
                          child: Container(
                            height: 44,
                            alignment: Alignment.center,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Icon(Icons.all_inclusive, size: 16, color: tk.text),
                                const SizedBox(width: RatelSpacing.sm),
                                Text(
                                  S.t('energy_super', 'Unlimited with Super'),
                                  style: TextStyle(color: tk.text, fontSize: 13, fontWeight: FontWeight.w600),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// A bordered refill option (watch ad / spend gems).
class _OptionPill extends StatelessWidget {
  const _OptionPill({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final tk = context.tokens;
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(tk.radiusMd),
      child: InkWell(
        onTap: () {},
        borderRadius: BorderRadius.circular(tk.radiusMd),
        child: Container(
          height: 40,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            border: Border.all(color: tk.border, width: tk.hairline),
            borderRadius: BorderRadius.circular(tk.radiusMd),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Icon(icon, size: 15, color: tk.textMuted),
              const SizedBox(width: RatelSpacing.xs),
              Flexible(
                child: Text(
                  label,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: tk.text, fontSize: 11.5),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
