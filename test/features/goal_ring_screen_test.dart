import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ratel/core/theme/theme.dart';
import 'package:ratel/features/social/screens/goal_ring_screen.dart';

void main() {
  testWidgets('goal ring renders chest with no overflow', (tester) async {
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      MaterialApp(theme: ratelTheme(), home: const GoalRingScreen()),
    );
    expect(find.text('Daily goal'), findsOneWidget);
    expect(find.text('Daily chest'), findsOneWidget);
    expect(find.text('Open chest'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
