import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ratel/core/theme/theme.dart';
import 'package:ratel/features/social/screens/streak_society_screen.dart';

void main() {
  testWidgets('streak society renders tiers with no overflow', (tester) async {
    tester.view.physicalSize = const Size(360, 820);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      MaterialApp(theme: ratelTheme(), home: const StreakSocietyScreen()),
    );
    expect(find.text('Streak Society'), findsOneWidget);
    expect(find.text('Member · day 7+'), findsOneWidget);
    expect(find.text('View my perks'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
