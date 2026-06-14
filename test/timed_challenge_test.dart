import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ratel/app_state.dart';
import 'package:ratel/milestones.dart';
import 'package:ratel/models.dart';
import 'package:ratel/placement.dart';
import 'package:ratel/screens/timed_challenge_screen.dart';
import 'package:ratel/widgets/ratel_scaffold.dart';
import 'package:shared_preferences/shared_preferences.dart';

const Exercise _q = Exercise.choice(
    prompt: 'Pick the greeting',
    options: ['Hello', 'Apple'],
    correctIndex: 0);

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    appState.reset();
    appState.hearts = 5;
  });

  test('timedGems pays 1 per 5 correct; timedPool is choice-only', () {
    expect(timedGems(0), 0);
    expect(timedGems(4), 0);
    expect(timedGems(5), 1);
    expect(timedGems(14), 2);
    final pool = timedPool();
    expect(pool.isNotEmpty, isTrue);
    for (final e in pool.take(20)) {
      expect(e.type, ExerciseType.choice);
    }
  });

  testWidgets('a run scores, pays gems, keeps the best, costs no hearts',
      (tester) async {
    await tester.pumpWidget(const MaterialApp(
        home: TimedChallengeScreen(
            pool: [_q], duration: Duration(seconds: 3))));
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('Beat the clock!'), findsOneWidget);
    await tester.tap(find.text('Start'));
    await tester.pump(const Duration(milliseconds: 100));
    // answer 5 correct fast (same question loops in the test pool)
    for (int n = 0; n < 5; n++) {
      await tester.tap(find.text('Hello'));
      await tester.pump(const Duration(milliseconds: 50));
    }
    // let the 3s clock run out
    await tester.pump(const Duration(seconds: 4));
    expect(find.text('Nice run!'), findsOneWidget);
    expect(find.textContaining('Score 50'), findsOneWidget);
    expect(appState.gems, 1); // 5 correct -> +1 gem
    expect(appState.hearts, 5); // never at risk
    final p = await SharedPreferences.getInstance();
    expect(p.getInt('timed_best'), 50);
    await tester.pump(const Duration(seconds: 1));
  });

  testWidgets('the +15s boost spends gems and arms', (tester) async {
    appState.addGems(60);
    await tester.pumpWidget(const MaterialApp(
        home: TimedChallengeScreen(
            pool: [_q], duration: Duration(seconds: 3))));
    await tester.pump(const Duration(milliseconds: 300));
    await tester.tap(find.textContaining('Start with +15s'));
    await tester.pump(const Duration(milliseconds: 300));
    expect(appState.gems, 10); // 60 - 50
    expect(find.text('+15s boost armed!'), findsOneWidget);
    await tester.tap(find.text('Start'));
    await tester.pump(const Duration(milliseconds: 200));
    expect(find.text('18s'), findsOneWidget); // 3 + 15 boosted
    // drain the long boosted clock so no timers leak
    await tester.pump(const Duration(seconds: 19));
    expect(find.text('Nice run!'), findsOneWidget);
    await tester.pump(const Duration(seconds: 1));
  });

  testWidgets('gate renders inside RatelScaffold and lays out at 360px',
      (tester) async {
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(const MaterialApp(
        home: TimedChallengeScreen(
            pool: [_q], duration: Duration(seconds: 3))));
    // SkeletonBox/RatelMascot loop forever -> pumpAndSettle would hang; advance
    // a fixed slice instead (session-craft gotcha).
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.byType(RatelScaffold), findsOneWidget);
    expect(find.text('Timed challenge'), findsOneWidget); // themed header title
    expect(find.text('Beat the clock!'), findsOneWidget);
    expect(find.text('Start'), findsOneWidget);
    expect(tester.takeException(), isNull); // RenderFlex overflow -> failure
  });
}
