import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ratel/app_state.dart';
import 'package:ratel/content.dart';
import 'package:ratel/screens/lesson_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    appState.reset();
    appState.hearts = 5;
  });

  testWidgets('the why card is offered on a CORRECT answer too (Phase 2.4)',
      (tester) async {
    await tester.pumpWidget(MaterialApp(
        home: LessonScreen(lesson: builtInCourse.first.lessons.first)));
    await tester.pump(const Duration(milliseconds: 400));
    await tester.tap(find.text('Hello').first);
    await tester.pump(const Duration(milliseconds: 150));
    await tester.tap(find.text('Check'));
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.text('Continue'), findsOneWidget); // answered correctly
    // Previously the why card only appeared on a wrong answer; now every item.
    expect(find.text('Explain this'), findsOneWidget);
    await tester.pump(const Duration(seconds: 1));
    appState.hearts = 5;
  });
}
