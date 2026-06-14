import '../../widgets/streak_calendar.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../widgets/motd_card.dart';
import '../../widgets/campaign_cards.dart';
import '../../widgets/hearts_sheet.dart';
import '../../widgets/daily_chest.dart';
import '../../widgets/perfect_week.dart';
import '../../widgets/monthly_quest.dart';
import '../../widgets/anniversary_card.dart';
import '../../widgets/ratel_mascot.dart';
import '../../widgets/mascot_anim.dart';
import '../../theme.dart';
import '../../flags.dart';
import '../../strings.dart';
import '../../milestones.dart';
import '../../guidebook.dart';
import '../section_test_screen.dart';
import '../../models.dart';
import '../../content.dart';
import '../../app_state.dart';
import '../lesson_screen.dart';
import '../paywall_screen.dart';
import '../../widgets/transitions.dart';
import '../../widgets/rolling_number.dart';
import '../../widgets/streak_flame.dart';
import '../../widgets/daily_nudge.dart';
import '../../widgets/streak_repair_card.dart';
import '../../widgets/review_card.dart';
import '../../widgets/daily_quests_card.dart';
import '../../widgets/pulse.dart';

enum NodeState { done, current, locked }

/// Learn tab body (home tab-shell, index 0) — the lessons path.
///
/// Extracted verbatim from the `home_screen` god-screen (Standardization
/// Master Plan, Phase 1, Inc 171). A tab body is NOT a pushed route, so it
/// carries no [RatelScaffold]/back header; the in-path header (streak/gems/
/// hearts stats + popovers) is part of this tab. Tab switches go through the
/// [onSwitchTab] callback (HomeScreen owns the bottom-nav `_tab`). This
/// increment is a STRUCTURAL move only — token/a11y migration follows.
class LearnTab extends StatefulWidget {
  const LearnTab({super.key, required this.onSwitchTab});

  final void Function(int) onSwitchTab;

  @override
  State<LearnTab> createState() => _LearnTabState();
}

class _LearnTabState extends State<LearnTab> {

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

  Set<String> _chests = {};

  @override
  void initState() {
    super.initState();
    SharedPreferences.getInstance().then((p) {
      if (!mounted) return;
      setState(() => _chests = (p.getStringList('chests') ?? const []).toSet());
    });
  }

  final GlobalKey _currentNodeKey = GlobalKey();
  String? _autoScrolled;

  static const List<String> _checkpointArt = [
    'map', 'reading', 'trophyhold', 'determined', 'curious'
  ];

  Widget _checkpoint(int index) {
    final String name = _checkpointArt[index % _checkpointArt.length];
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: RatelSpacing.xs),
      child: Row(
        children: [
          Expanded(
              child: Divider(
                  color: context.faintBorderC, indent: 28, endIndent: 14)),
          ExcludeSemantics(child: Image.asset('assets/images/ratel-$name.webp',
              width: 60,
              height: 60,
              errorBuilder: (_, _, _) =>
                  const SizedBox(width: 60, height: 60))),
          Expanded(
              child: Divider(
                  color: context.faintBorderC, indent: 14, endIndent: 28)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
        CampaignCards(onCoach: () => widget.onSwitchTab(2)),
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
              padding: const EdgeInsets.only(top: RatelSpacing.md, bottom: RatelSpacing.lg),
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
                      onPractice: () => widget.onSwitchTab(1));
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
        context.lockedNodeC;
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
              padding: const EdgeInsets.fromLTRB(RatelSpacing.xl, 0, RatelSpacing.xl, 18),
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
              padding: const EdgeInsets.fromLTRB(RatelSpacing.xl, 2, RatelSpacing.xl, RatelSpacing.sm),
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
                const SizedBox(width: RatelSpacing.sm),
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
              const SizedBox(height: RatelSpacing.sm),
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
              const SizedBox(height: RatelSpacing.md),
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
            const SizedBox(height: RatelSpacing.md),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () {
                  Navigator.of(ctx).pop();
                  widget.onSwitchTab(1);
                },
                child: Text(
                    S.instance.t('hp_practice', 'Practice — earn a heart')),
              ),
            ),
            // KIND upsell — always BELOW the practice-earns-heart option
            // (anti-goals: no guilt loops, no dark patterns).
            if (!appState.isPro) ...[
              const SizedBox(height: RatelSpacing.sm),
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

  Widget _header() {
    return Container(
      padding: const EdgeInsets.fromLTRB(RatelSpacing.lg, RatelSpacing.md, RatelSpacing.lg, RatelSpacing.md),
      color: context.surfaceC,
      child: Row(
        children: [
          const CircleAvatar(
            radius: 14,
            backgroundColor: RatelColors.enBadge,
            child: Text('EN',
                style: TextStyle(
                    color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600)),
          ),
          const SizedBox(width: RatelSpacing.sm),
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
          const SizedBox(width: RatelSpacing.md),
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
          const SizedBox(width: RatelSpacing.md),
          _numStat(Icons.bolt, appState.xp, RatelColors.honey),
          const SizedBox(width: RatelSpacing.md),
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
          padding: const EdgeInsets.fromLTRB(20, 0, 20, RatelSpacing.xl),
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
              const SizedBox(height: RatelSpacing.xs),
              Text(S.instance.t('gb_sub', 'Key phrases from this unit'),
                  style: const TextStyle(
                      color: RatelColors.textMuted, fontSize: 12.5)),
              const SizedBox(height: RatelSpacing.md),
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
                const SizedBox(height: RatelSpacing.md),
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
      margin: const EdgeInsets.fromLTRB(RatelSpacing.lg, RatelSpacing.sm, RatelSpacing.lg, 0),
      padding: const EdgeInsets.symmetric(horizontal: RatelSpacing.md, vertical: RatelSpacing.sm),
      decoration: BoxDecoration(
        color: unitAccent(u),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(_unitIcons[u % _unitIcons.length],
              color: Colors.white, size: 18),
          const SizedBox(width: RatelSpacing.sm),
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
      margin: const EdgeInsets.fromLTRB(RatelSpacing.lg, 18, RatelSpacing.lg, 0),
      padding: const EdgeInsets.symmetric(horizontal: RatelSpacing.lg, vertical: RatelSpacing.md),
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
          const SizedBox(width: RatelSpacing.md),
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
      margin: const EdgeInsets.fromLTRB(RatelSpacing.lg, RatelSpacing.md, RatelSpacing.lg, RatelSpacing.xs),
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
          const SizedBox(width: RatelSpacing.sm),
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
          context.lockedNodeC,
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
            const SizedBox(height: RatelSpacing.xs),
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
                        onPractice: () => widget.onSwitchTab(1));
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
          const SizedBox(width: RatelSpacing.md),
          const ExcludeSemantics(child: RatelActionAnim(
              action: 'walk',
              fallbackPose: RatelPose.encourage,
              size: 72)),
        ],
      ),
    );
  }
}
