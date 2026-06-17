import 'package:flutter/material.dart';
import '../../../design_system/components/ratel_bottom_nav.dart';
import '../../learn/screens/home_screen.dart';
import '../../practice/screens/practice_hub_screen.dart';
import '../../profile/screens/profile_screen.dart';
import '../../social/screens/leagues_screen.dart';

/// Main app shell — the post-auth tabbed surface. Holds the four tab roots in an
/// IndexedStack with one shared bottom nav (Home / Practice / Leagues / Profile),
/// so tabs switch in place and pushing a sub-screen covers the whole shell.
class MainShell extends StatefulWidget {
  const MainShell({super.key, this.initialTab = 0});

  final int initialTab;

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  late int _tab = widget.initialTab;

  static const List<Widget> _tabs = <Widget>[
    HomeScreen(),
    PracticeHubScreen(),
    LeaguesScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _tab, children: _tabs),
      bottomNavigationBar: SafeArea(
        top: false,
        child: RatelBottomNav(
          currentIndex: _tab,
          onTap: (int i) => setState(() => _tab = i),
        ),
      ),
    );
  }
}
