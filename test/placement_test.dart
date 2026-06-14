import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ratel/app_state.dart';
import 'package:ratel/models.dart';
import 'package:ratel/placement.dart';
import 'package:ratel/screens/placement_screen.dart';

void main() {
  test('unitsToSkipFor thresholds', () {
    expect(unitsToSkipFor(0, 8), 0);
    expect(unitsToSkipFor(2, 8), 0);
    expect(unitsToSkipFor(3, 8), 1);
    expect(unitsToSkipFor(5, 8), 2);
    expect(unitsToSkipFor(7, 8), 3);
    expect(unitsToSkipFor(8, 8), 3);
    expect(unitsToSkipFor(5, 0), 0);
  });

  test('placement probes come from the course and are all choice-type', () {
    final probes = buildPlacementProbes();
    expect(probes.length, greaterThanOrEqualTo(6));
    for (final p in probes) {
      expect(p.exercise.type, ExerciseType.choice);
      expect(placementLessonIds, contains(p.lessonId));
    }
  });

  test('lessonIdsForUnits covers exactly the leading units', () {
    final two = lessonIdsForUnits(2);
    expect(two, contains('u1l1'));
    expect(two, contains('u2l5'));
    expect(two, isNot(contains('u3l1')));
  });

  test('skipAhead marks complete without XP/streak side effects', () async {
    final state = AppState();
    await state.skipAhead(['u1l1', 'u1l2']);
    expect(state.isCompleted('u1l1'), isTrue);
    expect(state.isCompleted('u1l2'), isTrue);
    expect(state.xp, 0);
    expect(state.lessonsToday, 0);
  });

  testWidgets('placement screen: answer one probe', (tester) async {
    const probe = PlacementProbe(
        'u2l1',
        Exercise.choice(
            prompt: 'Pick the fruit',
            options: ['Apple', 'Chair'],
            correctIndex: 0));
    await tester.pumpWidget(const MaterialApp(
        home: PlacementScreen(goal: 20, probes: [probe, probe])));
    expect(find.text('Pick the fruit'), findsOneWidget);
    await tester.tap(find.text('Apple'));
    await tester.pump();
    await tester.tap(find.text('Check'));
    await tester.pump();
    expect(find.text('Continue'), findsOneWidget);
    await tester.tap(find.text('Continue'));
    await tester.pump();
    expect(find.text('Pick the fruit'), findsOneWidget); // probe 2 of 2
  });

  testWidgets('placement quiz lays out at 360px (custom header, no RatelScaffold)',
      (tester) async {
    const probe = PlacementProbe(
        'u2l1',
        Exercise.choice(
            prompt: 'Pick the fruit',
            options: ['Apple', 'Chair'],
            correctIndex: 0));
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(const MaterialApp(
        home: PlacementScreen(goal: 20, probes: [probe, probe])));
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.byType(LinearProgressIndicator), findsOneWidget); // custom header
    expect(find.byTooltip('Close'), findsOneWidget); // a11y: labelled close
    expect(find.text('Pick the fruit'), findsOneWidget);
    expect(tester.takeException(), isNull); // RenderFlex overflow -> failure
  });
}
