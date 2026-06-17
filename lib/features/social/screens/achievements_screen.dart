import 'package:flutter/material.dart';
import '../../../core/i18n/strings.dart';
import '../../../core/theme/tokens.dart';
import '../../../design_system/components/ratel_button.dart';

/// Achievements — mock Page-5 · screen 4 (award ladders grid). Design-only.
class AchievementsScreen extends StatelessWidget {
  const AchievementsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final tk = context.tokens;
    Widget tab(String label, bool active) => Expanded(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 3),
            padding: const EdgeInsets.symmetric(vertical: RatelSpacing.xs + 2),
            decoration: BoxDecoration(color: active ? tk.primary : tk.surface2, borderRadius: BorderRadius.circular(tk.radiusSm)),
            child: Text(label, textAlign: TextAlign.center, style: TextStyle(color: active ? Colors.white : tk.text, fontSize: 11)),
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
                  Row(
                    children: <Widget>[
                      tab(S.t('ach_awards', 'Awards'), true),
                      tab(S.t('ach_records', 'Personal records'), false),
                    ],
                  ),
                  const SizedBox(height: RatelSpacing.md),
                  Row(
                    children: <Widget>[
                      _Badge(icon: Icons.local_fire_department, color: tk.brand, bg: tk.warningBg, label: S.t('ach_gold', 'Gold')),
                      _Badge(icon: Icons.bolt, color: tk.success, bg: tk.successBg, label: S.t('ach_silver', 'Silver')),
                      _Badge(icon: Icons.school_outlined, color: tk.info, bg: tk.infoBg, label: S.t('ach_bronze', 'Bronze')),
                    ],
                  ),
                  const SizedBox(height: RatelSpacing.sm),
                  Row(
                    children: <Widget>[
                      for (int i = 0; i < 3; i++)
                        _Badge(icon: Icons.lock_outline, color: tk.textMuted, bg: tk.page, label: S.t('ach_locked', 'Locked')),
                    ],
                  ),
                  const SizedBox(height: RatelSpacing.sm),
                  Text(S.t('ach_note', 'Awards = tiered ladders · Records = your personal bests'), style: TextStyle(color: tk.textMuted, fontSize: 9.5)),
                  const SizedBox(height: RatelSpacing.md),
                  RatelButton.filled(label: S.t('ach_cta', 'See all 40'), onPressed: () {}),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({required this.icon, required this.color, required this.bg, required this.label});

  final IconData icon;
  final Color color;
  final Color bg;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: <Widget>[
          Container(
            width: 48,
            height: 48,
            alignment: Alignment.center,
            decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, size: 24, color: color),
          ),
          const SizedBox(height: 3),
          Text(label, style: TextStyle(color: color, fontSize: 9)),
        ],
      ),
    );
  }
}
