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
  setUp(() => SharedPreferences.setMockInitialValues({}));

  testWidgets('a missed exercise replays at the end and costs no heart twice',
      (tester) async {
    appState.hearts = 5;
    await tester.pumpWidget(MaterialApp(
        home: LessonScreen(lesson: builtInCourse.first.lessons.first)));
    await tester.pump(const Duration(milliseconds: 400));

    // Q1 WRONG on purpose (correct is 'Hello')
    await _answer(tester, 'Apple');
    expect(appState.hearts, 4); // first-pass miss costs one heart
    await _go(tester, 'Continue');
    // Q2..Q5 correct
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
    await _answer(tester, 'meet');
    // NOT the finish: the missed Q1 replays now
    await _go(tester, 'Continue');
    expect(find.text('FIXING MISTAKES'), findsOneWidget);
    expect(find.text('6/6'), findsOneWidget); // playlist grew by the miss
    // missing AGAIN in fix phase costs no heart
    await _answer(tester, 'Chair');
    expect(appState.hearts, 4);
    await _go(tester, 'Continue');
    // it re-queued once more — answer it right to finish
    await _answer(tester, 'Hello');
    await _go(tester, 'Finish');
    await tester.pump(const Duration(milliseconds: 600));
    expect(find.textContaining('4 / 5 correct'), findsOneWidget);
    expect(find.text('GOOD'), findsOneWidget); // 80% accuracy tier
    expect(find.text('TOTAL'), findsOneWidget);
    await tester.pump(const Duration(seconds: 1));
    appState.hearts = 5;
  });
}
