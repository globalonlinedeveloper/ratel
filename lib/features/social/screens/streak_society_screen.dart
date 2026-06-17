import 'package:flutter/material.dart';
import '../../../core/i18n/strings.dart';
import '../../../core/theme/tokens.dart';

/// Streak Society — mock Page-5 · screen 2 (auto-join tiers gifting freezes).
/// Design-only (no backend yet).
class StreakSocietyScreen extends StatelessWidget {
  const StreakSocietyScreen({super.key});

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
                  Row(
                    children: <Widget>[
                      Icon(Icons.workspace_premium, size: 22, color: RatelSociety.purple),
                      const SizedBox(width: RatelSpacing.sm),
                      Text(S.t('society_title', 'Streak Society'), style: TextStyle(color: tk.text, fontSize: 16, fontWeight: FontWeight.w600)),
                    ],
                  ),
                  const SizedBox(height: RatelSpacing.xs),
                  Text(S.t('society_sub', 'Joins automatically at a 7-day streak. Each tier gifts bonus freezes.'), style: TextStyle(color: tk.textMuted, fontSize: 11)),
                  const SizedBox(height: RatelSpacing.md),
                  Container(
                    padding: const EdgeInsets.all(RatelSpacing.md),
                    decoration: BoxDecoration(color: RatelSociety.purpleBg, border: Border.all(color: RatelSociety.purple, width: 1.5), borderRadius: BorderRadius.circular(tk.radiusMd)),
                    child: Row(
                      children: <Widget>[
                        Icon(Icons.verified, size: 19, color: RatelSociety.purpleDeep),
                        const SizedBox(width: RatelSpacing.sm),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(S.t('society_member', 'Member · day 7+'), style: TextStyle(color: RatelSociety.purpleText, fontSize: 12.5, fontWeight: FontWeight.w600)),
                              Text(S.t('society_member_sub', '3 bonus freezes / 100-day cycle'), style: TextStyle(color: RatelSociety.purpleDeep, fontSize: 10)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: RatelSpacing.sm),
                  _Tier(icon: Icons.local_fire_department, iconColor: tk.coral, title: S.t('society_t1', 'Veteran · 150 days'), sub: S.t('society_t1s', 'exclusive badge + profile flair')),
                  const SizedBox(height: RatelSpacing.sm),
                  _Tier(icon: Icons.diamond_outlined, iconColor: tk.info, title: S.t('society_t2', 'Legend · 365 days'), sub: S.t('society_t2s', 'app icon + year-in-review')),
                  const SizedBox(height: RatelSpacing.md),
                  Material(
                    color: RatelSociety.purple,
                    borderRadius: BorderRadius.circular(tk.radiusMd),
                    clipBehavior: Clip.antiAlias,
                    child: InkWell(
                      onTap: () {},
                      child: Container(
                        height: 44,
                        alignment: Alignment.center,
                        child: Text(S.t('society_cta', 'View my perks'), style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)),
                      ),
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

class _Tier extends StatelessWidget {
  const _Tier({required this.icon, required this.iconColor, required this.title, required this.sub});

  final IconData icon;
  final Color iconColor;
  final String title;
  final String sub;

  @override
  Widget build(BuildContext context) {
    final tk = context.tokens;
    return Container(
      padding: const EdgeInsets.all(RatelSpacing.md),
      decoration: BoxDecoration(border: Border.all(color: tk.border, width: tk.hairline), borderRadius: BorderRadius.circular(tk.radiusMd)),
      child: Row(
        children: <Widget>[
          Icon(icon, size: 19, color: iconColor),
          const SizedBox(width: RatelSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(title, style: TextStyle(color: tk.text, fontSize: 12.5)),
                Text(sub, style: TextStyle(color: tk.textMuted, fontSize: 10)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
