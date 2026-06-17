import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/tokens.dart';

/// DEV screen index — a tappable gallery of every built screen, grouped by page,
/// so the design-first build can be reviewed before the real flow is wired.
/// Temporary review aid (set as the app's initialLocation); replace with the
/// real entry once navigation is fully connected in a later phase.
class ScreenIndexScreen extends StatelessWidget {
  const ScreenIndexScreen({super.key});

  static const List<(String, List<(String, String)>)> _sections =
      <(String, List<(String, String)>)>[
    ('Page 1 · Auth & entry', <(String, String)>[
      ('1 · Splash', '/splash'),
      ('2 · Welcome', '/welcome'),
      ('3 · Auth hub', '/auth'),
      ('4 · Returning unlock', '/unlock'),
      ('5 · Email login', '/login'),
      ('6 · Sign-up', '/signup'),
      ('7 · Social consent', '/social-consent'),
      ('8 · Privacy choices', '/privacy'),
      ('9 · Age check', '/age'),
      ('10 · Parental consent', '/parental'),
      ('11 · Phone verify', '/phone'),
      ('12 · OTP', '/otp'),
      ('13 · Forgot password', '/forgot'),
      ('14 · Reset link sent', '/reset-sent'),
      ('15 · Set new password', '/set-password'),
      ('16 · Email verify', '/email-verify'),
      ('17 · Guest save', '/guest-save'),
      ('18 · Logout', '/logout'),
      ('19 · Delete account', '/delete'),
    ]),
    ('Page 2 · Onboarding', <(String, String)>[
      ('1 · Language picker', '/onboarding/language'),
      ('2 · Motivation', '/onboarding/motivation'),
      ('3 · Daily goal', '/onboarding/goal'),
      ('4 · Referral source', '/onboarding/referral'),
      ('5 · Notification opt-in', '/onboarding/notify'),
      ('6 · Start point', '/onboarding/start'),
      ('7 · Placement test', '/onboarding/placement'),
      ('8 · Level result', '/onboarding/level'),
      ('9 · First win', '/onboarding/first-win'),
    ]),
    ('Page 3 · Core learning', <(String, String)>[
      ('1 · Home', '/home'),
      ('2 · Lesson · choice', '/lesson/choice'),
      ('3 · Lesson · speaking', '/lesson/speaking'),
      ('4 · AI roleplay', '/roleplay'),
      ('5 · Lesson · listen', '/lesson/listen'),
      ('6 · Why card', '/why'),
      ('7 · Wrong feedback', '/wrong'),
      ('8 · Lesson complete', '/complete'),
      ('9 · Out of energy', '/energy'),
      ('10 · Stories', '/stories'),
      ('11 · Streak hub', '/streak'),
      ('12 · Course switcher', '/courses'),
    ]),
    ('Page 4 · Practice & AI speaking', <(String, String)>[
      ('1 · Practice hub', '/practice'),
      ('2 · Smart practice', '/practice/smart'),
      ('3 · Timed challenge', '/practice/timed'),
      ('4 · Coach chat', '/coach'),
      ('5 · Voice call', '/call'),
      ('6 · Speaking practice', '/practice/speaking'),
      ('7 · Pronunciation results', '/pronunciation'),
      ('8 · Stories (market)', '/practice/story'),
      ('9 · Adventures roleplay', '/adventures'),
      ('10 · Video lesson', '/video'),
      ('11 · Dictation', '/dictation'),
      ('12 · Writing feedback', '/writing'),
      ('13 · AI credits', '/credits'),
    ]),
    ('Page 5 · Gamification & social', <(String, String)>[
      ('1 · Streak', '/streak-detail'),
      ('2 · Streak Society', '/society'),
      ('3 · Daily quests', '/quests'),
      ('4 · Achievements', '/achievements'),
      ('5 · Achievement detail', '/achievement'),
      ('6 · Gem shop', '/shop'),
      ('7 · Out of energy', '/energy'),
      ('8 · Goal ring + chest', '/goal-ring'),
      ('9 · Leagues', '/leagues'),
      ('10 · Diamond tournament', '/tournament'),
      ('11 · Friends & feed', '/friends'),
      ('12 · Friend profile', '/friend'),
      ('13 · Family plan', '/family'),
      ('14 · Classroom', '/classroom'),
    ]),
    ('Page 6 · Profile, account & monetization', <(String, String)>[
      ('1 · Profile', '/profile'),
      ('2 · English Score', '/english-score'),
      ('3 · Avatar builder', '/avatar'),
      ('4 · Settings hub', '/settings'),
      ('5 · Appearance', '/appearance'),
      ('6 · Accessibility', '/accessibility'),
      ('7 · Privacy & data', '/privacy-data'),
      ('8 · Notifications', '/notifications'),
      ('9 · Help & legal', '/help'),
      ('10 · Paywall', '/paywall'),
      ('11 · Checkout success', '/checkout'),
      ('12 · Manage subscription', '/subscription'),
      ('13 · Cancel / win-back', '/cancel'),
      ('14 · Promo / redeem', '/promo'),
      ('15 · Referral hub', '/referral'),
    ]),
  ];

  @override
  Widget build(BuildContext context) {
    final tk = context.tokens;
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 440),
            child: ListView(
              padding: const EdgeInsets.all(RatelSpacing.md),
              children: <Widget>[
                Text(
                  'Ratel — all screens',
                  style: TextStyle(color: tk.text, fontSize: 18, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 2),
                Text(
                  'Design-first preview · tap any screen, then use back (←) to return here.',
                  style: TextStyle(color: tk.textMuted, fontSize: 11),
                ),
                const SizedBox(height: RatelSpacing.md),
                for (final (String title, List<(String, String)> rows) in _sections) ...<Widget>[
                  Padding(
                    padding: const EdgeInsets.only(top: RatelSpacing.md, bottom: RatelSpacing.xs),
                    child: Text(
                      title,
                      style: TextStyle(color: tk.primary, fontSize: 12, fontWeight: FontWeight.w700),
                    ),
                  ),
                  for (final (String label, String route) in rows)
                    InkWell(
                      onTap: () => context.push(route),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 11),
                        decoration: BoxDecoration(
                          border: Border(bottom: BorderSide(color: tk.border, width: tk.hairline)),
                        ),
                        child: Row(
                          children: <Widget>[
                            Expanded(child: Text(label, style: TextStyle(color: tk.text, fontSize: 13))),
                            Text(route, style: TextStyle(color: tk.textMuted, fontSize: 10)),
                            const SizedBox(width: 6),
                            Icon(Icons.chevron_right, size: 16, color: tk.textMuted),
                          ],
                        ),
                      ),
                    ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
