import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ratel/core/theme/theme.dart';
import 'package:ratel/features/onboarding/screens/level_result_screen.dart';

void main() {
  testWidgets('level result renders at 360px with no overflow', (tester) async {
    tester.view.physicalSize = const Size(360, 820);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      MaterialApp(theme: ratelTheme(), home: const LevelResultScreen()),
    );
    expect(find.text('A2'), findsOneWidget);
    expect(find.text("You're at A2 — Elementary"), findsOneWidget);
    expect(find.text('Everyday phrases'), findsOneWidget);
    expect(find.text('Start learning'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
