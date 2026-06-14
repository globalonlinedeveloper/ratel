import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme.dart';
import '../flags.dart';
import '../strings.dart';
import '../comeback.dart';
import '../milestones.dart';
import '../app_state.dart';
import '../config.dart';
import 'onboarding_screen.dart';
import 'coach_screen.dart';
import 'home/practice_tab.dart';
import 'home/learn_tab.dart';
import 'home/profile_tab.dart';
import '../widgets/leagues_board.dart';

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
    SharedPreferences.getInstance().then((p) async {
      if (!mounted) return;
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
        return LearnTab(onSwitchTab: (i) => setState(() => _tab = i));
      case 1:
        return const PracticeTab();
      case 2:
        return const CoachScreen();
      case 3:
        return _buildLeagues();
      case 4:
        return const ProfileTab();
      default:
        return _placeholder();
    }
  }

  Widget _buildLeagues() {
    return const LeaguesBoard();
  }

}
