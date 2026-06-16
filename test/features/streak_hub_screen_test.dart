import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ratel/core/theme/theme.dart';
import 'package:ratel/features/learn/screens/streak_hub_screen.dart';

void main() {
  testWidgets('streak hub renders at 360px with no overflow', (tester) async {
    tester.view.physicalSize = const Size(360, 820);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      MaterialApp(theme: ratelTheme(), home: const StreakHubScreen()),
    );
    expect(find.text('7 days'), findsOneWidget);
    expect(find.text("Today's quests"), findsOneWidget);
    expect(find.text('Earn 30 XP'), findsOneWidget);
    expect(find.text('View leagues'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
