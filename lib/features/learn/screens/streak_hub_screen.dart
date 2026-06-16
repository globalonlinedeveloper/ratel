import 'package:flutter/material.dart';
import '../../../core/i18n/strings.dart';
import '../../../core/theme/tokens.dart';
import '../../../design_system/components/ratel_button.dart';
import '../../../design_system/components/ratel_medallion.dart';

/// Streak & quests hub — mock Page-3 · screen 11. Design-only (no backend yet).
class StreakHubScreen extends StatelessWidget {
  const StreakHubScreen({super.key});

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
                        RatelMedallion(
                          icon: Icons.local_fire_department,
                          background: tk.warningBg,
                          foreground: tk.coral,
                          size: 60,
                          iconSize: 34,
                        ),
                        const SizedBox(height: RatelSpacing.xs),
                        Text(
                          S.t('streak_days', '7 days'),
                          style: TextStyle(color: tk.text, fontSize: 22, fontWeight: FontWeight.w700),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: RatelSpacing.md),
                  Row(
                    children: <Widget>[
                      _PerkCard(icon: Icons.ac_unit, label: S.t('streak_freeze', 'Freeze ×2'), color: tk.info),
                      const SizedBox(width: RatelSpacing.sm),
                      _PerkCard(icon: Icons.toll, label: S.t('streak_double', 'Double or nothing'), color: tk.brand),
                      const SizedBox(width: RatelSpacing.sm),
                      _PerkCard(icon: Icons.workspace_premium, label: S.t('streak_society', 'Society'), color: tk.brand),
                    ],
                  ),
                  const SizedBox(height: RatelSpacing.md),
                  Text(
                    S.t('streak_quests', "Today's quests"),
                    style: TextStyle(color: tk.text, fontSize: 12, fontWeight: FontWeight.w600),
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
                    child: Row(
                      children: <Widget>[
                        Icon(Icons.bolt, size: 16, color: tk.primary),
                        const SizedBox(width: RatelSpacing.sm),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                S.t('streak_q1', 'Earn 30 XP'),
                                style: TextStyle(color: tk.text, fontSize: 11.5),
                              ),
                              const SizedBox(height: 4),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(tk.radiusPill),
                                child: LinearProgressIndicator(
                                  value: 0.6,
                                  minHeight: 5,
                                  backgroundColor: tk.border,
                                  valueColor: AlwaysStoppedAnimation<Color>(tk.primary),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: RatelSpacing.sm),
                        Text('18/30', style: TextStyle(color: tk.textMuted, fontSize: 10)),
                      ],
                    ),
                  ),
                  const SizedBox(height: RatelSpacing.sm),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: RatelSpacing.md,
                      vertical: RatelSpacing.sm + 2,
                    ),
                    decoration: BoxDecoration(
                      color: tk.surface2,
                      borderRadius: BorderRadius.circular(tk.radiusSm),
                    ),
                    child: Row(
                      children: <Widget>[
                        Icon(Icons.group, size: 16, color: tk.hearts),
                        const SizedBox(width: RatelSpacing.sm),
                        Expanded(
                          child: Text(
                            S.t('streak_q2', 'Friends Quest · 100 gems'),
                            style: TextStyle(color: tk.text, fontSize: 11.5),
                          ),
                        ),
                        Text(
                          S.t('streak_join', 'Join'),
                          style: TextStyle(color: tk.success, fontSize: 10),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: RatelSpacing.md),
                  RatelButton.filled(
                    label: S.t('streak_cta', 'View leagues'),
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

/// A streak perk card (Freeze / Double / Society).
class _PerkCard extends StatelessWidget {
  const _PerkCard({required this.icon, required this.label, required this.color});

  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final tk = context.tokens;
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(RatelSpacing.sm + 1),
        decoration: BoxDecoration(
          border: Border.all(color: tk.border, width: tk.hairline),
          borderRadius: BorderRadius.circular(tk.radiusSm),
        ),
        child: Column(
          children: <Widget>[
            Icon(icon, size: 18, color: color),
            const SizedBox(height: 3),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(color: tk.text, fontSize: 10),
            ),
          ],
        ),
      ),
    );
  }
}
