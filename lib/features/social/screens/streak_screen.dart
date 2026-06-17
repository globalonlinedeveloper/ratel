import 'package:flutter/material.dart';
import '../../../core/i18n/strings.dart';
import '../../../core/theme/tokens.dart';
import '../../../design_system/components/ratel_button.dart';
import '../../../design_system/components/ratel_medallion.dart';

/// Streak — mock Page-5 · screen 1 (week grid, freezes-as-gift, repair/wager).
/// Design-only (no backend yet).
class StreakScreen extends StatelessWidget {
  const StreakScreen({super.key});

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
            padding: const EdgeInsets.fromLTRB(RatelSpacing.md, 0, RatelSpacing.md, RatelSpacing.md),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Center(
                    child: Column(
                      children: <Widget>[
                        RatelMedallion(icon: Icons.local_fire_department, background: tk.warningBg, foreground: tk.coral, size: 58, iconSize: 32),
                        const SizedBox(height: RatelSpacing.xs),
                        Text(S.t('streakg_days', '7 days'), style: TextStyle(color: tk.text, fontSize: 22, fontWeight: FontWeight.w700)),
                      ],
                    ),
                  ),
                  const SizedBox(height: RatelSpacing.sm),
                  Row(
                    children: <Widget>[
                      for (int i = 0; i < 7; i++)
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 2),
                            child: Container(
                              height: 30,
                              decoration: BoxDecoration(color: tk.coral, borderRadius: BorderRadius.circular(tk.radiusSm)),
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: RatelSpacing.xs),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      for (final String m in <String>['7 ✓', '30', '100', '365'])
                        Text(m, style: TextStyle(color: tk.textMuted, fontSize: 9.5)),
                    ],
                  ),
                  const SizedBox(height: RatelSpacing.sm),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: RatelSpacing.md, vertical: RatelSpacing.sm),
                    decoration: BoxDecoration(color: tk.infoBg, borderRadius: BorderRadius.circular(tk.radiusMd)),
                    child: Row(
                      children: <Widget>[
                        Icon(Icons.ac_unit, size: 17, color: tk.info),
                        const SizedBox(width: RatelSpacing.sm),
                        Expanded(child: Text(S.t('streakg_freeze', '2 freezes — auto-applied if you miss a day'), style: TextStyle(color: tk.info, fontSize: 11))),
                      ],
                    ),
                  ),
                  const SizedBox(height: RatelSpacing.sm),
                  Row(
                    children: <Widget>[
                      Expanded(child: RatelButton.neutral(icon: Icons.volunteer_activism, label: S.t('streakg_repair', 'Repair'), onPressed: () {})),
                      const SizedBox(width: RatelSpacing.sm),
                      Expanded(child: RatelButton.neutral(icon: Icons.toll, label: S.t('streakg_wager', 'Wager'), onPressed: () {})),
                    ],
                  ),
                  const SizedBox(height: RatelSpacing.xs),
                  Text(S.t('streakg_note', 'freeze is a gift, never a guilt-trip · celebrations at 30/100/365'), textAlign: TextAlign.center, style: TextStyle(color: tk.textMuted, fontSize: 9)),
                  const SizedBox(height: RatelSpacing.md),
                  RatelButton.filled(label: S.t('streakg_cta', 'Keep it going'), onPressed: () {}),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
