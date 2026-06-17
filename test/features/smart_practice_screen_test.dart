import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ratel/core/theme/theme.dart';
import 'package:ratel/features/practice/screens/smart_practice_screen.dart';

void main() {
  testWidgets('smart practice renders weak skills with no overflow',
      (tester) async {
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      MaterialApp(theme: ratelTheme(), home: const SmartPracticeScreen()),
    );
    expect(find.text('Smart practice'), findsOneWidget);
    expect(find.text('Verb agreement'), findsOneWidget);
    expect(find.text('Start · 12 items'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
