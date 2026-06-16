import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ratel/core/theme/theme.dart';
import 'package:ratel/features/onboarding/screens/language_picker_screen.dart';

void main() {
  testWidgets('language picker renders at 360px with no overflow',
      (tester) async {
    tester.view.physicalSize = const Size(360, 820);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      MaterialApp(theme: ratelTheme(), home: const LanguagePickerScreen()),
    );
    expect(find.text('Welcome to Ratel'), findsOneWidget);
    expect(find.text('I speak'), findsOneWidget);
    expect(find.text('I want to learn'), findsOneWidget);
    expect(find.text('English'), findsOneWidget);
    expect(find.text('Continue'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
