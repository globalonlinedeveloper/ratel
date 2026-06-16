import 'package:flutter/material.dart';
import '../../../core/i18n/strings.dart';
import '../../../core/theme/tokens.dart';
import '../../../design_system/components/ratel_bottom_nav.dart';

/// Home — mock Page-3 · screen 1 (packed learning hub: stats, lesson path,
/// tune-up, bottom nav). Design-only (no backend yet).
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final tk = context.tokens;
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 440),
            child: Column(
              children: <Widget>[
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(RatelSpacing.md),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        _statsHeader(tk),
                        const SizedBox(height: RatelSpacing.sm),
                        _pillsRow(tk),
                        const SizedBox(height: RatelSpacing.md),
                        Text(
                          S.t('home_unit', 'Unit 3 · Everyday phrases'),
                          style: TextStyle(
                            color: tk.text,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: RatelSpacing.sm),
                        _lessonPath(tk),
                        const SizedBox(height: RatelSpacing.md),
                        _tuneUpBanner(tk),
                        const SizedBox(height: RatelSpacing.sm),
                        _friendsSuperRow(tk),
                      ],
                    ),
                  ),
                ),
                RatelBottomNav(currentIndex: 0, onTap: (int i) {}),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _statsHeader(RatelTokens tk) {
    Widget stat(IconData icon, String value, Color color) => Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(icon, size: 15, color: color),
            const SizedBox(width: 2),
            Text(
              value,
              style: TextStyle(color: color, fontSize: 11.5, fontWeight: FontWeight.w600),
            ),
          ],
        );
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            stat(Icons.local_fire_department, S.t('home_streak', '7'), tk.coral),
            const SizedBox(width: 2),
            Icon(Icons.ac_unit, size: 12, color: tk.info),
          ],
        ),
        stat(Icons.diamond_outlined, S.t('home_gems', '320'), tk.info),
        stat(Icons.bolt, S.t('home_energy', '18/25'), tk.brand),
        stat(Icons.track_changes, S.t('home_goal', '12/20'), tk.primary),
      ],
    );
  }

  Widget _pillsRow(RatelTokens tk) {
    Widget pill(String label, Color bg, Color fg) => Expanded(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 3),
            padding: const EdgeInsets.symmetric(vertical: RatelSpacing.xs + 2),
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(tk.radiusSm),
            ),
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(color: fg, fontSize: 10),
            ),
          ),
        );
    return Row(
      children: <Widget>[
        pill(S.t('home_league', 'Gold league'), tk.warningBg, tk.warning),
        pill(S.t('home_quests', 'Quests 2/3'), tk.surface2, tk.text),
        pill(S.t('home_chest', 'Chest'), tk.surface2, tk.text),
      ],
    );
  }

  Widget _lessonPath(RatelTokens tk) {
    Widget node({
      required IconData icon,
      required Color bg,
      required Color fg,
      double size = 46,
      Color? border,
      EdgeInsets padding = EdgeInsets.zero,
    }) =>
        Padding(
          padding: padding,
          child: Container(
            width: size,
            height: size,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: bg,
              shape: BoxShape.circle,
              border: border == null ? null : Border.all(color: border, width: 2.5),
            ),
            child: Icon(icon, size: size * 0.48, color: fg),
          ),
        );
    return Column(
      children: <Widget>[
        node(icon: Icons.check, bg: tk.primary, fg: Colors.white),
        const SizedBox(height: RatelSpacing.sm),
        node(
          icon: Icons.star,
          bg: tk.warningBg,
          fg: tk.brand,
          size: 50,
          border: tk.win,
          padding: const EdgeInsets.only(left: 46),
        ),
        const SizedBox(height: RatelSpacing.sm),
        node(
          icon: Icons.lock_outline,
          bg: tk.page,
          fg: tk.textMuted,
          padding: const EdgeInsets.only(right: 46),
        ),
      ],
    );
  }

  Widget _tuneUpBanner(RatelTokens tk) => Container(
        padding: const EdgeInsets.symmetric(
          horizontal: RatelSpacing.sm + 2,
          vertical: RatelSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: tk.successBg,
          borderRadius: BorderRadius.circular(tk.radiusMd),
        ),
        child: Row(
          children: <Widget>[
            Icon(Icons.bolt, size: 15, color: tk.success),
            const SizedBox(width: RatelSpacing.sm),
            Expanded(
              child: Text(
                S.t('home_tuneup', '7 weak skills · 4-min tune-up'),
                style: TextStyle(color: tk.success, fontSize: 10.5),
              ),
            ),
          ],
        ),
      );

  Widget _friendsSuperRow(RatelTokens tk) {
    Widget pill(IconData icon, String label, Color border, Color fg) => Expanded(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 3),
            padding: const EdgeInsets.symmetric(vertical: RatelSpacing.xs + 2),
            decoration: BoxDecoration(
              border: Border.all(color: border, width: 0.5),
              borderRadius: BorderRadius.circular(tk.radiusSm),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Icon(icon, size: 13, color: fg),
                const SizedBox(width: 4),
                Text(label, style: TextStyle(color: fg, fontSize: 10)),
              ],
            ),
          ),
        );
    return Row(
      children: <Widget>[
        pill(Icons.group_outlined, S.t('home_friends', 'Friends'), tk.border, tk.text),
        pill(Icons.auto_awesome, S.t('home_super', 'Go Super ✦'), tk.win, tk.warning),
      ],
    );
  }
}
