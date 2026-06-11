import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ratel/app_state.dart';
import 'package:ratel/content.dart';
import 'package:ratel/screens/lesson_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> _answer(WidgetTester t, String option) async {
  await t.tap(find.text(option).first);
  await t.pump(const Duration(milliseconds: 150));
  await t.tap(find.text('Check'));
  await t.pump(const Duration(milliseconds: 400));
}

Future<void> _go(WidgetTester t, String btn) async {
  await t.tap(find.text(btn));
  await t.pump(const Duration(milliseconds: 400));
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    appState.reset();
    appState.hearts = 5;
  });

  testWidgets('the 5th correct in a row flashes the +1 gem chip',
      (tester) async {
    await tester.pumpWidget(MaterialApp(
        home: LessonScreen(lesson: builtInCourse.first.lessons.first)));
    await tester.pump(const Duration(milliseconds: 400));
    await _answer(tester, 'Hello');
    expect(find.text('+1'), findsNothing); // combo 1: no flash
    await _go(tester, 'Continue');
    await _answer(tester, 'How');
    await _go(tester, 'Continue');
    await tester.tap(find.text('Good').first);
    await tester.pump(const Duration(milliseconds: 150));
    await tester.tap(find.text('morning').first);
    await tester.pump(const Duration(milliseconds: 150));
    await _go(tester, 'Check');
    await _go(tester, 'Continue');
    await _answer(tester, "I'm fine, thanks");
    await _go(tester, 'Continue');
    await _answer(tester, 'meet'); // combo 5 - the gem pays here
    expect(find.text('+1'), findsOneWidget);
    await _go(tester, 'Finish');
    await tester.pump(const Duration(milliseconds: 700));
    expect(find.text('GEMS'), findsOneWidget); // stagger still lands
    await tester.pump(const Duration(seconds: 1));
  });
}
