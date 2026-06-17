import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ratel/core/theme/theme.dart';
import 'package:ratel/features/profile/screens/english_score_screen.dart';

void main() {
  testWidgets('english score renders sub-skills with no overflow',
      (tester) async {
    tester.view.physicalSize = const Size(360, 820);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      MaterialApp(theme: ratelTheme(), home: const EnglishScoreScreen()),
    );
    expect(find.text('95'), findsOneWidget);
    expect(find.text('B1 · Independent'), findsOneWidget);
    expect(find.text('Reading'), findsOneWidget);
    expect(find.text('Share score card'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
