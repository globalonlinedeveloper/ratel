import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ratel/core/theme/theme.dart';
import 'package:ratel/features/practice/screens/writing_feedback_screen.dart';

void main() {
  testWidgets('writing feedback renders redline with no overflow',
      (tester) async {
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      MaterialApp(theme: ratelTheme(), home: const WritingFeedbackScreen()),
    );
    expect(find.text('Write about your weekend'), findsOneWidget);
    expect(find.text('AI redline · 2 fixes'), findsOneWidget);
    expect(find.text('Rewrite with tips'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
