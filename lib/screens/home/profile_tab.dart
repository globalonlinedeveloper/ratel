import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../app_state.dart';
import '../../config.dart';
import '../../content.dart';
import '../../guest.dart';
import '../../milestones.dart';
import '../../strings.dart';
import '../../theme.dart';
import '../../widgets/achievements_view.dart';
import '../../widgets/badge_gallery.dart';
import '../../widgets/daily_goal_card.dart';
import '../../widgets/ratel_mascot.dart';
import '../../widgets/rolling_number.dart';
import '../../widgets/save_account_sheet.dart';
import '../../widgets/share_card.dart';
import '../../widgets/streak_calendar.dart';
import '../../widgets/streak_flame.dart';
import '../../widgets/weak_areas_summary.dart';
import '../admin_screen.dart';
import '../friends_screen.dart';
import '../paywall_screen.dart';
import '../settings_screen.dart';
import '../report_queue_screen.dart';

/// Profile tab body (home tab-shell, index 4).
///
/// Extracted from the `home_screen` god-screen in the Standardization Master
/// Plan, Phase 1 (Inc 170). A tab body is NOT a pushed route, so it carries
/// no [RatelScaffold]/back header. StatefulWidget because the Profile settings
/// own local UI state (`_listenOn`) + setState-driven toggles. Migration
/// scope (lossless): spacing literals -> [RatelSpacing] (exact match), the
/// avatar-halo hex -> the `context.avatarBgC` theme getter, decorative mascot
/// wrapped in [ExcludeSemantics]. No state-trio: Profile reads the already
/// loaded global appState synchronously; data-heavy parts (achievements,
/// badges, weak areas) are their own widgets owning their own states.
class ProfileTab extends StatefulWidget {
  const ProfileTab({super.key});

  @override
  State<ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends State<ProfileTab> {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          const SizedBox(height: RatelSpacing.xl),
          Container(
            width: 110,
            height: 110,
            decoration: BoxDecoration(
                color: context.avatarBgC,
                shape: BoxShape.circle),
            alignment: Alignment.center,
            child: const ExcludeSemantics(
                child: RatelMascot(pose: RatelPose.idle, size: 90)),
          ),
          const SizedBox(height: RatelSpacing.md),
          Text(appState.displayName.isEmpty ? 'Learner' : appState.displayName,
              style: const TextStyle(fontSize: 20, fontFamily: kDisplayFont, fontWeight: FontWeight.w700)),
          if (isGuest)
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: FilledButton.tonalIcon(
                onPressed: () => showSaveAccountSheet(context),
                icon: const Icon(Icons.cloud_upload, size: 18),
                label: Text(S.instance
                    .t('guest_banner', 'Guest — save your progress')),
              ),
            )
          else
          Text(appState.email.isEmpty ? 'Learning English' : appState.email,
              style: const TextStyle(color: RatelColors.textMuted)),
          const SizedBox(height: 20),
          const DailyGoalCard(),
          Padding(
            padding: const EdgeInsets.fromLTRB(RatelSpacing.lg, 0, RatelSpacing.lg, RatelSpacing.sm),
            child: MergeSemantics(
              child: Semantics(
                button: true,
                label: appState.isPro
                    ? S.instance.t('pro_row_active', 'Ratel Pro is active ✨')
                    : S.instance.t(
                        'pro_row_title', 'Ratel Pro — unlimited hearts & more'),
                child: GestureDetector(
                  key: const Key('pro_row'),
                  onTap: () => Navigator.of(context).push(MaterialPageRoute(
                      builder: (_) => const PaywallScreen())),
                  child: Container(
                    padding: const EdgeInsets.all(RatelSpacing.lg),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                          colors: [RatelColors.honey, RatelColors.coral]),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.workspace_premium,
                            color: Colors.white),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                              appState.isPro
                                  ? S.instance.t(
                                      'pro_row_active', 'Ratel Pro is active ✨')
                                  : S.instance.t('pro_row_title',
                                      'Ratel Pro — unlimited hearts & more'),
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700)),
                        ),
                        const Icon(Icons.chevron_right, color: Colors.white),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: RatelSpacing.lg),
            child: GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              childAspectRatio: 2.4,
              children: [
                _statCardNum(Icons.local_fire_department, appState.streak,
                    S.instance.t('stat_streak', 'Day streak'),
                    RatelColors.coral, flame: true),
                _statCardNum(Icons.bolt, appState.xp,
                    S.instance.t('stat_xp', 'Total XP'),
                    RatelColors.honey),
                _statCardNum(Icons.favorite, appState.hearts,
                    S.instance.t('hearts_title', 'Hearts'),
                    RatelColors.hearts),
                _statCardNum(Icons.task_alt, appState.completedCount,
                    S.instance.t('stat_lessons', 'Lessons done'),
                    RatelColors.teal),
              ],
            ),
          ),
          const SizedBox(height: RatelSpacing.md),
          _englishScoreCard(),
          const StreakCalendar(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
            child: Wrap(
              alignment: WrapAlignment.center,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                const Icon(Icons.ac_unit, size: 15, color: RatelColors.teal),
                Text(
                    S.instance
                        .t('n_freezes', ' {n} freezes')
                        .replaceAll('{n}', '${appState.streakFreezes}'),
                    style: const TextStyle(
                        color: RatelColors.textMuted, fontSize: 13)),
                const SizedBox(width: 14),
                const Icon(Icons.emoji_events,
                    size: 15, color: RatelColors.honey),
                Text(
                    S.instance
                        .t('best_streak', ' best {n}-day streak')
                        .replaceAll('{n}', '${appState.longestStreak}'),
                    style: const TextStyle(
                        color: RatelColors.textMuted, fontSize: 13)),
              ],
            ),
          ),
          const SizedBox(height: RatelSpacing.sm),
          const WeakAreasSummary(),
          const AchievementsView(),
          const BadgeGallery(),
          const SizedBox(height: RatelSpacing.sm),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.settings_outlined,
                color: RatelColors.teal),
            title: Text(S.instance.t('set_title', 'Settings')),
            subtitle: Text(S.instance.t(
                'set_entry_sub', 'Sound, language, appearance, reminders')),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.of(context).push(MaterialPageRoute(
                builder: (_) => const SettingsScreen())),
          ),
          if (Config.hasSupabase) ...[
            const SizedBox(height: RatelSpacing.md),
            OutlinedButton.icon(
              onPressed: () => Navigator.of(context).push(MaterialPageRoute(
                  builder: (_) => const FriendsScreen())),
              icon: const Icon(Icons.group_outlined),
              label: Text(S.instance.t('fr_title', 'Friends')),
            ),
          ],
          if (Config.hasSupabase) ...[
            const SizedBox(height: RatelSpacing.sm),
            OutlinedButton.icon(
              onPressed: () => showShareCard(context),
              icon: const Icon(Icons.ios_share),
              label: Text(
                  S.instance.t('share_invite', 'Share / invite friends')),
            ),
          ],
          if (appState.isAdmin) ...[
            const SizedBox(height: RatelSpacing.md),
            OutlinedButton.icon(
              onPressed: () => Navigator.of(context).push(MaterialPageRoute(
                  builder: (_) => const AdminScreen())),
              icon: const Icon(Icons.admin_panel_settings),
              label: const Text('Content admin'),
            ),
            const SizedBox(height: RatelSpacing.sm),
            OutlinedButton.icon(
              onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(
                      builder: (_) => const ReportQueueScreen())),
              icon: const Icon(Icons.flag_outlined),
              label: const Text('Report queue'),
            ),
          ],
          const SizedBox(height: RatelSpacing.lg),
          Wrap(
            alignment: WrapAlignment.center,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              TextButton(
                onPressed: () => launchUrl(Uri.parse(
                    'https://globalonlinedeveloper.github.io/ratel/privacy.html')),
                child: Text(S.instance.t('set_privacy', 'Privacy policy'),
                    style: const TextStyle(
                        color: RatelColors.textMuted, fontSize: 12)),
              ),
              TextButton(
                onPressed: () => launchUrl(Uri.parse(
                    'https://globalonlinedeveloper.github.io/ratel/terms.html')),
                child: Text(S.instance.t('set_terms', 'Terms'),
                    style: const TextStyle(
                        color: RatelColors.textMuted, fontSize: 12)),
              ),
            ],
          ),
          if (Config.hasSupabase) ...[
            TextButton.icon(
              onPressed: () async {
                await Supabase.instance.client.auth.signOut();
                appState.reset();
              },
              icon: const Icon(Icons.logout, color: RatelColors.textMuted),
              label: Text(S.instance.t('btn_logout', 'Log out'),
                  style: TextStyle(color: RatelColors.textMuted)),
            ),
            TextButton.icon(
              onPressed: () => _confirmDeleteAccount(context, appState),
              icon: const Icon(Icons.delete_forever,
                  color: RatelColors.coral, size: 18),
              label: Text(S.instance.t('btn_delete', 'Delete account'),
                  style:
                      TextStyle(color: RatelColors.coral, fontSize: 12)),
            ),
          ],
          const SizedBox(height: RatelSpacing.xl),
        ],
      ),
    );
  }

  Future<void> _confirmDeleteAccount(
      BuildContext context, AppState appState) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(S.instance.t('del_title', 'Delete your account?')),
        content: Text(S.instance.t(
            'del_body',
            'This permanently deletes your account and ALL progress '
            '(XP, streak, friends, history). This cannot be undone.')),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: Text(S.instance.t('del_keep', 'Keep my account'))),
          FilledButton(
            style: FilledButton.styleFrom(
                backgroundColor: RatelColors.coral),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(S.instance.t('del_confirm', 'Delete forever')),
          ),
        ],
      ),
    );
    if (ok != true) return;
    try {
      await Supabase.instance.client.rpc('delete_self');
      await Supabase.instance.client.auth.signOut();
      appState.reset();
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(S.instance.t('delete_failed',
                "Couldn't delete right now — please try again."))));
      }
    }
  }

  Widget _statCardNum(IconData icon, int value, String label, Color color,
      {bool flame = false}) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: context.surfaceC,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: context.borderC),
      ),
      child: Row(
        children: [
          flame
              ? StreakFlame(streak: value, size: 26)
              : Icon(icon, color: color, size: 26),
          const SizedBox(width: 10),
          Expanded(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                RollingNumber(value,
                    style: const TextStyle(
                        fontSize: 19, fontWeight: FontWeight.w700)),
                Text(label,
                    style: const TextStyle(
                        color: RatelColors.textMuted, fontSize: 12)),
              ],
            ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _englishScoreCard() {
    final int totalLessons = [
      for (final u in course) u.lessons.length
    ].fold(0, (a, b) => a + b);
    final int score = appState.englishScoreNode(totalLessons);
    final String band = cefrFor(score);
    final int gap = toNextBand(score);
    return Container(
      margin: const EdgeInsets.fromLTRB(RatelSpacing.lg, 0, RatelSpacing.lg, RatelSpacing.sm),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: context.surfaceC,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: context.borderC),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.school_outlined,
                  size: 18, color: RatelColors.teal),
              const SizedBox(width: RatelSpacing.sm),
              Expanded(
                child: Text(S.instance.t('es_title', 'English Score'),
                    style: const TextStyle(
                        fontWeight: FontWeight.w700, fontSize: 14)),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 3),
                decoration: BoxDecoration(
                    color: context.tintC(RatelColors.teal),
                    borderRadius: BorderRadius.circular(10)),
                child: Text(band,
                    style: const TextStyle(
                        color: RatelColors.teal,
                        fontWeight: FontWeight.w800,
                        fontSize: 13)),
              ),
            ],
          ),
          const SizedBox(height: RatelSpacing.sm),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              RollingNumber(score,
                  style: const TextStyle(
                      fontSize: 30, fontWeight: FontWeight.w800)),
              const Text(' / 100',
                  style: TextStyle(
                      color: RatelColors.textMuted, fontSize: 13)),
              const SizedBox(width: RatelSpacing.sm),
              if (gap > 0)
                Expanded(
                  child: Text(
                    S.instance
                        .t('es_gap', '{n} to {band}')
                        .replaceAll('{n}', '$gap')
                        .replaceAll('{band}', cefrFor(score + gap)),
                    textAlign: TextAlign.right,
                    style: const TextStyle(
                        color: RatelColors.textMuted, fontSize: 12)),
                ),
            ],
          ),
          const SizedBox(height: RatelSpacing.sm),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: (score % 25) / 25,
              minHeight: 6,
              backgroundColor: context.tintC(RatelColors.teal),
              color: RatelColors.teal,
            ),
          ),
          const SizedBox(height: 6),
          Text(
              S.instance.t(
                  'cefr_${band.toLowerCase()}', canDoFor(band)),
              style: const TextStyle(
                  fontSize: 12.5, fontWeight: FontWeight.w600)),
          const SizedBox(height: 2),
          Text(
              S.instance.t('es_sub',
                  'Grows as you master skills, not just finish lessons.'),
              style: const TextStyle(
                  color: RatelColors.textMuted, fontSize: 11.5)),
        ],
      ),
    );
  }

}
