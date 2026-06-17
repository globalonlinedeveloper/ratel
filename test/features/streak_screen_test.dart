import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ratel/core/theme/theme.dart';
import 'package:ratel/features/social/screens/streak_screen.dart';

void main() {
  testWidgets('streak screen renders week grid with no overflow',
      (tester) async {
    tester.view.physicalSize = const Size(360, 820);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      MaterialApp(theme: ratelTheme(), home: const StreakScreen()),
    );
    expect(find.text('7 days'), findsOneWidget);
    expect(find.text('Repair'), findsOneWidget);
    expect(find.text('Keep it going'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
