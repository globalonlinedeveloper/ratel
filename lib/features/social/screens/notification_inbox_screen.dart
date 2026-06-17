import 'package:flutter/material.dart';
import '../../../core/i18n/strings.dart';
import '../../../core/theme/tokens.dart';
import '../../../design_system/components/ratel_empty_state.dart';
import '../../../design_system/components/ratel_link.dart';
import '../../../design_system/components/ratel_medallion.dart';

/// In-app notification inbox (`/inbox`) — streak saves, kudos, league results,
/// followers. Distinct from the `/notifications` push-settings screen. A const
/// `_empty` flag demonstrates the design-phase empty-state branch (audit
/// cross-cutting #5). Mock feed; real notifications + persistence land Phase 3.
class NotificationInboxScreen extends StatelessWidget {
  const NotificationInboxScreen({super.key});

  static const bool _empty = false;

  static const List<_Notif> _items = <_Notif>[
    _Notif(
      Icons.local_fire_department,
      _Cat.streak,
      'Streak saved!',
      'Your 7-day streak is safe — see you tomorrow.',
      '2h',
      true,
    ),
    _Notif(
      Icons.favorite,
      _Cat.kudos,
      'asha_learns cheered you',
      'Kudos on finishing Everyday phrases.',
      '5h',
      true,
    ),
    _Notif(
      Icons.emoji_events,
      _Cat.league,
      'Gold League result',
      'You finished 4th and promoted to Sapphire.',
      '1d',
      false,
    ),
    _Notif(
      Icons.group,
      _Cat.follow,
      'New follower',
      'deepak_r started following you.',
      '2d',
      false,
    ),
    _Notif(
      Icons.bolt,
      _Cat.energy,
      'Energy refilled',
      'Your energy is back to full — time to practice.',
      '3d',
      false,
    ),
  ];

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
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: Text(
                          S.t('inbox_title', 'Notifications'),
                          style: TextStyle(
                            color: tk.text,
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      if (!_empty)
                        RatelLink(
                          label: S.t('inbox_mark_all', 'Mark all read'),
                          onTap: () {},
                        ),
                    ],
                  ),
                  const SizedBox(height: RatelSpacing.sm),
                  if (_empty)
                    RatelEmptyState(
                      icon: Icons.notifications_none,
                      title: S.t('inbox_empty_title', "You're all caught up"),
                      message: S.t(
                        'inbox_empty_msg',
                        'New streak saves, kudos and league results show up here.',
                      ),
                    )
                  else
                    for (final _Notif n in _items) ...<Widget>[
                      _NotifItem(n: n),
                      const SizedBox(height: 4),
                    ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

enum _Cat { streak, kudos, league, follow, energy }

class _Notif {
  const _Notif(
    this.icon,
    this.cat,
    this.title,
    this.body,
    this.time,
    this.unread,
  );

  final IconData icon;
  final _Cat cat;
  final String title;
  final String body;
  final String time;
  final bool unread;
}

class _NotifItem extends StatelessWidget {
  const _NotifItem({required this.n});

  final _Notif n;

  Color _fg(RatelTokens tk) {
    switch (n.cat) {
      case _Cat.streak:
        return tk.coral;
      case _Cat.kudos:
        return tk.hearts;
      case _Cat.league:
        return tk.win;
      case _Cat.follow:
        return tk.info;
      case _Cat.energy:
        return tk.brand;
    }
  }

  @override
  Widget build(BuildContext context) {
    final tk = context.tokens;
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: RatelSpacing.sm,
        vertical: RatelSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: n.unread ? tk.surface2 : Colors.transparent,
        borderRadius: BorderRadius.circular(tk.radiusMd),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          RatelMedallion(
            icon: n.icon,
            background: n.unread ? tk.surface : tk.surface2,
            foreground: _fg(tk),
            size: 38,
            iconSize: 19,
          ),
          const SizedBox(width: RatelSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  n.title,
                  style: TextStyle(
                    color: tk.text,
                    fontSize: 12.5,
                    fontWeight: n.unread ? FontWeight.w700 : FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  n.body,
                  style: TextStyle(
                    color: tk.textMuted,
                    fontSize: 11,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: RatelSpacing.sm),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: <Widget>[
              Text(
                n.time,
                style: TextStyle(color: tk.textMuted, fontSize: 10),
              ),
              if (n.unread) ...<Widget>[
                const SizedBox(height: 4),
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: tk.primary,
                    shape: BoxShape.circle,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
