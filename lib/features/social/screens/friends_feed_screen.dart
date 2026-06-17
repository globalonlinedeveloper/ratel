import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/i18n/strings.dart';
import '../../../core/theme/tokens.dart';

/// Friends & feed — mock Page-5 · screen 11 (kudos-only activity feed).
/// The friend row opens a friend profile; the shell owns the nav.
class FriendsFeedScreen extends StatelessWidget {
  const FriendsFeedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final tk = context.tokens;
    Widget addPill(IconData icon, String label) => Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 3),
        padding: const EdgeInsets.symmetric(vertical: 6),
        decoration: BoxDecoration(
          border: Border.all(color: tk.border, width: tk.hairline),
          borderRadius: BorderRadius.circular(tk.radiusSm),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(icon, size: 13, color: tk.textMuted),
            const SizedBox(width: 4),
            Text(label, style: TextStyle(color: tk.text, fontSize: 10)),
          ],
        ),
      ),
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
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: Text(
                          S.t('friends_title', 'Friends'),
                          style: TextStyle(
                            color: tk.text,
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      Icon(Icons.person_add_alt, size: 18, color: tk.primary),
                    ],
                  ),
                  const SizedBox(height: RatelSpacing.sm),
                  Row(
                    children: <Widget>[
                      addPill(Icons.qr_code, S.t('friends_qr', 'QR')),
                      addPill(Icons.link, S.t('friends_link', 'Link')),
                      addPill(
                        Icons.alternate_email,
                        S.t('friends_name', 'Name'),
                      ),
                    ],
                  ),
                  const SizedBox(height: RatelSpacing.md),
                  Text(
                    S.t('friends_activity', 'Activity'),
                    style: TextStyle(
                      color: tk.textMuted,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: RatelSpacing.sm),
                  _Activity(
                    initial: 'A',
                    avatarColor: tk.hearts,
                    text: S.t('friends_a1', 'Asha hit a 30-day streak'),
                    reactIcon: Icons.front_hand,
                    reactColor: tk.brand,
                  ),
                  const SizedBox(height: RatelSpacing.sm),
                  _Activity(
                    initial: 'R',
                    avatarColor: tk.info,
                    text: S.t('friends_a2', 'Ravi reached Gold league'),
                    reactIcon: Icons.sentiment_satisfied_alt,
                    reactColor: tk.success,
                  ),
                  const SizedBox(height: RatelSpacing.xs),
                  Text(
                    S.t(
                      'friends_note',
                      'kudos & high-fives only — never "you\'re losing" guilt',
                    ),
                    style: TextStyle(color: tk.textMuted, fontSize: 9),
                  ),
                  const SizedBox(height: RatelSpacing.sm),
                  GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => context.push('/friend'),
                    child: Row(
                      children: <Widget>[
                        Container(
                          width: 30,
                          height: 30,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: RatelSociety.purple,
                            shape: BoxShape.circle,
                          ),
                          child: const Text(
                            'A',
                            style: TextStyle(color: Colors.white, fontSize: 12),
                          ),
                        ),
                        const SizedBox(width: RatelSpacing.sm),
                        Expanded(
                          child: Text(
                            S.t('friends_f1', 'Asha'),
                            style: TextStyle(color: tk.text, fontSize: 11.5),
                          ),
                        ),
                        Icon(
                          Icons.local_fire_department,
                          size: 14,
                          color: tk.coral,
                        ),
                        const SizedBox(width: 2),
                        Text(
                          '12',
                          style: TextStyle(color: tk.coral, fontSize: 11),
                        ),
                      ],
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

class _Activity extends StatelessWidget {
  const _Activity({
    required this.initial,
    required this.avatarColor,
    required this.text,
    required this.reactIcon,
    required this.reactColor,
  });

  final String initial;
  final Color avatarColor;
  final String text;
  final IconData reactIcon;
  final Color reactColor;

  @override
  Widget build(BuildContext context) {
    final tk = context.tokens;
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: RatelSpacing.md,
        vertical: RatelSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: tk.surface2,
        borderRadius: BorderRadius.circular(tk.radiusMd),
      ),
      child: Row(
        children: <Widget>[
          Container(
            width: 30,
            height: 30,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: avatarColor,
              shape: BoxShape.circle,
            ),
            child: Text(
              initial,
              style: const TextStyle(color: Colors.white, fontSize: 12),
            ),
          ),
          const SizedBox(width: RatelSpacing.sm),
          Expanded(
            child: Text(text, style: TextStyle(color: tk.text, fontSize: 11.5)),
          ),
          Icon(reactIcon, size: 18, color: reactColor),
        ],
      ),
    );
  }
}
