import '../guest.dart';
import '../widgets/save_account_sheet.dart';
import '../widgets/streak_calendar.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/material.dart';
import '../widgets/motd_card.dart';
import '../widgets/hearts_sheet.dart';
import '../widgets/anniversary_card.dart';
import '../widgets/ratel_mascot.dart';
import '../widgets/mascot_anim.dart';
import 'package:flutter/services.dart';
import '../theme.dart';
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
import 'paywall_screen.dart';
import '../widgets/transitions.dart';
import '../widgets/rolling_number.dart';
import '../widgets/streak_flame.dart';
import '../widgets/mistakes_review.dart';
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

  @override
  void initState() {
    super.initState();
    if (!appState.loaded) {
      appState.sync();
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: appState,
      builder: (context, _) {
        if (Config.hasSupabase && appState.loaded && !appState.onboarded) {
          return const OnboardingScreen();
        }
        return Scaffold(
          body: SafeArea(child: _body(context)),
          bottomNavigationBar: NavigationBar(
            selectedIndex: _tab,
            onDestinationSelected: (i) => setState(() => _tab = i),
            destinations: const [
              NavigationDestination(
                  icon: Icon(Icons.home_outlined),
                  selectedIcon: Icon(Icons.home),
                  label: 'Learn'),
              NavigationDestination(
                  icon: Icon(Icons.edit_outlined), label: 'Practice'),
              NavigationDestination(
                  icon: Icon(Icons.forum_outlined),
                  selectedIcon: Icon(Icons.forum),
                  label: 'Coach'),
              NavigationDestination(
                  icon: Icon(Icons.emoji_events_outlined), label: 'Leagues'),
              NavigationDestination(
                  icon: Icon(Icons.person_outline), label: 'Profile'),
            ],
          ),
        );
      },
    );
  }

  void _shareInvite(BuildContext context) {
    final streak = appState.streak;
    final code = appState.friendCode;
    final streakLine = streak > 0
        ? "I'm on a $streak-day streak learning English with Ratel! 🔥 "
        : 'I\'m learning English with Ratel, a fearless honey badger. 🦡 ';
    final invite = code.isEmpty
        ? ''
        : ' Add me with code $code.';
    final msg =
        '${streakLine}Join me: https://globalonlinedeveloper.github.io/ratel/$invite';
    Clipboard.setData(ClipboardData(text: msg));
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Invite copied — paste it anywhere to share!')));
  }

  Widget _placeholder() => const Center(
        child: Text('Coming soon', style: TextStyle(color: RatelColors.textMuted)),
      );

  Widget _body(BuildContext context) {
    switch (_tab) {
      case 0:
        return _buildLearn(context);
      case 1:
        return _buildPractice();
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

  Widget _buildPractice() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text('Practice',
            style: TextStyle(fontSize: 20, fontFamily: kDisplayFont, fontWeight: FontWeight.w700)),
        const SizedBox(height: 12),
        const MistakesReview(),
        const Text('Revisit lessons',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
        const SizedBox(height: 4),
        const Text('Replay any lesson to sharpen up.',
            style: TextStyle(color: RatelColors.textMuted)),
        const SizedBox(height: 12),
        ...List.generate(course.length, (u) {
          final unit = course[u];
          final int doneCount =
              unit.lessons.where((l) => appState.isCompleted(l.id)).length;
          final bool hasCurrent =
              unit.lessons.any((l) => !appState.isCompleted(l.id)) &&
                  (u == 0 ||
                      course[u - 1]
                          .lessons
                          .every((l) => appState.isCompleted(l.id)));
          return Container(
            margin: const EdgeInsets.only(bottom: 10),
            decoration: BoxDecoration(
              color: context.surfaceC,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: context.borderC),
            ),
            clipBehavior: Clip.antiAlias,
            child: Theme(
              data: Theme.of(context)
                  .copyWith(dividerColor: Colors.transparent),
              child: ExpansionTile(
                initiallyExpanded: hasCurrent,
                leading: CircleAvatar(
                  radius: 16,
                  backgroundColor: unitAccent(u),
                  child: Text('${u + 1}',
                      style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: 13)),
                ),
                title: Text(unit.subtitle,
                    style: const TextStyle(
                        fontWeight: FontWeight.w700, fontSize: 15)),
                subtitle: Text('$doneCount/${unit.lessons.length} lessons',
                    style: const TextStyle(
                        color: RatelColors.textMuted, fontSize: 12)),
                children: [
                  for (final l in unit.lessons) _practiceRow(context, l),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _practiceRow(BuildContext context, Lesson l) {
    final bool done = appState.isCompleted(l.id);
    {
      {
          return Padding(
            padding: EdgeInsets.zero,
            child: InkWell(
              onTap: () {
                if (appState.hearts <= 0 && !appState.isPro) {
                  showHeartsSheet(context);
                  return;
                }
                Navigator.of(context)
                    .push(ratelRoute(LessonScreen(lesson: l)));
              },
              borderRadius: BorderRadius.circular(14),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 16,
                      backgroundColor:
                          done ? RatelColors.teal : RatelColors.honey,
                      child: Icon(done ? Icons.check : Icons.play_arrow,
                          color: Colors.white, size: 20),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(l.title,
                              style: const TextStyle(
                                  fontWeight: FontWeight.w600, fontSize: 16)),
                          Text('${l.exercises.length} exercises',
                              style: const TextStyle(
                                  color: RatelColors.textMuted, fontSize: 13)),
                        ],
                      ),
                    ),
                    const Icon(Icons.chevron_right,
                        color: RatelColors.textMuted),
                  ],
                ),
              ),
            ),
          );
      }
    }
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
                label: const Text('Guest — save your progress'),
              ),
            )
          else
          Text(appState.email.isEmpty ? 'Learning English' : appState.email,
              style: const TextStyle(color: RatelColors.textMuted)),
          const SizedBox(height: 20),
          const DailyGoalCard(),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: GestureDetector(
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
                    const Icon(Icons.workspace_premium, color: Colors.white),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                          appState.isPro
                              ? 'Ratel Pro is active ✨'
                              : 'Ratel Pro — unlimited hearts & more',
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
                    'Day streak', RatelColors.coral, flame: true),
                _statCardNum(Icons.bolt, appState.xp, 'Total XP',
                    RatelColors.honey),
                _statCardNum(Icons.favorite, appState.hearts, 'Hearts',
                    RatelColors.hearts),
                _statCardNum(Icons.task_alt, appState.completedCount,
                    'Lessons done', RatelColors.teal),
              ],
            ),
          ),
          const SizedBox(height: 12),
          const StreakCalendar(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.ac_unit, size: 15, color: RatelColors.teal),
                Text(' ${appState.streakFreezes} freezes',
                    style: const TextStyle(
                        color: RatelColors.textMuted, fontSize: 13)),
                const SizedBox(width: 14),
                const Icon(Icons.emoji_events,
                    size: 15, color: RatelColors.honey),
                Text(' best ${appState.longestStreak}-day streak',
                    style: const TextStyle(
                        color: RatelColors.textMuted, fontSize: 13)),
              ],
            ),
          ),
          const SizedBox(height: 8),
          const WeakAreasSummary(),
          const AchievementsView(),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Sound effects'),
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
                  title: const Text('Haptics'),
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
                  title: const Text('Background music'),
                  subtitle: const Text('Calm ambient loop while you learn'),
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
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Reduce motion'),
                  subtitle: const Text('Minimize animations'),
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
                  title: const Text('Battle mode'),
                  subtitle: const Text('Duel a rival as you answer'),
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
                    segments: const [
                      ButtonSegment(
                          value: ThemeMode.system,
                          icon: Icon(Icons.brightness_auto_outlined),
                          label: Text('Auto')),
                      ButtonSegment(
                          value: ThemeMode.light,
                          icon: Icon(Icons.light_mode_outlined),
                          label: Text('Light')),
                      ButtonSegment(
                          value: ThemeMode.dark,
                          icon: Icon(Icons.dark_mode_outlined),
                          label: Text('Dark')),
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
          if (Config.hasSupabase) ...[
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: () => Navigator.of(context).push(MaterialPageRoute(
                  builder: (_) => const FriendsScreen())),
              icon: const Icon(Icons.group_outlined),
              label: const Text('Friends'),
            ),
          ],
          if (Config.hasSupabase) ...[
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: () => _shareInvite(context),
              icon: const Icon(Icons.ios_share),
              label: const Text('Share / invite friends'),
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
          ],
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextButton(
                onPressed: () => launchUrl(Uri.parse(
                    'https://globalonlinedeveloper.github.io/ratel/privacy.html')),
                child: const Text('Privacy policy',
                    style: TextStyle(
                        color: RatelColors.textMuted, fontSize: 12)),
              ),
              TextButton(
                onPressed: () => launchUrl(Uri.parse(
                    'https://globalonlinedeveloper.github.io/ratel/terms.html')),
                child: const Text('Terms',
                    style: TextStyle(
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
              label: const Text('Log out',
                  style: TextStyle(color: RatelColors.textMuted)),
            ),
            TextButton.icon(
              onPressed: () => _confirmDeleteAccount(context, appState),
              icon: const Icon(Icons.delete_forever,
                  color: RatelColors.coral, size: 18),
              label: const Text('Delete account',
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
        title: const Text('Delete your account?'),
        content: const Text(
            'This permanently deletes your account and ALL progress '
            '(XP, streak, friends, history). This cannot be undone.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: const Text('Keep my account')),
          FilledButton(
            style: FilledButton.styleFrom(
                backgroundColor: RatelColors.coral),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Delete forever'),
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
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content:
                Text("Couldn't delete right now — please try again.")));
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
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
    const List<double> offsets = [-50.0, 10.0, 50.0, 0.0, -40.0];

    final List<Widget> path = [];
    for (int u = 0; u < course.length; u++) {
      final unit = course[u];
      if (u > 0) path.add(_checkpoint(u));
      path.add(_unitBanner(u, unit));
      path.add(const SizedBox(height: 14));
      for (int i = 0; i < unit.lessons.length; i++) {
        final Lesson l = unit.lessons[i];
        final NodeState st = appState.isCompleted(l.id)
            ? NodeState.done
            : (l.id == currentId ? NodeState.current : NodeState.locked);
        path.add(st == NodeState.current
            ? KeyedSubtree(key: _currentNodeKey, child: _currentNode(context, l))
            : _node(
                state: st,
                dx: offsets[i % offsets.length],
                title: l.title,
                accent: unitAccent(u)));
        path.add(const SizedBox(height: 14));
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
        const StreakRepairCard(),
        const DailyNudge(),
        const ReviewCard(),
        const DailyQuestsCard(),
        const AnniversaryCard(),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.only(top: 12, bottom: 16),
            child: Column(children: path),
          ),
        ),
      ],
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
          _streakStat(appState.streak),
          const SizedBox(width: 12),
          _numStat(Icons.bolt, appState.xp, RatelColors.honey),
          const SizedBox(width: 12),
          appState.isPro
              ? Row(mainAxisSize: MainAxisSize.min, children: const [
                  Icon(Icons.favorite, color: RatelColors.hearts, size: 18),
                  SizedBox(width: 3),
                  Text('∞',
                      style: TextStyle(
                          color: RatelColors.hearts,
                          fontWeight: FontWeight.w700,
                          fontSize: 16)),
                ])
              : _numStat(Icons.favorite, appState.hearts, RatelColors.hearts),
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

  Widget _unitBanner(int index, Unit unit) {
    final int done =
        unit.lessons.where((l) => appState.isCompleted(l.id)).length;
    return Container(
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
                Text(unit.title,
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
        ],
      ),
    );
  }

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
    return Transform.translate(
      offset: Offset(dx, 0),
      child: Column(
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
                child: const Text('Start',
                    style: TextStyle(
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
          const RatelMascot(pose: RatelPose.encourage, size: 72),
        ],
      ),
    );
  }
}
