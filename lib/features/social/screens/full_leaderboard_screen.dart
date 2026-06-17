import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/i18n/strings.dart';
import '../../../core/theme/tokens.dart';
import '../../../design_system/components/ratel_button.dart';

/// Full leaderboard — the real ~30-learner weekly cohort (distinct from the
/// 3-round Diamond Tournament). Rank rows open the friend profile. Design-only
/// (mock cohort data; real cohort membership + XP land in Phase 3).
class FullLeaderboardScreen extends StatelessWidget {
  const FullLeaderboardScreen({super.key});

  // Mock cohort of 30 (rank, avatar initial, pseudonymous handle, weekly XP).
  // `me` marks the signed-in learner. Phase 3 replaces this with live data.
  static const List<_Entry> _cohort = <_Entry>[
    _Entry(1, 'M', 'mira_x', 1240),
    _Entry(2, 'D', 'deepak_r', 1185),
    _Entry(3, 'Y', 'yuki88', 1130),
    _Entry(4, 'Y', 'You', 1080, me: true),
    _Entry(5, 'N', 'noah_p', 1035),
    _Entry(6, 'S', 'sara_k', 990),
    _Entry(7, 'L', 'lin_wei', 950),
    _Entry(8, 'O', 'omar_s', 905),
    _Entry(9, 'P', 'priya_n', 870),
    _Entry(10, 'T', 'tomas_v', 835),
    _Entry(11, 'A', 'ana_g', 800),
    _Entry(12, 'K', 'kenji_t', 770),
    _Entry(13, 'F', 'fatima_z', 740),
    _Entry(14, 'L', 'lucas_b', 710),
    _Entry(15, 'W', 'wei_l', 680),
    _Entry(16, 'N', 'nadia_h', 650),
    _Entry(17, 'D', 'diego_m', 620),
    _Entry(18, 'R', 'ruth_a', 590),
    _Entry(19, 'S', 'sven_o', 560),
    _Entry(20, 'M', 'mei_c', 530),
    _Entry(21, 'I', 'ivan_d', 505),
    _Entry(22, 'Z', 'zoe_q', 480),
    _Entry(23, 'R', 'raj_p', 455),
    _Entry(24, 'C', 'cara_l', 430),
    _Entry(25, 'P', 'paulo_f', 405),
    _Entry(26, 'H', 'hana_k', 380),
    _Entry(27, 'L', 'leo_m', 355),
    _Entry(28, 'T', 'tariq_b', 330),
    _Entry(29, 'E', 'ella_w', 305),
    _Entry(30, 'B', 'bo_jin', 280),
  ];

  @override
  Widget build(BuildContext context) {
    final tk = context.tokens;
    final List<Color> palette = <Color>[
      tk.primary,
      tk.hearts,
      tk.coral,
      tk.info,
      tk.win,
      tk.success,
    ];

    final List<Widget> rows = <Widget>[];
    for (int i = 0; i < _cohort.length; i++) {
      final _Entry e = _cohort[i];
      if (e.rank == 26) {
        rows.add(const SizedBox(height: RatelSpacing.sm));
        rows.add(
          _ZoneBanner(
            label: S.t('lb_demote', '↓ bottom 5 demote'),
            fg: tk.danger,
            bg: tk.dangerBg,
          ),
        );
        rows.add(const SizedBox(height: RatelSpacing.sm));
      }
      rows.add(
        _Rank(
          rank: '${e.rank}',
          initial: e.initial,
          avatarColor: e.me ? tk.primary : palette[i % palette.length],
          name: e.me ? S.t('lb_you', 'You') : e.name,
          xp: '${e.xp}',
          me: e.me,
          onTap: e.me ? null : () => context.push('/friend'),
        ),
      );
      rows.add(const SizedBox(height: 4));
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Navigator.of(context).canPop()
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                tooltip: S.t('a11y_back', 'Back'),
                onPressed: () => Navigator.of(context).maybePop(),
              )
            : null,
      ),
      body: SafeArea(
        child: Align(
          alignment: Alignment.topCenter,
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
                  Text(
                    S.t('lb_title', 'Full leaderboard'),
                    style: TextStyle(
                      color: tk.text,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    S.t('lb_sub', 'Your cohort this week · 30 learners'),
                    style: TextStyle(color: tk.textMuted, fontSize: 10.5),
                  ),
                  const SizedBox(height: RatelSpacing.sm),
                  _ZoneBanner(
                    label: S.t('lb_promote', '↑ top 7 promote'),
                    fg: tk.success,
                    bg: tk.successBg,
                  ),
                  const SizedBox(height: RatelSpacing.sm),
                  ...rows,
                  const SizedBox(height: RatelSpacing.sm),
                  RatelButton.outline(
                    label: S.t('lb_tourn_link', 'Diamond Tournament'),
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

class _Entry {
  const _Entry(this.rank, this.initial, this.name, this.xp, {this.me = false});

  final int rank;
  final String initial;
  final String name;
  final int xp;
  final bool me;
}

class _ZoneBanner extends StatelessWidget {
  const _ZoneBanner({required this.label, required this.fg, required this.bg});

  final String label;
  final Color fg;
  final Color bg;

  @override
  Widget build(BuildContext context) {
    final tk = context.tokens;
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: RatelSpacing.md,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(tk.radiusSm),
      ),
      child: Text(label, style: TextStyle(color: fg, fontSize: 9.5)),
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
    this.onTap,
  });

  final String rank;
  final String initial;
  final Color avatarColor;
  final String name;
  final String xp;
  final bool me;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final tk = context.tokens;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(tk.radiusSm),
      child: Container(
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
            SizedBox(
              width: 20,
              child: Text(
                rank,
                style: TextStyle(
                  color: me ? tk.success : tk.textMuted,
                  fontSize: 12,
                  fontWeight: me ? FontWeight.w600 : FontWeight.w400,
                ),
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
      ),
    );
  }
}
