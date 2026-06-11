import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ratel/app_state.dart';
import 'package:ratel/content.dart';
import 'package:ratel/achievements.dart';
import 'package:ratel/daily_quests.dart';
import 'package:ratel/models.dart';
import 'package:ratel/typed_match.dart';
import 'package:ratel/sfx.dart';
import 'package:ratel/widgets/rolling_number.dart';
import 'package:ratel/widgets/streak_flame.dart';
import 'package:ratel/widgets/aurora_background.dart';
import 'package:ratel/widgets/combo_glow.dart';
import 'package:ratel/widgets/mistakes_review.dart';
import 'package:ratel/widgets/daily_nudge.dart';

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

  test('course has ten units with forty-nine unique lesson ids', () {
    expect(course.length, 10);
    final ids = [for (final u in course) ...u.lessons.map((l) => l.id)];
    expect(ids.length, 49);
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
          } else if (ex.type == ExerciseType.wordBank) {
            // wordBank: the answer must be buildable from the given tiles.
            expect(ex.correctOrder, isNotEmpty);
            final bank = [...ex.options];
            for (final word in ex.correctOrder) {
              expect(bank.remove(word), isTrue,
                  reason: 'tile "$word" missing for "${ex.prompt}"');
            }
          } else {
            // typed: at least one non-empty accepted answer (in correctOrder).
            expect(ex.correctOrder, isNotEmpty);
            for (final a in ex.correctOrder) {
              expect(a.trim(), isNotEmpty);
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
          void need(String key) {
            if (!map.containsKey(key) ||
                (map[key] as String).trim().isEmpty) {
              missing.add(key);
            }
          }

          switch (ex.type) {
            case ExerciseType.choice:
              for (var j = 0; j < ex.options.length; j++) {
                if (j != ex.correctIndex) need('${lesson.id}:$i:$j');
              }
            case ExerciseType.wordBank:
              need('${lesson.id}:$i:wb');
            case ExerciseType.typed || ExerciseType.listen:
              need('${lesson.id}:$i:ty');
            case ExerciseType.dialogueOrder:
              need('${lesson.id}:$i:do');
            case ExerciseType.multiBlank:
              need('${lesson.id}:$i:mb');
            case ExerciseType.listenRespond:
              for (var j = 0; j < ex.options.length; j++) {
                if (j != ex.correctIndex) need('${lesson.id}:$i:$j');
              }
            case ExerciseType.matchPairs:
              break; // match boards never show a wrong banner
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

  test('achievements unlock at their thresholds', () {
    final s = AppState();
    expect(isEarned(achievements.first, s), isFalse); // 0 lessons
    s.completeLesson('u1l1', 100); // 1 lesson, 100 xp
    expect(isEarned(achievements.firstWhere((a) => a.title == 'First steps'), s),
        isTrue);
    expect(isEarned(achievements.firstWhere((a) => a.title == 'Centurion'), s),
        isTrue);
    expect(isEarned(achievements.firstWhere((a) => a.title == 'XP hunter'), s),
        isFalse);
  });

  testWidgets('DailyNudge warns of streak risk and hides when goal met',
      (tester) async {
    appState.streak = 3;
    appState.todayXp = 0;
    appState.dailyGoalXp = 50;
    await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: DailyNudge())));
    expect(find.textContaining('streak alive'), findsOneWidget);
    appState.todayXp = 100; // goal met -> nudge hides
    await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: DailyNudge())));
    expect(find.textContaining('streak alive'), findsNothing);
    appState.reset();
  });

  test('daily quests: two quests, stable within a day, completion detected', () {
    final a = questsForToday();
    final b = questsForToday();
    expect(a.length, 2);
    expect(a[0].target, b[0].target); // stable within the same day
    expect(a[1].target, b[1].target);
    final full = AppState()
      ..todayXp = 999
      ..lessonsToday = 99;
    expect(a.every((q) => questDone(q, full)), isTrue);
    expect(a.any((q) => questDone(q, AppState())), isFalse);
  });

  test('typedAnswerMatches is case/punctuation/article tolerant', () {
    expect(typedAnswerMatches('water', ['water']), isTrue);
    expect(typedAnswerMatches('  WATER ', ['water']), isTrue);
    expect(typedAnswerMatches('Water.', ['water']), isTrue);
    expect(typedAnswerMatches('the shop', ['shop', 'store']), isTrue);
    expect(typedAnswerMatches('a bus', ['bus']), isTrue);
    expect(typedAnswerMatches('store', ['shop', 'store', 'market']), isTrue);
    expect(typedAnswerMatches('train', ['bus']), isFalse);
    expect(typedAnswerMatches('', ['bus']), isFalse);
    expect(typedAnswerMatches('   ', ['bus']), isFalse);
  });

  test('typed exercise stores accepted answers in correctOrder', () {
    const ex = Exercise.typed(prompt: 'Type it', accepted: ['go', 'start']);
    expect(ex.type, ExerciseType.typed);
    expect(ex.correctOrder, ['go', 'start']);
    expect(ex.options, isEmpty);
  });

  test('markOnboarded keeps the friend code (regression: it used to blank it)', () async {
    final s = AppState();
    s.friendCode = 'EDAB7F';
    await s.markOnboarded();
    expect(s.onboarded, isTrue);
    expect(s.friendCode, 'EDAB7F'); // must survive onboarding
  });

  test('listen exercise is graded like typed (accepted in correctOrder)', () {
    const ex = Exercise.listen(prompt: 'Type what you hear', accepted: ['Hello']);
    expect(ex.type, ExerciseType.listen);
    expect(ex.correctOrder, ['Hello']);
    expect(ex.options, isEmpty);
    expect(typedAnswerMatches('hello', ex.correctOrder), isTrue);
    expect(typedAnswerMatches('yellow', ex.correctOrder), isFalse);
  });
}
