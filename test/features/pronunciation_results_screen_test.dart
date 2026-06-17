import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ratel/core/theme/theme.dart';
import 'package:ratel/features/practice/screens/pronunciation_results_screen.dart';

void main() {
  testWidgets('pronunciation results render metrics with no overflow',
      (tester) async {
    tester.view.physicalSize = const Size(360, 820);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      MaterialApp(theme: ratelTheme(), home: const PronunciationResultsScreen()),
    );
    expect(find.text('Your pronunciation'), findsOneWidget);
    expect(find.text('Pronunciation'), findsOneWidget);
    expect(find.text('Intonation'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
