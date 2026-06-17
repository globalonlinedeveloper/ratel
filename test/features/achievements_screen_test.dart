import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ratel/core/theme/theme.dart';
import 'package:ratel/features/social/screens/achievements_screen.dart';

void main() {
  testWidgets('achievements render badge grid with no overflow',
      (tester) async {
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      MaterialApp(theme: ratelTheme(), home: const AchievementsScreen()),
    );
    expect(find.text('Awards'), findsOneWidget);
    expect(find.text('Gold'), findsOneWidget);
    expect(find.text('See all 40'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
