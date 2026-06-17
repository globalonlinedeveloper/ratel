import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ratel/core/theme/theme.dart';
import 'package:ratel/features/practice/screens/timed_challenge_screen.dart';

void main() {
  testWidgets('timed challenge renders at 360px with no overflow',
      (tester) async {
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      MaterialApp(theme: ratelTheme(), home: const TimedChallengeScreen()),
    );
    expect(find.text('Timed challenge'), findsOneWidget);
    expect(find.text('60s'), findsOneWidget);
    expect(find.text('42'), findsOneWidget);
    expect(find.text('Start challenge'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
