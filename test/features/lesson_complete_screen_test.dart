import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ratel/core/theme/theme.dart';
import 'package:ratel/features/learn/screens/lesson_complete_screen.dart';

void main() {
  testWidgets('lesson complete renders stats at 360px with no overflow',
      (tester) async {
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      MaterialApp(theme: ratelTheme(), home: const LessonCompleteScreen()),
    );
    expect(find.text('Lesson complete!'), findsOneWidget);
    expect(find.text('+18'), findsOneWidget);
    expect(find.text('AI debrief'), findsOneWidget);
    expect(find.text('Share'), findsOneWidget);
    expect(find.text('Continue'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
