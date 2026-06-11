import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ratel/app_state.dart';
import 'package:ratel/content.dart';
import 'package:ratel/milestones.dart';
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

  test('comboGemBonus pays on every 5th correct in a row', () {
    expect(comboGemBonus(5), 1);
    expect(comboGemBonus(10), 1);
    expect(comboGemBonus(4), 0);
    expect(comboGemBonus(0), 0);
  });

  test('addGems / spendGems guard the balance', () {
    appState.addGems(10);
    expect(appState.gems, 10);
    expect(appState.spendGems(350), false);
    expect(appState.gems, 10);
    expect(appState.spendGems(10), true);
    expect(appState.gems, 0);
  });

  testWidgets('a flawless lesson pays combo + perfect gems', (tester) async {
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
    await tester.pump(const Duration(milliseconds: 600));
    expect(find.text('GEMS'), findsOneWidget);
    expect(find.text('+6'), findsOneWidget); // combo x5 (+1) + flawless (+5)
    expect(appState.gems, 6);
    await tester.pump(const Duration(seconds: 1));
  });

  testWidgets('an imperfect lesson pays no flawless bonus', (tester) async {
    await tester.pumpWidget(MaterialApp(
        home: LessonScreen(lesson: builtInCourse.first.lessons.first)));
    await tester.pump(const Duration(milliseconds: 400));
    await _answer(tester, 'Apple'); // wrong on purpose
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
    await _go(tester, 'Continue'); // into the fix phase
    await tester.pump(const Duration(milliseconds: 2400));
    await tester.pump(const Duration(milliseconds: 350));
    await _answer(tester, 'Hello');
    await _go(tester, 'Finish');
    await tester.pump(const Duration(milliseconds: 600));
    expect(find.text('GEMS'), findsNothing); // 4-combo max, no flawless
    expect(appState.gems, 0);
    await tester.pump(const Duration(seconds: 1));
    appState.hearts = 5;
  });
}
