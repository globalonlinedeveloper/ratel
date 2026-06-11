import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ratel/app_state.dart';
import 'package:ratel/content.dart';
import 'package:ratel/milestones.dart';
import 'package:ratel/screens/lesson_screen.dart';
import 'package:ratel/widgets/perfect_week.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> _answer(WidgetTester t, String option) async {
  await t.tap(find.text(option).first);
  await t.pump(const Duration(milliseconds: 150));
  await t.tap(find.text('Check'));
  await t.pump(const Duration(milliseconds: 400));
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    appState.reset();
    appState.hearts = 5;
  });

  test('boostActive / weekKey / perfectWeek', () {
    final now = DateTime(2026, 6, 11, 12);
    expect(boostActive(now.add(const Duration(minutes: 1)), now), true);
    expect(boostActive(now.subtract(const Duration(minutes: 1)), now),
        false);
    expect(boostActive(null, now), false);
    expect(weekKey(DateTime(2026, 6, 11)), weekKey(DateTime(2026, 6, 8)));
    expect(weekKey(DateTime(2026, 6, 11)),
        isNot(weekKey(DateTime(2026, 6, 15))));
    expect(perfectWeek([20, 20, 20, 20, 20, 20, 20], 20), true);
    expect(perfectWeek([20, 20, 0, 20, 20, 20, 20], 20), false);
    expect(perfectWeek([20, 20, 20], 20), false);
    expect(perfectWeek([20, 20, 20, 20, 20, 20, 20], 0), false);
  });

  test('grantWeeklyFreeze respects the cap', () async {
    appState.streakFreezes = 1;
    expect(await appState.grantWeeklyFreeze(), true);
    expect(appState.streakFreezes, 2);
    expect(await appState.grantWeeklyFreeze(), false);
  });

  testWidgets('an active boost doubles completion XP', (tester) async {
    SharedPreferences.setMockInitialValues({
      'xp_boost_until': DateTime.now()
          .add(const Duration(minutes: 10))
          .toIso8601String(),
    });
    await tester.pumpWidget(MaterialApp(
        home: LessonScreen(lesson: builtInCourse.first.lessons.first)));
    await tester.pump(const Duration(milliseconds: 400));
    await _answer(tester, 'Hello');
    await tester.tap(find.text('Continue'));
    await tester.pump(const Duration(milliseconds: 400));
    await _answer(tester, 'How');
    await tester.tap(find.text('Continue'));
    await tester.pump(const Duration(milliseconds: 400));
    await tester.tap(find.text('Good').first);
    await tester.pump(const Duration(milliseconds: 150));
    await tester.tap(find.text('morning').first);
    await tester.pump(const Duration(milliseconds: 150));
    await tester.tap(find.text('Check'));
    await tester.pump(const Duration(milliseconds: 400));
    await tester.tap(find.text('Continue'));
    await tester.pump(const Duration(milliseconds: 400));
    await _answer(tester, "I'm fine, thanks");
    await tester.tap(find.text('Continue'));
    await tester.pump(const Duration(milliseconds: 400));
    await _answer(tester, 'meet');
    await tester.tap(find.text('Finish'));
    await tester.pump(const Duration(milliseconds: 700));
    expect(find.text('BOOST'), findsOneWidget);
    // the random surprise bonus makes the exact text flaky; assert
    // the DOUBLING property instead: undoubled max = 70 XP
    // (50 + bonus<=20), doubled min = 100 - disjoint ranges.
    expect(appState.xp >= 100, isTrue,
        reason: 'xp=${appState.xp} not doubled');
    await tester.pump(const Duration(seconds: 1));
  });

  testWidgets('Perfect Week card pays once', (tester) async {
    appState.dailyGoalXp = 20;
    await tester.pumpWidget(const MaterialApp(
        home: Scaffold(
            body: PerfectWeekCard(
                dailyXp: [20, 25, 30, 20, 20, 50, 20]))));
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.textContaining('PERFECT WEEK'), findsOneWidget);
    await tester.tap(find.text('+20 gems'));
    await tester.pump(const Duration(milliseconds: 300));
    expect(appState.gems, 20);
    expect(find.textContaining('claimed'), findsOneWidget);
    // a fresh build the same week stays hidden
    await tester.pumpWidget(const MaterialApp(
        home: Scaffold(
            body: Padding(
                padding: EdgeInsets.all(1),
                child: PerfectWeekCard(
                    dailyXp: [20, 25, 30, 20, 20, 50, 20])))));
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.textContaining('PERFECT WEEK'), findsNothing);
    expect(appState.gems, 20);
  });
}
