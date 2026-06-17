import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/i18n/strings.dart';
import '../../../core/theme/tokens.dart';

/// Practice hub — mock Page-4 · screen 1 (smart session + practice modes grid).
/// Tiles route to their practice screens; the shell owns the nav.
class PracticeHubScreen extends StatelessWidget {
  const PracticeHubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final tk = context.tokens;
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 440),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(RatelSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: Text(
                          S.t('practice_title', 'Practice'),
                          style: TextStyle(
                            color: tk.text,
                            fontSize: 17,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: RatelSpacing.sm,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: tk.infoBg,
                          borderRadius: BorderRadius.circular(tk.radiusPill),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            Icon(Icons.auto_awesome, size: 13, color: tk.info),
                            const SizedBox(width: 3),
                            Text(
                              S.t('practice_ai', '3/5 AI'),
                              style: TextStyle(color: tk.info, fontSize: 11),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: RatelSpacing.sm),
                  GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => context.push('/practice/smart'),
                    child: Container(
                      padding: const EdgeInsets.all(RatelSpacing.md),
                      decoration: BoxDecoration(
                        color: tk.primary,
                        borderRadius: BorderRadius.circular(tk.radiusMd),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            S.t('practice_session_tag', 'TUNED TO YOU · 5 MIN'),
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 10,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            S.t(
                              'practice_session_title',
                              "Today's smart session",
                            ),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            S.t(
                              'practice_session_sub',
                              '12 weak items · refreshes daily',
                            ),
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: RatelSpacing.md),
                  Row(
                    children: <Widget>[
                      _Tile(
                        icon: Icons.gps_fixed,
                        label: S.t('practice_smart', 'Smart practice'),
                        color: tk.primary,
                        onTap: () => context.push('/practice/smart'),
                      ),
                      const SizedBox(width: RatelSpacing.sm),
                      _Tile(
                        icon: Icons.rotate_right,
                        label: S.t('practice_review', 'Due review · 12'),
                        color: tk.info,
                        onTap: () => context.push('/practice/smart'),
                      ),
                    ],
                  ),
                  const SizedBox(height: RatelSpacing.sm),
                  Row(
                    children: <Widget>[
                      _Tile(
                        icon: Icons.mic,
                        label: S.t('practice_speaking', 'Speaking'),
                        color: tk.hearts,
                        onTap: () => context.push('/practice/speaking'),
                      ),
                      const SizedBox(width: RatelSpacing.sm),
                      _Tile(
                        icon: Icons.forum_outlined,
                        label: S.t('practice_coach', 'Coach & call'),
                        color: tk.brand,
                        onTap: () => context.push('/coach'),
                      ),
                    ],
                  ),
                  const SizedBox(height: RatelSpacing.sm),
                  Row(
                    children: <Widget>[
                      _Tile(
                        icon: Icons.menu_book_outlined,
                        label: S.t('practice_stories', 'Stories'),
                        color: tk.brand,
                        onTap: () => context.push('/practice/story'),
                      ),
                      const SizedBox(width: RatelSpacing.sm),
                      _Tile(
                        icon: Icons.timer_outlined,
                        label: S.t('practice_timed', 'Timed · Mistakes'),
                        color: tk.coral,
                        onTap: () => context.push('/practice/timed'),
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

/// A square practice-mode tile (icon over label).
class _Tile extends StatelessWidget {
  const _Tile({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final tk = context.tokens;
    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(RatelSpacing.sm + 2),
          decoration: BoxDecoration(
            border: Border.all(color: tk.border, width: tk.hairline),
            borderRadius: BorderRadius.circular(tk.radiusLg - 2),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Icon(icon, size: 18, color: color),
              const SizedBox(height: 4),
              Text(label, style: TextStyle(color: tk.text, fontSize: 11.5)),
            ],
          ),
        ),
      ),
    );
  }
}
