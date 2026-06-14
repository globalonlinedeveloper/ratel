import 'package:flutter/foundation.dart' show kIsWeb;
import '../push.dart';
import '../locales.dart';
import '../guest.dart';
import '../widgets/save_account_sheet.dart';
import '../widgets/streak_calendar.dart';
import '../widgets/share_card.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../widgets/motd_card.dart';
import '../widgets/campaign_cards.dart';
import '../widgets/hearts_sheet.dart';
import '../widgets/daily_chest.dart';
import '../widgets/perfect_week.dart';
import '../widgets/monthly_quest.dart';
import '../widgets/badge_gallery.dart';
import '../widgets/anniversary_card.dart';
import '../widgets/ratel_mascot.dart';
import '../widgets/mascot_anim.dart';
import '../theme.dart';
import '../flags.dart';
import '../strings.dart';
import '../comeback.dart';
import '../milestones.dart';
import '../guidebook.dart';
import 'section_test_screen.dart';
import 'report_queue_screen.dart';
import '../models.dart';
import '../content.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../app_state.dart';
import '../config.dart';
import '../sfx.dart';
import 'lesson_screen.dart';
import 'admin_screen.dart';
import 'onboarding_screen.dart';
import 'friends_screen.dart';
import 'coach_screen.dart';
import 'home/practice_tab.dart';
import 'paywall_screen.dart';
import '../widgets/transitions.dart';
import '../widgets/rolling_number.dart';
import '../widgets/streak_flame.dart';
import '../widgets/weak_areas_summary.dart';
import '../widgets/leagues_board.dart';
import '../widgets/daily_nudge.dart';
import '../widgets/streak_repair_card.dart';
import '../widgets/review_card.dart';
import '../widgets/daily_quests_card.dart';
import '../widgets/achievements_view.dart';
import '../widgets/daily_goal_card.dart';
import '../widgets/pulse.dart';

enum NodeState { done, current, locked }

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _tab = 0;

  /// Inc 138: the pinned bar follows the unit scrolled into view (QA #2 P4 —
  /// it used to read "Unit 1" at every scroll depth). Null = current unit.
  int? _viewedUnit;
  final Map<int, GlobalKey> _unitBannerKeys = {};

  GlobalKey _unitKeyFor(int u) =>
      _unitBannerKeys.putIfAbsent(u, GlobalKey.new);

  /// Pick the unit whose banner was last scrolled past the viewport top.
  bool _onPathScroll(ScrollNotification n) {
    if (n.metrics.axis != Axis.vertical) return false;
    final RenderObject? vp = n.context?.findRenderObject();
    if (vp is! RenderBox || !vp.hasSize) return false;
    final double top = vp.localToGlobal(Offset.zero).dy + 8;
    int best = 0;
    double bestDy = double.negativeInfinity;
    for (final e in _unitBannerKeys.entries) {
      final BuildContext? c = e.value.currentContext;
      if (c == null) continue;
      final RenderObject? ro = c.findRenderObject();
      if (ro is! RenderBox || !ro.hasSize || !ro.attached) continue;
      final double dy = ro.localToGlobal(Offset.zero).dy;
      if (dy <= top && dy > bestDy) {
        bestDy = dy;
        best = e.key;
      }
    }
    if (bestDy == double.negativeInfinity) best = 0;
    if (_viewedUnit != best) setState(() => _viewedUnit = best);
    return false;
  }

  bool _listenOn = true;
  Set<String> _chests = {};

  @override
  void initState() {
    super.initState();
    SharedPreferences.getInstance().then((p) async {
      if (!mounted) return;
      setState(() {
        _listenOn = p.getBool('listen_on') ?? true;
        _chests = (p.getStringList('chests') ?? const []).toSet();
      });
      // weekly freeze drip: one free freeze per ISO week, cap 2
      final String wk = weekKey(DateTime.now());
      if (p.getString('freeze_grant_week') != wk) {
        if (await appState.grantWeeklyFreeze()) {
          await p.setString('freeze_grant_week', wk);
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text(S.instance.t('freeze_drip',
                    'A free streak freeze arrived — stay fearless!'))));
          }
        } else {
          await p.setString('freeze_grant_week', wk);
        }
      }
      await _comebackCheck(p);
    });
    if (!appState.loaded) {
      appState.sync();
    }
    appState.redeemPendingFriendCode().then((code) {
      if (code != null && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(S.instance
                .t('friend_added',
                    'Friend added from your invite link ({code})!')
                .replaceAll('{code}', code))));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: appState,
      builder: (context, _) {
        if (Config.hasSupabase && appState.loaded && !appState.onboarded) {
          return const OnboardingScreen();
        }
        return KeyedSubtree(
          // Inc 137b: a locale flip must re-inflate EVERYTHING — identical
          // const child instances are skipped on rebuild (the Inc 135 freeze
          // class), which left const S()-consumers in the OLD language until
          // a full reload (live-verified on c6e09dc).
          key: ValueKey('locale-${S.instance.locale}'),
          child: Scaffold(
          body: SafeArea(child: _body(context)),
          bottomNavigationBar: NavigationBar(
            selectedIndex: _tab,
            onDestinationSelected: (i) => setState(() {
              if (i != 0) _viewedUnit = null;
              _tab = i;
            }),
            destinations: [
              NavigationDestination(
                  icon: const Icon(Icons.home_outlined),
                  selectedIcon: const Icon(Icons.home),
                  label: S.instance.t('nav_learn', 'Learn')),
              NavigationDestination(
                  icon: const Icon(Icons.edit_outlined),
                  label: S.instance.t('nav_practice', 'Practice')),
              NavigationDestination(
                  icon: const Icon(Icons.forum_outlined),
                  selectedIcon: const Icon(Icons.forum),
                  label: S.instance.t('nav_coach', 'Coach')),
              NavigationDestination(
                  icon: const Icon(Icons.emoji_events_outlined),
                  label: S.instance.t('nav_leagues', 'Leagues')),
              NavigationDestination(
                  icon: const Icon(Icons.person_outline),
                  label: S.instance.t('nav_profile', 'Profile')),
            ],
          ),
          ),
        );
      },
    );
  }

  /// Inc 134: record lapse-risk evenings; grant the comeback boost the
  /// next morning (multiplier + window from app_flags, once per day).
  Future<void> _comebackCheck(SharedPreferences p) async {
    if (!Flags.instance.flag('comeback_on', true)) return;
    final DateTime now = DateTime.now();
    if (appState.loaded && isEveningLapseRisk(now, appState.todayXp)) {
      await p.setString('lapse_risk_day', dayKey(now));
      return;
    }
    if (shouldGrantComeback(
        now: now,
        riskDay: p.getString('lapse_risk_day'),
        lastGrantDay: p.getString('comeback_day'))) {
      final int mult = Flags.instance.intOf('comeback_multiplier', 3);
      final int mins = Flags.instance.intOf('comeback_window_min', 30);
      await p.setString('xp_boost_until',
          now.add(Duration(minutes: mins)).toIso8601String());
      await p.setInt('xp_boost_mult', mult);
      await p.setString('comeback_day', dayKey(now));
      await p.remove('lapse_risk_day');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(S.instance
                .t('comeback_granted',
                    'Welcome back! {m}x XP for the next {n} minutes!')
                .replaceAll('{m}', '$mult')
                .replaceAll('{n}', '$mins'))));
      }
    }
  }

  Widget _placeholder() => Center(
        child: Text(S.instance.t('coming_soon', 'Coming soon'),
            style: const TextStyle(color: RatelColors.textMuted)),
      );

  Widget _body(BuildContext context) {
    switch (_tab) {
      case 0:
        return _buildLearn(context);
      case 1:
        return const PracticeTab();
      case 2:
        return const CoachScreen();
      case 3:
        return _buildLeagues();
      case 4:
        return _buildProfile();
      default:
        return _placeholder();
    }
  }

  Widget _buildLeagues() {
    return const LeaguesBoard();
  }

  Widget _buildProfile() {
    return SingleChildScrollView(
      child: Column(
        children: [
          const SizedBox(height: 24),
          Container(
            width: 110,
            height: 110,
            decoration: BoxDecoration(
                color: context.isDark
                    ? const Color(0xFF35302A)
                    : const Color(0xFFFAEEDA),
                shape: BoxShape.circle),
            alignment: Alignment.center,
            child: const RatelMascot(pose: RatelPose.idle, size: 90),
          ),
          const SizedBox(height: 12),
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
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
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
                    padding: const EdgeInsets.all(16),
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
            padding: const EdgeInsets.symmetric(horizontal: 16),
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
          const SizedBox(height: 12),
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
          const SizedBox(height: 8),
          const WeakAreasSummary(),
          const AchievementsView(),
          const BadgeGallery(),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(S.instance.t('set_sound', 'Sound effects')),
                  secondary:
                      const Icon(Icons.volume_up, color: RatelColors.honey),
                  value: Sfx.instance.soundOn,
                  onChanged: (v) {
                    Sfx.instance.setSoundOn(v);
                    setState(() {});
                  },
                ),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(S.instance.t('set_haptics', 'Haptics')),
                  secondary:
                      const Icon(Icons.vibration, color: RatelColors.teal),
                  value: Sfx.instance.hapticsOn,
                  onChanged: (v) {
                    Sfx.instance.setHapticsOn(v);
                    setState(() {});
                  },
                ),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(S.instance.t('set_music', 'Background music')),
                  subtitle: Text(S.instance
                      .t('set_music_sub', 'Calm ambient loop while you learn')),
                  secondary: Sfx.instance.musicOn
                      ? const RatelActionAnim(
                          action: 'headphones',
                          fallbackPose: RatelPose.speak,
                          size: 34)
                      : const Icon(Icons.music_note,
                          color: RatelColors.honey),
                  value: Sfx.instance.musicOn,
                  onChanged: (v) {
                    Sfx.instance.setMusicOn(v);
                    setState(() {});
                  },
                ),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.translate,
                      color: RatelColors.teal),
                  title: Text(S.instance.t('set_language', 'App language')),
                  subtitle: Text(S.instance
                      .t('set_lang_sub', 'Server copy follows your choice')),
                  trailing: SegmentedButton<String>(
                    showSelectedIcon: false,
                    style: const ButtonStyle(
                        visualDensity: VisualDensity.compact),
                    segments: [
                      for (final e in Locales.instance.enabled)
                        ButtonSegment(value: e.code, label: Text(e.nativeName)),
                    ],
                    selected: {S.instance.locale},
                    onSelectionChanged: (sel) async {
                      await S.instance.setLocale(sel.first);
                      if (mounted) setState(() {});
                    },
                  ),
                ),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(S.instance.t('set_listening', 'Listening exercises')),
                  subtitle: Text(S.instance
                      .t('set_listen_sub', 'Type-what-you-hear questions')),
                  secondary: const Icon(Icons.hearing_outlined),
                  value: _listenOn,
                  onChanged: (v) async {
                    setState(() => _listenOn = v);
                    try {
                      final p = await SharedPreferences.getInstance();
                      await p.setBool('listen_on', v);
                    } catch (_) {}
                  },
                ),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(S.instance.t('set_motion', 'Reduce motion')),
                  subtitle: Text(
                      S.instance.t('set_motion_sub', 'Minimize animations')),
                  secondary:
                      const Icon(Icons.motion_photos_off_outlined),
                  value: reduceMotionNotifier.value,
                  onChanged: (v) {
                    setReduceMotion(v);
                    setState(() {});
                  },
                ),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(S.instance.t('set_battle', 'Battle mode')),
                  subtitle: Text(S.instance
                      .t('set_battle_sub', 'Duel a rival as you answer')),
                  secondary:
                      const Icon(Icons.sports_kabaddi_outlined),
                  value: battleModeNotifier.value,
                  onChanged: (v) {
                    setBattleMode(v);
                    setState(() {});
                  },
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: SegmentedButton<ThemeMode>(
                    segments: [
                      ButtonSegment(
                          value: ThemeMode.system,
                          icon: const Icon(Icons.brightness_auto_outlined),
                          label: FittedBox(
                              fit: BoxFit.scaleDown,
                              child:
                                  Text(S.instance.t('set_auto', 'Auto')))),
                      ButtonSegment(
                          value: ThemeMode.light,
                          icon: const Icon(Icons.light_mode_outlined),
                          label: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                  S.instance.t('set_light', 'Light')))),
                      ButtonSegment(
                          value: ThemeMode.dark,
                          icon: const Icon(Icons.dark_mode_outlined),
                          label: FittedBox(
                              fit: BoxFit.scaleDown,
                              child:
                                  Text(S.instance.t('set_dark', 'Dark')))),
                    ],
                    selected: {themeModeNotifier.value},
                    onSelectionChanged: (s) {
                      setThemeMode(s.first);
                      setState(() {});
                    },
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 4),
          ListTile(
            dense: true,
            leading: const Icon(Icons.schedule,
                color: RatelColors.teal),
            title: Text(S.instance.t('set_remind', 'Remind me at')),
            subtitle: Text(S.instance.t(
                'set_remind_sub', 'Daily streak reminder, your local time')),
            trailing: DropdownButton<int>(
              value: localHourFromUtc(appState.reminderHourUtc,
                  DateTime.now().timeZoneOffset),
              underline: const SizedBox.shrink(),
              items: [
                for (int h = 0; h < 24; h++)
                  DropdownMenuItem(
                      value: h,
                      child: Text('${h.toString().padLeft(2, '0')}:30')),
              ],
              onChanged: (h) {
                if (h == null) return;
                appState.setReminderHour(utcHourFromLocal(
                    h, DateTime.now().timeZoneOffset));
                setState(() {});
              },
            ),
          ),
          if (!kIsWeb) ...[
            const SizedBox(height: 4),
            FutureBuilder<String>(
              future: Push.instance.statusLabel(),
              builder: (context, snap) {
                final st = snap.data ?? '…';
                return ListTile(
                  dense: true,
                  leading: const Icon(Icons.notifications_active_outlined,
                      color: RatelColors.honey),
                  title: Text(
                      S.instance.t('set_push', 'Daily streak reminders')),
                  subtitle: Text(st == 'Off'
                      ? S.instance.t('push_off_hint',
                          'Off — enable in system settings if asked before')
                      : st),
                  trailing: st == 'On'
                      ? const Icon(Icons.check_circle,
                          color: RatelColors.teal, size: 20)
                      : TextButton(
                          onPressed: () async {
                            await Push.instance.requestAgain();
                            if (context.mounted) {
                              (context as Element).markNeedsBuild();
                            }
                          },
                          child: Text(S.instance.t('btn_enable', 'Enable'))),
                );
              },
            ),
          ],
          if (Config.hasSupabase) ...[
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: () => Navigator.of(context).push(MaterialPageRoute(
                  builder: (_) => const FriendsScreen())),
              icon: const Icon(Icons.group_outlined),
              label: Text(S.instance.t('fr_title', 'Friends')),
            ),
          ],
          if (Config.hasSupabase) ...[
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: () => showShareCard(context),
              icon: const Icon(Icons.ios_share),
              label: Text(
                  S.instance.t('share_invite', 'Share / invite friends')),
            ),
          ],
          if (appState.isAdmin) ...[
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: () => Navigator.of(context).push(MaterialPageRoute(
                  builder: (_) => const AdminScreen())),
              icon: const Icon(Icons.admin_panel_settings),
              label: const Text('Content admin'),
            ),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(
                      builder: (_) => const ReportQueueScreen())),
              icon: const Icon(Icons.flag_outlined),
              label: const Text('Report queue'),
            ),
          ],
          const SizedBox(height: 16),
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
          const SizedBox(height: 24),
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

  final GlobalKey _currentNodeKey = GlobalKey();
  String? _autoScrolled;

  static const List<String> _checkpointArt = [
    'map', 'reading', 'trophyhold', 'determined', 'curious'
  ];

  Widget _checkpoint(int index) {
    final String name = _checkpointArt[index % _checkpointArt.length];
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
              child: Divider(
                  color: context.faintBorderC, indent: 28, endIndent: 14)),
          Image.asset('assets/images/ratel-$name.webp',
              width: 60,
              height: 60,
              errorBuilder: (_, _, _) =>
                  const SizedBox(width: 60, height: 60)),
          Expanded(
              child: Divider(
                  color: context.faintBorderC, indent: 14, endIndent: 28)),
        ],
      ),
    );
  }

  Widget _buildLearn(BuildContext context) {
    // Flatten every unit to find the single "current" lesson across the course.
    final List<Lesson> all = [for (final u in course) ...u.lessons];
    final int globalCurrent =
        all.indexWhere((l) => !appState.isCompleted(l.id));
    final String? currentId =
        globalCurrent == -1 ? null : all[globalCurrent].id;
    int curUnit = 0;
    for (int u = 0; u < course.length; u++) {
      if (course[u].lessons.any((l) => l.id == currentId)) {
        curUnit = u;
        break;
      }
    }
    const List<double> offsets = [-50.0, 10.0, 50.0, 0.0, -40.0];

    final List<Widget> path = [];
    for (int u = 0; u < course.length; u++) {
      final unit = course[u];
      if (u > 0) path.add(_checkpoint(u));
      if (startsSection(u)) path.add(_sectionBanner(u));
      path.add(_unitBanner(u, unit));
      path.add(const SizedBox(height: 14));
      for (int i = 0; i < unit.lessons.length; i++) {
        final Lesson l = unit.lessons[i];
        final NodeState st = appState.isCompleted(l.id)
            ? NodeState.done
            : (l.id == currentId ? NodeState.current : NodeState.locked);
        path.add(st == NodeState.current
            ? KeyedSubtree(key: _currentNodeKey, child: _currentNode(context, l))
            : GestureDetector(
                onTap: () => _nodePopup(l, st, u),
                child: _node(
                    state: st,
                    dx: offsets[i % offsets.length],
                    title: l.title,
                    accent: unitAccent(u))));
        path.add(const SizedBox(height: 14));
        if (i == 2) {
          path.add(_chestNode(u, unit));
          path.add(const SizedBox(height: 14));
        }
      }
    }
    // bring the learner straight to where they left off
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (currentId != null &&
          _autoScrolled != currentId &&
          _currentNodeKey.currentContext != null) {
        _autoScrolled = currentId;
        Scrollable.ensureVisible(_currentNodeKey.currentContext!,
            alignment: 0.35,
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeOutCubic);
      }
    });
    path.add(_node(
        state: currentId == null ? NodeState.done : NodeState.locked,
        dx: -40,
        trophy: true));

    return Column(
      children: [
        _header(),
        const MotdCard(),
        CampaignCards(onCoach: () => setState(() => _tab = 2)),
        const StreakRepairCard(),
        const DailyNudge(),
        const ReviewCard(),
        const DailyQuestsCard(),
        const DailyChestCard(),
        const PerfectWeekCard(),
        const MonthlyQuestCard(),
        const AnniversaryCard(),
        if (currentId != null)
          _pinnedUnitBar(
              (_viewedUnit ?? curUnit).clamp(0, course.length - 1)),
        Expanded(
          child: NotificationListener<ScrollNotification>(
            onNotification: _onPathScroll,
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(top: 12, bottom: 16),
              child: Column(children: path),
            ),
          ),
        ),
      ],
    );
  }

  /// Done nodes invite a single-lesson review; locked nodes explain.
  void _nodePopup(Lesson lesson, NodeState state, int u) {
    final bool done = state == NodeState.done;
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(lesson.title),
        content: Text(done
            ? S.instance.t('node_done_body',
                'You aced this one. A quick practice keeps it fresh!')
            : S.instance
                .t('node_locked_body', 'Complete the path above to unlock!')),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: Text(S.instance.t('btn_close', 'Close'))),
          if (done)
            FilledButton(
              style: FilledButton.styleFrom(backgroundColor: unitAccent(u)),
              onPressed: () {
                Navigator.of(ctx).pop();
                if (appState.hearts <= 0 && !appState.isPro) {
                  showHeartsSheet(context,
                      onPractice: () => setState(() => _tab = 1));
                  return;
                }
                Navigator.of(context).push(ratelRoute(
                    LessonScreen(lesson: lesson, reviewMode: true)));
              },
              child: Text(S.instance.t('node_practice', 'Practice again')),
            ),
        ],
      ),
    );
  }

  Widget _chestNode(int u, Unit unit) {
    final bool ready =
        unit.lessons.take(3).every((l) => appState.isCompleted(l.id));
    final bool claimed = _chests.contains('$u');
    final Color grey =
        context.isDark ? const Color(0xFF3A3733) : const Color(0xFFD9D9D9);
    final Widget core = Container(
      key: Key('chest_$u'),
      width: 56,
      height: 56,
      decoration: BoxDecoration(
          color: ready && !claimed ? RatelColors.honey : grey,
          shape: BoxShape.circle),
      child: Icon(claimed ? Icons.check : Icons.redeem,
          color: ready && !claimed ? Colors.white : RatelColors.textMuted,
          size: 26),
    );
    return GestureDetector(
      onTap: () => _chestTap(u, ready, claimed),
      child: _shift(40, ready && !claimed ? Pulse(child: core) : core),
    );
  }

  Future<void> _chestTap(int u, bool ready, bool claimed) async {
    if (claimed) return;
    if (!ready) {
      showDialog<void>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text(S.instance.t('chest_title', 'A reward chest!')),
          content: Text(S.instance.t('chest_locked',
              'Finish the three lessons above to open it.')),
          actions: [
            TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: Text(S.instance.t('btn_ok', 'OK'))),
          ],
        ),
      );
      return;
    }
    setState(() => _chests = {..._chests, '$u'});
    appState.addBonusXp(20);
    appState.addGems(5);
    try {
      final p = await SharedPreferences.getInstance();
      await p.setStringList('chests', _chests.toList());
    } catch (_) {}
    if (!mounted) return;
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(S.instance.t('chest_found_title',
            'You found 20 XP and 5 gems!')),
        content: Text(S.instance.t('chest_found_body',
            'The honey badger approves. Keep going!')),
        actions: [
          FilledButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: Text(S.instance.t('btn_claim', 'Claim'))),
        ],
      ),
    );
  }

  void _streakPopover() {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (ctx) => SafeArea(
        child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
                S.instance
                    .t('streak_days_title', '{n}-day streak')
                    .replaceAll('{n}', '${appState.streak}'),
                style: const TextStyle(
                    fontSize: 18, fontWeight: FontWeight.w800)),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 18),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.ac_unit,
                      color: RatelColors.teal, size: 18),
                  const SizedBox(width: 6),
                  Text(
                      S.instance
                          .t('freezes_count', 'Freezes: {n}/2')
                          .replaceAll(
                              '{n}', '${appState.streakFreezes}'),
                      style: const TextStyle(
                          fontSize: 13, fontWeight: FontWeight.w600)),
                  const SizedBox(width: 10),
                  if (appState.streakFreezes < 2)
                    TextButton(
                      onPressed: () async {
                        final bool ok = await appState.buyStreakFreeze(
                            cost: Flags.instance
                                .intOf('gem_freeze_cost', 200));
                        if (ctx.mounted) Navigator.of(ctx).pop();
                        if (!mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                                content: Text(ok
                                    ? S.instance.t('freeze_added',
                                        'Streak freeze added!')
                                    : S.instance.t(
                                        'gems_short',
                                        'Not enough gems yet — '
                                        'keep learning!'))));
                      },
                      child: Text(S.instance
                          .t('freeze_get', 'Get one · {n} gems')
                          .replaceAll(
                              '{n}',
                              '${Flags.instance.intOf('gem_freeze_cost', 200)}')),
                    ),
                ],
              ),
            ),
            const StreakCalendar(),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 2, 24, 8),
              child: Text(
                  S.instance.t('streak_tip',
                      "Practice every day so your streak won't break!"),
                  style: const TextStyle(
                      color: RatelColors.textMuted, fontSize: 13)),
            ),
          ],
        ),
        ),
      ),
    );
  }

  void _gemsPopover() {
    final int freezeCost = Flags.instance.intOf('gem_freeze_cost', 200);
    final int refillCost = Flags.instance.intOf('gem_refill_cost', 350);
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(S.instance.t('gems_title', 'Gems')),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.diamond,
                    color: RatelColors.teal, size: 26),
                const SizedBox(width: 8),
                Text('${appState.gems}',
                    style: const TextStyle(
                        fontSize: 26, fontWeight: FontWeight.w800)),
              ],
            ),
            const SizedBox(height: 6),
            Text(
                S.instance.t('gems_earn_hint',
                    'Earn gems from combos, flawless lessons and chests.'),
                textAlign: TextAlign.center,
                style: const TextStyle(
                    color: RatelColors.textMuted, fontSize: 13)),
            const SizedBox(height: 14),
            if (appState.streakFreezes < 2)
              FilledButton.tonalIcon(
                onPressed: () async {
                  final bool ok =
                      await appState.buyStreakFreeze(cost: freezeCost);
                  if (ctx.mounted) Navigator.of(ctx).pop();
                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text(ok
                          ? S.instance
                              .t('freeze_added', 'Streak freeze added!')
                          : S.instance.t('gems_short',
                              'Not enough gems yet — keep learning!'))));
                },
                icon: const Icon(Icons.ac_unit,
                    color: RatelColors.teal, size: 18),
                label: Text(S.instance
                    .t('gem_buy_freeze', 'Streak freeze · {n} gems')
                    .replaceAll('{n}', '$freezeCost')),
              ),
            if (!appState.isPro && appState.hearts < 5) ...[
              const SizedBox(height: 8),
              FilledButton.tonalIcon(
                onPressed: () {
                  Navigator.of(ctx).pop();
                  if (appState.gems >= refillCost) {
                    appState.refillHearts();
                    appState.spendGems(refillCost);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text(S.instance.t('gems_short',
                            'Not enough gems yet — keep learning!'))));
                  }
                },
                icon: const Icon(Icons.favorite,
                    color: RatelColors.hearts, size: 18),
                label: Text(S.instance
                    .t('refill_label', 'Refill hearts · {n} gems')
                    .replaceAll('{n}', '$refillCost')),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: Text(S.instance.t('btn_close', 'Close'))),
        ],
      ),
    );
  }

  void _heartsPopover() {
    final Duration? next = appState.nextHeartIn;
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(S.instance.t('hearts_title', 'Hearts')),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (int i = 0; i < 5; i++)
                  Icon(
                      appState.isPro || i < appState.hearts
                          ? Icons.favorite
                          : Icons.favorite_border,
                      color: RatelColors.hearts,
                      size: 26),
              ],
            ),
            const SizedBox(height: 10),
            Text(
                appState.isPro
                    ? S.instance
                        .t('hearts_pro', 'Unlimited hearts with Ratel Pro')
                    : (appState.hearts >= 5 || next == null)
                        ? S.instance.t('hearts_full',
                            'Hearts full — go get them!')
                        : S.instance
                            .t('hearts_next', 'Next heart in {t}')
                            .replaceAll('{t}', fmtCountdown(next)),
                style: const TextStyle(color: RatelColors.textMuted)),
            if (!appState.isPro && appState.hearts < 5) ...[
              const SizedBox(height: 12),
              FilledButton.tonalIcon(
                onPressed: () {
                  final int cost =
                      Flags.instance.intOf('gem_refill_cost', 350);
                  Navigator.of(ctx).pop();
                  if (appState.gems >= cost) {
                    appState.refillHearts();
                    appState.spendGems(cost);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                            content: Text(S.instance.t(
                                'gems_short',
                                'Not enough gems yet — keep learning!'))));
                  }
                },
                icon: const Icon(Icons.diamond,
                    color: RatelColors.teal, size: 18),
                label: Text(S.instance
                    .t('refill_label', 'Refill hearts · {n} gems')
                    .replaceAll(
                        '{n}',
                        '${Flags.instance.intOf('gem_refill_cost', 350)}')),
              ),
            ],
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () {
                  Navigator.of(ctx).pop();
                  setState(() => _tab = 1);
                },
                child: Text(
                    S.instance.t('hp_practice', 'Practice — earn a heart')),
              ),
            ),
            // KIND upsell — always BELOW the practice-earns-heart option
            // (anti-goals: no guilt loops, no dark patterns).
            if (!appState.isPro) ...[
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  key: const Key('hearts_pro_upsell'),
                  onPressed: () {
                    Navigator.of(ctx).pop();
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (_) => const PaywallScreen()));
                  },
                  icon: const Icon(Icons.workspace_premium,
                      color: RatelColors.honey, size: 18),
                  label: Text(S.instance
                      .t('pw_upsell', 'Ratel Pro — unlimited hearts')),
                ),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: Text(S.instance.t('btn_close', 'Close'))),
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
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 8),
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
              const SizedBox(width: 8),
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
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              RollingNumber(score,
                  style: const TextStyle(
                      fontSize: 30, fontWeight: FontWeight.w800)),
              const Text(' / 100',
                  style: TextStyle(
                      color: RatelColors.textMuted, fontSize: 13)),
              const SizedBox(width: 8),
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
          const SizedBox(height: 8),
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

  Widget _header() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      color: context.surfaceC,
      child: Row(
        children: [
          const CircleAvatar(
            radius: 14,
            backgroundColor: Color(0xFF185FA5),
            child: Text('EN',
                style: TextStyle(
                    color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600)),
          ),
          const SizedBox(width: 8),
          const Text('English',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
          const Spacer(),
          MergeSemantics(
            child: Semantics(
              button: true,
              label: S.instance.t('streak_title', 'Streak'),
              child: InkWell(
                key: const Key('streak_stat'),
                borderRadius: BorderRadius.circular(8),
                onTap: _streakPopover,
                child: _streakStat(appState.streak),
              ),
            ),
          ),
          const SizedBox(width: 12),
          MergeSemantics(
            child: Semantics(
              button: true,
              label: S.instance.t('gems_title', 'Gems'),
              child: InkWell(
                key: const Key('gems_stat'),
                borderRadius: BorderRadius.circular(8),
                onTap: _gemsPopover,
                child:
                    _numStat(Icons.diamond, appState.gems, RatelColors.teal),
              ),
            ),
          ),
          const SizedBox(width: 12),
          _numStat(Icons.bolt, appState.xp, RatelColors.honey),
          const SizedBox(width: 12),
          MergeSemantics(
            child: Semantics(
              button: true,
              label: S.instance.t('hearts_title', 'Hearts'),
              child: InkWell(
                key: const Key('hearts_stat'),
                borderRadius: BorderRadius.circular(8),
                onTap: _heartsPopover,
            child: appState.isPro
                ? Row(mainAxisSize: MainAxisSize.min, children: const [
                    Icon(Icons.favorite,
                        color: RatelColors.hearts, size: 18),
                    SizedBox(width: 3),
                    Text('∞',
                        style: TextStyle(
                            color: RatelColors.hearts,
                            fontWeight: FontWeight.w700,
                            fontSize: 16)),
                  ])
                    : _numStat(Icons.favorite, appState.hearts,
                        RatelColors.hearts),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _numStat(IconData icon, int value, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: color, size: 18),
        const SizedBox(width: 3),
        RollingNumber(value,
            style: TextStyle(
                color: color, fontWeight: FontWeight.w600, fontSize: 14)),
      ],
    );
  }

  Widget _streakStat(int streak) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        StreakFlame(streak: streak, size: 18),
        const SizedBox(width: 3),
        RollingNumber(streak,
            style: const TextStyle(
                color: RatelColors.coral,
                fontWeight: FontWeight.w600,
                fontSize: 14)),
      ],
    );
  }

  static const List<IconData> _unitIcons = [
    Icons.menu_book, // 1 everyday basics
    Icons.location_city, // 2 out and about
    Icons.task_alt, // 3 getting things done
    Icons.event, // 4 plans & connections
    Icons.restaurant, // 5 daily life
    Icons.headphones, // 6 listen & understand
    Icons.work, // 7 work & school
    Icons.forum, // 8 stories & opinions
    Icons.flight, // 9 travel & places
    Icons.favorite, // 10 health & feelings
  ];

  void _showGuidebook(int index, Unit unit) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (ctx) => SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.menu_book, color: unitAccent(index)),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                        S.instance
                            .t('gb_title', 'Guidebook · {sub}')
                            .replaceAll('{sub}', unit.subtitle),
                        style: const TextStyle(
                            fontSize: 17, fontWeight: FontWeight.w800)),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(S.instance.t('gb_sub', 'Key phrases from this unit'),
                  style: const TextStyle(
                      color: RatelColors.textMuted, fontSize: 12.5)),
              const SizedBox(height: 12),
              for (final (i, entry)
                  in guidebookFor(unit).indexed) ...[
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                        appState.isCompleted(unit.lessons[i].id)
                            ? Icons.check_circle
                            : Icons.radio_button_unchecked,
                        size: 18,
                        color: appState.isCompleted(unit.lessons[i].id)
                            ? RatelColors.teal
                            : RatelColors.textMuted),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(entry.$1,
                              style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 14)),
                          Text(entry.$2,
                              style: TextStyle(
                                  color: context.mutedC, fontSize: 13)),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
              ],
            ],
          ),
        ),
      ),
    );
  }

  /// Locked = some lesson in an earlier unit is still incomplete.
  bool _sectionLocked(CourseSection s) {
    if (s.firstUnit == 0) return false;
    for (int i = 0; i < s.firstUnit && i < course.length; i++) {
      for (final l in course[i].lessons) {
        if (!appState.isCompleted(l.id)) return true;
      }
    }
    return false;
  }

  /// Always-visible 'you are here' bar above the scrolling path.
  Widget _pinnedUnitBar(int u) {
    final unit = course[u];
    final int done =
        unit.lessons.where((l) => appState.isCompleted(l.id)).length;
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: unitAccent(u),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(_unitIcons[u % _unitIcons.length],
              color: Colors.white, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
                S.instance
                    .t('unit_label', 'Unit {n} · {sub}')
                    .replaceAll('{n}', '${u + 1}')
                    .replaceAll('{sub}', unit.subtitle),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 13)),
          ),
          Text('$done/${unit.lessons.length}',
              style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                  fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }

  Widget _sectionBanner(int u) {
    final s = sectionForUnit(u);
    final int last =
        s.lastUnit < course.length ? s.lastUnit : course.length - 1;
    int unitsDone = 0;
    for (int i = s.firstUnit; i <= last; i++) {
      if (course[i].lessons.every((l) => appState.isCompleted(l.id))) {
        unitsDone++;
      }
    }
    final int total = last - s.firstUnit + 1;
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 18, 16, 0),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: context.surfaceC,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.borderC),
      ),
      child: Row(
        children: [
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
                color: unitAccent(s.firstUnit),
                borderRadius: BorderRadius.circular(10)),
            child: Text(s.cefr,
                style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 13)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                    S.instance
                        .t('section_label', 'Section {n}')
                        .replaceAll('{n}', '${kSections.indexOf(s) + 1}'),
                    style: const TextStyle(
                        color: RatelColors.textMuted, fontSize: 11)),
                Text(s.title,
                    style: const TextStyle(
                        fontWeight: FontWeight.w800, fontSize: 16)),
              ],
            ),
          ),
          if (_sectionLocked(s))
            TextButton(
              onPressed: () => Navigator.of(context)
                  .push(ratelRoute(SectionTestScreen(section: s)))
                  .then((_) => setState(() {})),
              child: Text(S.instance.t('test_out', 'Test out')),
            )
          else
            Text(
                S.instance
                    .t('n_units', '{a}/{b} units')
                    .replaceAll('{a}', '$unitsDone')
                    .replaceAll('{b}', '$total'),
                style: const TextStyle(
                    color: RatelColors.textMuted,
                    fontSize: 12,
                    fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }

  Widget _unitBanner(int index, Unit unit) {
    final int done =
        unit.lessons.where((l) => appState.isCompleted(l.id)).length;
    return MergeSemantics(
      child: Semantics(
        button: true,
        label: S.instance.t('gb_open', 'Open guidebook'),
        child: GestureDetector(
          key: _unitKeyFor(index),
          onTap: () => _showGuidebook(index, unit),
          child: Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
          color: unitAccent(index), borderRadius: BorderRadius.circular(14)),
      child: Row(
        children: [
          Icon(_unitIcons[index % _unitIcons.length], color: Colors.white),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                    S.instance
                        .t('unit_n', 'Unit {n}')
                        .replaceAll('{n}', '${index + 1}'),
                    style:
                        const TextStyle(color: Colors.white70, fontSize: 12)),
                Text(unit.subtitle,
                    style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 15)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(12)),
            child: Text('$done/${unit.lessons.length}',
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w700)),
          ),
          const SizedBox(width: 8),
          const Icon(Icons.menu_book, color: Colors.white70, size: 16),
        ],
      ),
          ),
        ),
      ),
    );
  }

  /// Horizontal path offset via LAYOUT (Padding), not paint
  /// (Transform.translate), so hit-testing matches what's drawn.
  Widget _shift(double dx, Widget child) => Padding(
        padding: EdgeInsets.only(
            left: dx > 0 ? dx * 2 : 0, right: dx < 0 ? -dx * 2 : 0),
        child: child,
      );

  Widget _node(
      {required NodeState state,
      double dx = 0,
      bool trophy = false,
      String? title,
      Color? accent}) {
    final (Color bg, IconData icon) = switch (state) {
      NodeState.done => (accent ?? RatelColors.teal, Icons.check),
      NodeState.locked => (
          context.isDark ? const Color(0xFF3A3733) : const Color(0xFFD9D9D9),
          trophy ? Icons.emoji_events : Icons.lock
        ),
      NodeState.current => (RatelColors.honey, Icons.star),
    };
    return _shift(
      dx,
      Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 62,
            height: 62,
            decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
            child: Icon(icon,
                color: state == NodeState.locked
                    ? RatelColors.textMuted
                    : Colors.white,
                size: 28),
          ),
          if (title != null) ...[
            const SizedBox(height: 4),
            SizedBox(
              width: 130,
              child: Text(title,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: state == NodeState.locked
                          ? RatelColors.textMuted
                          : context.textC)),
            ),
          ],
        ],
      ),
    );
  }

  Widget _currentNode(BuildContext context, Lesson lesson) {
    return Transform.translate(
      offset: const Offset(-4, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
                decoration: BoxDecoration(
                    color: RatelColors.charcoal,
                    borderRadius: BorderRadius.circular(20)),
                child: Text(S.instance.t('start_pill', 'Start'),
                    style: const TextStyle(
                        color: RatelColors.cream,
                        fontSize: 11,
                        fontWeight: FontWeight.w600)),
              ),
              const SizedBox(height: 6),
              GestureDetector(
                onTap: () {
                  if (appState.hearts <= 0 && !appState.isPro) {
                    showHeartsSheet(context,
                        onPractice: () => setState(() => _tab = 1));
                    return;
                  }
                  Navigator.of(context).push(
                    ratelRoute(LessonScreen(lesson: lesson)),
                  );
                },
                child: Pulse(
                  child: Container(
                    width: 66,
                    height: 66,
                    decoration: BoxDecoration(
                        color: RatelColors.honey,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                              color: RatelColors.honey.withValues(alpha: 0.45),
                              blurRadius: 18,
                              spreadRadius: 1),
                        ]),
                    child:
                        const Icon(Icons.star, color: Colors.white, size: 30),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 12),
          const RatelActionAnim(
              action: 'walk',
              fallbackPose: RatelPose.encourage,
              size: 72),
        ],
      ),
    );
  }
}
