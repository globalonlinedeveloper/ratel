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

  testWidgets('the answered banner offers a report sheet', (tester) async {
    await tester.pumpWidget(MaterialApp(
        home: LessonScreen(lesson: builtInCourse.first.lessons.first)));
    await tester.pump(const Duration(milliseconds: 400));
    await tester.tap(find.text('Hello').first);
    await tester.pump(const Duration(milliseconds: 150));
    await tester.tap(find.text('Check'));
    await tester.pump(const Duration(milliseconds: 400));
    await tester.tap(find.byIcon(Icons.flag_outlined));
    await tester.pump(); // sheet route in
    await tester.pump(const Duration(milliseconds: 450)); // slide up
    expect(find.text('Report this exercise'), findsOneWidget);
    await tester.tap(find.text('Typo or unnatural English'));
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.textContaining('Thanks!'), findsOneWidget);
    await tester.pump(const Duration(seconds: 5)); // drain snackbar
    appState.hearts = 5;
  });
}
