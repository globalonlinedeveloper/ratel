import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ratel/core/theme/theme.dart';
import 'package:ratel/features/social/screens/full_leaderboard_screen.dart';

void main() {
  testWidgets('full leaderboard renders cohort at 360px with no overflow',
      (tester) async {
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      MaterialApp(theme: ratelTheme(), home: const FullLeaderboardScreen()),
    );
    // Title + cohort subtitle (subtitle is unique to this screen).
    expect(find.text('Full leaderboard'), findsOneWidget);
    expect(find.text('Your cohort this week · 30 learners'), findsOneWidget);
    // Promote + demote zone banners.
    expect(find.text('↑ top 7 promote'), findsOneWidget);
    expect(find.text('↓ bottom 5 demote'), findsOneWidget);
    // The signed-in learner row + a top name + the rank-30 tail are all built
    // (SingleChildScrollView builds all children eagerly).
    expect(find.text('You'), findsOneWidget);
    expect(find.text('mira_x'), findsOneWidget);
    expect(find.text('bo_jin'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
