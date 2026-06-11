import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ratel/app_state.dart';
import 'package:ratel/content.dart';
import 'package:ratel/milestones.dart';
import 'package:ratel/screens/home_screen.dart';
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

  test('canDoFor covers every band', () {
    expect(canDoFor('A1'), contains('introduce yourself'));
    expect(canDoFor('A2'), contains('routine'));
    expect(canDoFor('B1'), contains('familiar topics'));
    expect(canDoFor('B2'), contains('confident'));
  });

  testWidgets('the Profile score card explains what the band means',
      (tester) async {
    await tester.pumpWidget(const MaterialApp(home: HomeScreen()));
    await tester.pump(const Duration(milliseconds: 600));
    await tester.tap(find.text('Profile'));
    await tester.pump(const Duration(milliseconds: 600));
    expect(find.textContaining('Can introduce yourself'), findsOneWidget);
    await tester.pump(const Duration(seconds: 1));
  });

  testWidgets('a first-time completion grows the score chip',
      (tester) async {
    await tester.pumpWidget(MaterialApp(
        home: LessonScreen(lesson: builtInCourse.first.lessons.first)));
    await tester.pump(const Duration(milliseconds: 400));
    await _answer(tester, 'Hello');
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
    await _answer(tester, 'meet');
    await _go(tester, 'Finish');
    await tester.pump(const Duration(milliseconds: 700));
    expect(find.text('SCORE'), findsOneWidget);
    expect(find.text('0 → 1'), findsOneWidget);
    await tester.pump(const Duration(seconds: 1));
  });
}
