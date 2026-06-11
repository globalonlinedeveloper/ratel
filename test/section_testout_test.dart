import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ratel/app_state.dart';
import 'package:ratel/milestones.dart';
import 'package:ratel/placement.dart';
import 'package:ratel/screens/home_screen.dart';
import 'package:ratel/screens/section_test_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    appState.reset();
    appState.hearts = 5;
  });

  test('sectionProbes samples choice items from the skipped units only', () {
    final probes = sectionProbes(3);
    expect(probes.length, 8);
    for (final p in probes) {
      expect(p.lessonId.startsWith('u1') || p.lessonId.startsWith('u2') ||
          p.lessonId.startsWith('u3'), isTrue,
          reason: p.lessonId);
      expect(p.exercise.options.isNotEmpty, isTrue);
    }
    expect(sectionProbes(0), isEmpty);
  });

  test('sectionTestPassed needs 85%', () {
    expect(sectionTestPassed(7, 8), true);
    expect(sectionTestPassed(6, 8), false);
    expect(sectionTestPassed(0, 0), false);
  });

  testWidgets('acing the test-out unlocks the section via skipAhead',
      (tester) async {
    const s = CourseSection(
        title: 'Daily life', cefr: 'A2', firstUnit: 3, lastUnit: 5);
    await tester.pumpWidget(
        const MaterialApp(home: SectionTestScreen(section: s)));
    await tester.pump(const Duration(milliseconds: 300));
    final probes = sectionProbes(3);
    for (int i = 0; i < probes.length; i++) {
      final right = probes[i]
          .exercise.options[probes[i].exercise.correctIndex];
      await tester.tap(find.text(right).first);
      await tester.pump(const Duration(milliseconds: 100));
      await tester
          .tap(find.text(i + 1 < probes.length ? 'Next' : 'See result'));
      await tester.pump(const Duration(milliseconds: 250));
    }
    expect(find.text('You jumped ahead!'), findsOneWidget);
    expect(appState.isCompleted('u1l1'), isTrue); // units 1-3 marked done
    expect(appState.isCompleted('u3l5'), isTrue);
    expect(appState.xp, 0); // skipAhead is side-effect free
  });

  testWidgets('a locked section banner offers Test out', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: HomeScreen()));
    await tester.pump(const Duration(milliseconds: 600));
    // fresh account: A2 and B1 are locked -> two Test out buttons
    expect(find.text('Test out'), findsNWidgets(2));
    await tester.pump(const Duration(seconds: 1));
  });
}
