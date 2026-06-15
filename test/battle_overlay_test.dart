import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ratel/app_state.dart';
import 'package:ratel/models.dart';
import 'package:ratel/theme.dart';
import 'package:ratel/widgets/battle_stage.dart';
import 'package:ratel/screens/lesson_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Phase 2.6 — the battle/villain HUD must be a PURE OVERLAY: it may decorate
// the page but must NEVER block, gate, or change the answering task. These
// tests lock that contract so a future change can't quietly make the game
// compete with learning (Exercise-Page-Spec section 5.1).

const _l1 = Lesson(id: 'bt1', title: 'Battle overlay', exercises: [
  Exercise.choice(prompt: 'Pick A', options: ['A', 'B'], correctIndex: 0),
]);

Future<void> _open(WidgetTester t) async {
  await t.pumpWidget(const MaterialApp(home: LessonScreen(lesson: _l1)));
  await t.pump(const Duration(milliseconds: 400));
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    appState.reset();
    appState.hearts = 5;
    reduceMotionNotifier.value = true; // freeze battle sway in tests
  });
  tearDown(() {
    reduceMotionNotifier.value = false;
    battleModeNotifier.value = true; // restore default
    appState.hearts = 5;
  });

  testWidgets('battle ON: HUD renders but the lesson still completes',
      (tester) async {
    battleModeNotifier.value = true;
    await _open(tester);
    expect(find.byType(BattleStage), findsOneWidget); // overlay present
    await tester.tap(find.text('A').first); // task fully interactive
    await tester.pump(const Duration(milliseconds: 150));
    await tester.tap(find.text('Check'));
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.text('Finish'), findsOneWidget); // never gated by the battle
    await tester.pump(const Duration(seconds: 1));
  });

  testWidgets('battle ON: a wrong answer is still graded (heart deducts)',
      (tester) async {
    battleModeNotifier.value = true;
    await _open(tester);
    await tester.tap(find.text('B').first); // wrong
    await tester.pump(const Duration(milliseconds: 150));
    await tester.tap(find.text('Check'));
    await tester.pump(const Duration(milliseconds: 400));
    expect(appState.hearts, 4); // graded THROUGH the overlay, not shielded
    expect(find.byType(BattleStage), findsOneWidget);
    await tester.pump(const Duration(seconds: 1));
  });

  testWidgets('battle OFF: mascot shown (no BattleStage), answering still works',
      (tester) async {
    battleModeNotifier.value = false;
    await _open(tester);
    expect(find.byType(BattleStage), findsNothing); // toggled off, no HUD
    await tester.tap(find.text('B').first); // wrong
    await tester.pump(const Duration(milliseconds: 150));
    await tester.tap(find.text('Check'));
    await tester.pump(const Duration(milliseconds: 400));
    expect(appState.hearts, 4); // grades the same regardless of the toggle
    await tester.pump(const Duration(seconds: 1));
  });
}
