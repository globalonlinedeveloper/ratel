import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ratel/app_state.dart';
import 'package:ratel/content.dart';
import 'package:ratel/models.dart';
import 'package:ratel/sfx.dart';
import 'package:ratel/widgets/rolling_number.dart';
import 'package:ratel/widgets/streak_flame.dart';
import 'package:ratel/widgets/aurora_background.dart';
import 'package:ratel/widgets/combo_glow.dart';
import 'package:ratel/widgets/mistakes_review.dart';

void main() {
  test('combo ladder rises then caps, resets on wrong', () {
    final c = ComboCounter();
    expect(c.onCorrect(), 0);
    expect(c.onCorrect(), 1);
    expect(c.onCorrect(), 2);
    expect(c.onCorrect(), 3);
    expect(c.onCorrect(), 4);
    expect(c.onCorrect(), 4);
    c.onWrong();
    expect(c.value, 0);
    expect(c.onCorrect(), 0);
  });

  test('completeLesson adds XP and marks the lesson complete', () {
    final state = AppState();
    expect(state.xp, 0);
    expect(state.isCompleted('u1l1'), isFalse);

    state.completeLesson('u1l1', 40);

    expect(state.xp, 40);
    expect(state.isCompleted('u1l1'), isTrue);
    expect(state.completedCount, 1);
  });

  test('reset clears all progress', () {
    final state = AppState();
    state.completeLesson('u1l1', 40);
    state.reset();

    expect(state.xp, 0);
    expect(state.isCompleted('u1l1'), isFalse);
    expect(state.completedCount, 0);
  });

  test('course has four units with twenty unique lesson ids', () {
    expect(course.length, 4);
    final ids = [for (final u in course) ...u.lessons.map((l) => l.id)];
    expect(ids.length, 20);
    expect(ids.toSet().length, ids.length); // no duplicate ids
  });

  test('every exercise is well-formed', () {
    for (final unit in course) {
      for (final lesson in unit.lessons) {
        expect(lesson.exercises, isNotEmpty);
        for (final ex in lesson.exercises) {
          if (ex.type == ExerciseType.choice) {
            expect(ex.options.length, greaterThanOrEqualTo(2));
            expect(ex.correctIndex, inInclusiveRange(0, ex.options.length - 1));
          } else {
            // wordBank: the answer must be buildable from the given tiles.
            expect(ex.correctOrder, isNotEmpty);
            final bank = [...ex.options];
            for (final word in ex.correctOrder) {
              expect(bank.remove(word), isTrue,
                  reason: 'tile "$word" missing for "${ex.prompt}"');
            }
          }
        }
      }
    }
  });

  testWidgets('RollingNumber settles on its target value', (tester) async {
    await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: RollingNumber(42))));
    await tester.pumpAndSettle();
    expect(find.text('42'), findsOneWidget);
  });

  testWidgets('RollingNumber applies prefix and suffix', (tester) async {
    await tester.pumpWidget(const MaterialApp(
        home: Scaffold(body: RollingNumber(7, prefix: '+', suffix: ' XP'))));
    await tester.pumpAndSettle();
    expect(find.text('+7 XP'), findsOneWidget);
  });

  testWidgets('StreakFlame builds and animates without error', (tester) async {
    await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: StreakFlame(streak: 5))));
    // The flame repeats forever, so step time manually (never pumpAndSettle).
    await tester.pump(const Duration(milliseconds: 120));
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.byType(StreakFlame), findsOneWidget);
    expect(find.byType(CustomPaint), findsWidgets);
  });

  testWidgets('StreakFlame handles a zero streak (dim ember)', (tester) async {
    await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: StreakFlame(streak: 0))));
    await tester.pump(const Duration(milliseconds: 120));
    expect(find.byType(StreakFlame), findsOneWidget);
  });

  testWidgets('AuroraBackground renders its child without error', (tester) async {
    await tester.pumpWidget(const MaterialApp(
        home: AuroraBackground(child: Text('hi', textDirection: TextDirection.ltr))));
    // Infinite drift controller -> step time manually, never pumpAndSettle.
    await tester.pump(const Duration(milliseconds: 120));
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.text('hi'), findsOneWidget);
    expect(find.byType(CustomPaint), findsWidgets);
  });

  testWidgets('ComboGlow builds at low and high combo', (tester) async {
    await tester.pumpWidget(const MaterialApp(
        home: Scaffold(body: ComboGlow(combo: 0))));
    await tester.pumpAndSettle();
    expect(find.byType(ComboGlow), findsOneWidget);
    await tester.pumpWidget(const MaterialApp(
        home: Scaffold(body: ComboGlow(combo: 5))));
    await tester.pumpAndSettle();
    expect(find.byType(CustomPaint), findsWidgets);
  });

  test('every fixed wrong-answer has a pre-authored explanation (no API at runtime)', () {
    final f = File('assets/explanations.json');
    expect(f.existsSync(), isTrue, reason: 'assets/explanations.json missing');
    final map = json.decode(f.readAsStringSync()) as Map<String, dynamic>;
    final missing = <String>[];
    for (final unit in course) {
      for (final lesson in unit.lessons) {
        for (var i = 0; i < lesson.exercises.length; i++) {
          final ex = lesson.exercises[i];
          if (ex.type == ExerciseType.choice) {
            for (var j = 0; j < ex.options.length; j++) {
              if (j == ex.correctIndex) continue;
              final key = '${lesson.id}:$i:$j';
              if (!map.containsKey(key) ||
                  (map[key] as String).trim().isEmpty) {
                missing.add(key);
              }
            }
          } else {
            final key = '${lesson.id}:$i:wb';
            if (!map.containsKey(key) ||
                (map[key] as String).trim().isEmpty) {
              missing.add(key);
            }
          }
        }
      }
    }
    expect(missing, isEmpty,
        reason: 'Missing explanations for $missing — run tool/gen_explanations.py');
  });

  testWidgets('MistakesReview renders safely when signed out', (tester) async {
    await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: MistakesReview())));
    await tester.pump();
    expect(find.byType(MistakesReview), findsOneWidget);
  });

  test('exerciseForKey resolves content keys and rejects bad ones', () {
    final ex = exerciseForKey('u1l1:0');
    expect(ex, isNotNull);
    expect(ex!.prompt, course[0].lessons[0].exercises[0].prompt);
    expect(exerciseForKey('u1l1:999'), isNull);
    expect(exerciseForKey('nope:0'), isNull);
    expect(exerciseForKey('garbage'), isNull);
  });

  test('lessonTitleForId resolves titles and rejects unknown ids', () {
    expect(lessonTitleForId('u1l1'), course[0].lessons[0].title);
    expect(lessonTitleForId('nope'), isNull);
  });
}
