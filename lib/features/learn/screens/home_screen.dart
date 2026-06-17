import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/i18n/strings.dart';
import '../../../core/theme/tokens.dart';

/// Home — mock Page-3 · screen 1 (packed learning hub: stats, lesson path,
/// tune-up). Tiles route to their detail screens; the shell owns the nav.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final tk = context.tokens;
    return Scaffold(
      body: SafeArea(
        child: Align(alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 440),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(RatelSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  _statsHeader(context, tk),
                  const SizedBox(height: RatelSpacing.sm),
                  _pillsRow(context, tk),
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
                  _lessonPath(context, tk),
                  const SizedBox(height: RatelSpacing.md),
                  GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => context.push('/practice/smart'),
                    child: _tuneUpBanner(tk),
                  ),
                  const SizedBox(height: RatelSpacing.sm),
                  _friendsSuperRow(context, tk),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _statsHeader(BuildContext context, RatelTokens tk) {
    Widget stat(IconData icon, String value, Color color, VoidCallback onTap) =>
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: onTap,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Icon(icon, size: 15, color: color),
              const SizedBox(width: 2),
              Text(
                value,
                style: TextStyle(
                  color: color,
                  fontSize: 11.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        );
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => context.push('/streak'),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Icon(Icons.local_fire_department, size: 15, color: tk.coral),
              const SizedBox(width: 2),
              Text(
                S.t('home_streak', '7'),
                style: TextStyle(
                  color: tk.coral,
                  fontSize: 11.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 2),
              Icon(Icons.ac_unit, size: 12, color: tk.info),
            ],
          ),
        ),
        stat(
          Icons.diamond_outlined,
          S.t('home_gems', '320'),
          tk.info,
          () => context.push('/shop'),
        ),
        stat(
          Icons.bolt,
          S.t('home_energy', '18/25'),
          tk.brand,
          () => context.push('/energy'),
        ),
        stat(
          Icons.track_changes,
          S.t('home_goal', '12/20'),
          tk.primary,
          () => context.push('/goal-ring'),
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Semantics(
              button: true,
              label: S.t('home_search_a11y', 'Search'),
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => context.push('/search'),
                child: Icon(Icons.search, size: 18, color: tk.textMuted),
              ),
            ),
            const SizedBox(width: RatelSpacing.md),
            Semantics(
              button: true,
              label: S.t('home_inbox_a11y', 'Notifications'),
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => context.push('/inbox'),
                child: Icon(
                  Icons.notifications_none,
                  size: 18,
                  color: tk.textMuted,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _pillsRow(BuildContext context, RatelTokens tk) {
    Widget pill(String label, Color bg, Color fg, VoidCallback onTap) =>
        Expanded(
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: onTap,
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 3),
              padding: const EdgeInsets.symmetric(
                vertical: RatelSpacing.xs + 2,
              ),
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
          ),
        );
    return Row(
      children: <Widget>[
        pill(
          S.t('home_league', 'Gold league'),
          tk.warningBg,
          tk.warning,
          () => context.push('/leagues'),
        ),
        pill(
          S.t('home_quests', 'Quests 2/3'),
          tk.surface2,
          tk.text,
          () => context.push('/quests'),
        ),
        pill(
          S.t('home_chest', 'Chest'),
          tk.surface2,
          tk.text,
          () => context.push('/goal-ring'),
        ),
      ],
    );
  }

  Widget _lessonPath(BuildContext context, RatelTokens tk) {
    Widget node({
      required IconData icon,
      required Color bg,
      required Color fg,
      double size = 46,
      Color? border,
      EdgeInsets padding = EdgeInsets.zero,
    }) => Padding(
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
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => context.push('/lesson/choice'),
          child: node(icon: Icons.check, bg: tk.primary, fg: Colors.white),
        ),
        const SizedBox(height: RatelSpacing.sm),
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => context.push('/lesson/choice'),
          child: node(
            icon: Icons.star,
            bg: tk.warningBg,
            fg: tk.brand,
            size: 50,
            border: tk.win,
            padding: const EdgeInsets.only(left: 46),
          ),
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

  Widget _friendsSuperRow(BuildContext context, RatelTokens tk) {
    Widget pill(
      IconData icon,
      String label,
      Color border,
      Color fg,
      VoidCallback onTap,
    ) => Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
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
      ),
    );
    return Row(
      children: <Widget>[
        pill(
          Icons.group_outlined,
          S.t('home_friends', 'Friends'),
          tk.border,
          tk.text,
          () => context.push('/friends'),
        ),
        pill(
          Icons.auto_awesome,
          S.t('home_super', 'Go Super ✦'),
          tk.win,
          tk.warning,
          () => context.push('/paywall'),
        ),
      ],
    );
  }
}
