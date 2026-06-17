import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/i18n/strings.dart';
import '../../../core/theme/tokens.dart';
import '../../../design_system/components/ratel_button.dart';
import '../../../design_system/components/ratel_medallion.dart';

/// Profile — mock Page-6 · screen 1 (identity, stats, English Score, badges).
/// English Score / Edit / settings route out; the shell owns the nav.
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final tk = context.tokens;
    Widget stat(String value, String label, Color color) => Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 3),
        padding: const EdgeInsets.all(RatelSpacing.sm),
        decoration: BoxDecoration(
          color: tk.surface2,
          borderRadius: BorderRadius.circular(tk.radiusMd),
        ),
        child: Column(
          children: <Widget>[
            Text(
              value,
              style: TextStyle(
                color: color,
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(label, style: TextStyle(color: tk.textMuted, fontSize: 9)),
          ],
        ),
      ),
    );
    Widget badge(IconData icon, Color color, Color bg) => Container(
      width: 42,
      height: 42,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(icon, size: 22, color: color),
    );
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
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => context.push('/settings'),
          ),
        ],
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
                        RatelMedallion(
                          icon: Icons.sentiment_satisfied_alt,
                          background: tk.warningBg,
                          foreground: tk.brand,
                          size: 74,
                          iconSize: 42,
                        ),
                        const SizedBox(height: RatelSpacing.xs),
                        Text(
                          S.t('profile_name', 'raj_learns'),
                          style: TextStyle(
                            color: tk.text,
                            fontSize: 17,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          S.t('profile_joined', 'Joined 2025 · 🇮🇳'),
                          style: TextStyle(color: tk.textMuted, fontSize: 10),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: RatelSpacing.md),
                  Row(
                    children: <Widget>[
                      stat('7', S.t('profile_streak', 'streak'), tk.coral),
                      stat('2.4k', S.t('profile_xp', 'XP'), tk.brand),
                      stat('Gold', S.t('profile_league', 'league'), tk.info),
                    ],
                  ),
                  const SizedBox(height: RatelSpacing.md),
                  GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => context.push('/english-score'),
                    child: Container(
                      padding: const EdgeInsets.all(RatelSpacing.md),
                      decoration: BoxDecoration(
                        color: tk.successBg,
                        border: Border.all(color: tk.primary, width: 1.5),
                        borderRadius: BorderRadius.circular(tk.radiusLg),
                      ),
                      child: Row(
                        children: <Widget>[
                          Icon(Icons.radar, size: 26, color: tk.primary),
                          const SizedBox(width: RatelSpacing.md),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text(
                                  S.t('profile_score', 'English Score · 95'),
                                  style: TextStyle(
                                    color: tk.success,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Text(
                                  S.t(
                                    'profile_score_sub',
                                    'B1 · view breakdown',
                                  ),
                                  style: TextStyle(
                                    color: tk.success,
                                    fontSize: 10,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Icon(
                            Icons.chevron_right,
                            size: 18,
                            color: tk.success,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: RatelSpacing.md),
                  Text(
                    S.t('profile_badges', 'Recent badges'),
                    style: TextStyle(
                      color: tk.textMuted,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: RatelSpacing.sm),
                  Row(
                    children: <Widget>[
                      badge(
                        Icons.local_fire_department,
                        tk.brand,
                        tk.warningBg,
                      ),
                      const SizedBox(width: RatelSpacing.sm),
                      badge(Icons.bolt, tk.success, tk.successBg),
                      const SizedBox(width: RatelSpacing.sm),
                      badge(Icons.emoji_events, tk.info, tk.infoBg),
                    ],
                  ),
                  const SizedBox(height: RatelSpacing.md),
                  RatelButton.neutral(
                    icon: Icons.edit_outlined,
                    label: S.t('profile_edit', 'Edit profile'),
                    onPressed: () => context.push('/avatar'),
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
