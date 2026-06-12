import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ratel/app_state.dart';
import 'package:ratel/comeback.dart';
import 'package:ratel/milestones.dart';
import 'package:ratel/models.dart';
import 'package:ratel/screens/lesson_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

const Exercise _c = Exercise.choice(
    prompt: 'Pick the greeting',
    options: ['Hello', 'Car', 'Run'],
    correctIndex: 0);

void main() {
  group('comeback grant logic (pure properties)', () {
    test('evening lapse risk holds for every hour and xp combination', () {
      for (int h = 0; h < 24; h++) {
        final t = DateTime(2026, 6, 11, h, 30);
        expect(isEveningLapseRisk(t, 0), h >= 18,
            reason: 'hour $h with 0 XP');
        expect(isEveningLapseRisk(t, 10), false,
            reason: 'hour $h with XP earned');
      }
    });

    test('grants only on the morning after the flagged day', () {
      final risk = dayKey(DateTime(2026, 6, 11));
      for (int h = 0; h < 24; h++) {
        final now = DateTime(2026, 6, 12, h, 15);
        expect(
            shouldGrantComeback(
                now: now, riskDay: risk, lastGrantDay: null),
            h < 12,
            reason: 'hour $h');
      }
    });

    test('never grants twice on the same day', () {
      final now = DateTime(2026, 6, 12, 8);
      expect(
          shouldGrantComeback(
              now: now,
              riskDay: dayKey(DateTime(2026, 6, 11)),
              lastGrantDay: dayKey(now)),
          false);
    });

    test('a stale flag (2+ days old) or no flag never grants', () {
      final now = DateTime(2026, 6, 12, 8);
      expect(
          shouldGrantComeback(
              now: now,
              riskDay: dayKey(DateTime(2026, 6, 10)),
              lastGrantDay: null),
          false);
      expect(
          shouldGrantComeback(now: now, riskDay: null, lastGrantDay: null),
          false);
    });

    test('boost windows expire (boostActive property)', () {
      final now = DateTime(2026, 6, 12, 9);
      for (int m = -45; m <= 45; m += 5) {
        expect(boostActive(now.add(Duration(minutes: m)), now), m > 0,
            reason: 'until now+${m}m');
      }
      expect(boostActive(null, now), false);
    });
  });

  group('boost multiplier plumbing', () {
    setUp(() {
      appState.reset();
      appState.hearts = 5;
    });

    Future<void> runLesson(WidgetTester tester) async {
      const lesson = Lesson(id: 'tcb', title: 'Boost', exercises: [_c]);
      await tester.pumpWidget(
          const MaterialApp(home: LessonScreen(lesson: lesson)));
      await tester.pump(const Duration(milliseconds: 400));
      await tester.tap(find.text('Hello'));
      await tester.pump(const Duration(milliseconds: 150));
      await tester.tap(find.text('Check'));
      await tester.pump(const Duration(milliseconds: 400));
      await tester.tap(find.text('Finish'));
      await tester.pump(const Duration(milliseconds: 900));
    }

    testWidgets('comeback window shows the 3x chip', (tester) async {
      SharedPreferences.setMockInitialValues({
        'xp_boost_until': DateTime.now()
            .add(const Duration(minutes: 20))
            .toIso8601String(),
        'xp_boost_mult': 3,
      });
      await runLesson(tester);
      expect(find.text('3x'), findsOneWidget);
    });

    testWidgets('a chest boost without the mult pref stays 2x',
        (tester) async {
      SharedPreferences.setMockInitialValues({
        'xp_boost_until': DateTime.now()
            .add(const Duration(minutes: 10))
            .toIso8601String(),
      });
      await runLesson(tester);
      expect(find.text('2x'), findsOneWidget);
    });

    testWidgets('no window means no boost chip', (tester) async {
      SharedPreferences.setMockInitialValues({});
      await runLesson(tester);
      expect(find.text('3x'), findsNothing);
      expect(find.text('2x'), findsNothing);
    });
  });
}
