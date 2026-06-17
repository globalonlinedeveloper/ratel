import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/i18n/strings.dart';
import '../../../core/theme/tokens.dart';
import '../../../design_system/components/ratel_button.dart';

/// Leagues — mock Page-5 · screen 9 (winnable Gold-league cohort). Design-only.
class LeaguesScreen extends StatelessWidget {
  const LeaguesScreen({super.key});

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
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: Text(
                          S.t('league_title', 'Gold League'),
                          style: TextStyle(
                            color: tk.text,
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      Text(
                        S.t('league_left', '5 days left'),
                        style: TextStyle(color: tk.textMuted, fontSize: 10),
                      ),
                    ],
                  ),
                  const SizedBox(height: RatelSpacing.sm),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Icon(
                        Icons.shield_outlined,
                        size: 18,
                        color: tk.textMuted,
                      ),
                      Icon(Icons.shield_outlined, size: 18, color: tk.win),
                      Icon(Icons.shield, size: 22, color: tk.win),
                      Icon(Icons.shield_outlined, size: 18, color: tk.success),
                      Icon(Icons.shield_outlined, size: 18, color: tk.info),
                    ],
                  ),
                  const SizedBox(height: RatelSpacing.xs),
                  Center(
                    child: Text(
                      S.t(
                        'league_sub',
                        '10 tiers · Bronze → Diamond · winnable cohorts of 30',
                      ),
                      style: TextStyle(color: tk.textMuted, fontSize: 9),
                    ),
                  ),
                  const SizedBox(height: RatelSpacing.sm),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: RatelSpacing.md,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: tk.successBg,
                      borderRadius: BorderRadius.circular(tk.radiusSm),
                    ),
                    child: Text(
                      S.t('league_promote', '↑ top 7 promote'),
                      style: TextStyle(color: tk.success, fontSize: 9.5),
                    ),
                  ),
                  const SizedBox(height: RatelSpacing.sm),
                  _Rank(
                    rank: '4',
                    initial: 'Y',
                    avatarColor: tk.primary,
                    name: S.t('league_you', 'You'),
                    xp: '820 XP',
                    me: true,
                  ),
                  const SizedBox(height: 4),
                  _Rank(
                    rank: '5',
                    initial: 'A',
                    avatarColor: tk.hearts,
                    name: S.t('league_asha', 'Asha'),
                    xp: '780',
                    me: false,
                  ),
                  const SizedBox(height: RatelSpacing.sm),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: RatelSpacing.md,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: tk.dangerBg,
                      borderRadius: BorderRadius.circular(tk.radiusSm),
                    ),
                    child: Text(
                      S.t('league_demote', '↓ bottom 5 demote'),
                      style: TextStyle(color: tk.danger, fontSize: 9.5),
                    ),
                  ),
                  const SizedBox(height: RatelSpacing.md),
                  RatelButton.filled(
                    label: S.t('league_cta', 'Full leaderboard'),
                    onPressed: () => context.push('/tournament'),
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

class _Rank extends StatelessWidget {
  const _Rank({
    required this.rank,
    required this.initial,
    required this.avatarColor,
    required this.name,
    required this.xp,
    required this.me,
  });

  final String rank;
  final String initial;
  final Color avatarColor;
  final String name;
  final String xp;
  final bool me;

  @override
  Widget build(BuildContext context) {
    final tk = context.tokens;
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: RatelSpacing.sm + 1,
        vertical: 7,
      ),
      decoration: BoxDecoration(
        color: me ? tk.successBg : Colors.transparent,
        border: me ? Border.all(color: tk.primary, width: 1.5) : null,
        borderRadius: BorderRadius.circular(tk.radiusSm),
      ),
      child: Row(
        children: <Widget>[
          Text(
            rank,
            style: TextStyle(
              color: me ? tk.success : tk.textMuted,
              fontSize: 12,
              fontWeight: me ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
          const SizedBox(width: RatelSpacing.sm),
          Container(
            width: 24,
            height: 24,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: avatarColor,
              shape: BoxShape.circle,
            ),
            child: Text(
              initial,
              style: const TextStyle(color: Colors.white, fontSize: 11),
            ),
          ),
          const SizedBox(width: RatelSpacing.sm),
          Expanded(
            child: Text(
              name,
              style: TextStyle(
                color: me ? tk.success : tk.text,
                fontSize: 11.5,
              ),
            ),
          ),
          Text(
            xp,
            style: TextStyle(
              color: me ? tk.success : tk.textMuted,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}
