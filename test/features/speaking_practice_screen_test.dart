import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ratel/core/theme/theme.dart';
import 'package:ratel/features/practice/screens/speaking_practice_screen.dart';

void main() {
  testWidgets('speaking practice renders at 360px with no overflow',
      (tester) async {
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      MaterialApp(theme: ratelTheme(), home: const SpeakingPracticeScreen()),
    );
    expect(find.text('Say this sentence'), findsOneWidget);
    expect(find.text('See my score'), findsOneWidget);
    expect(find.text('Tap to retry'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
