import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ratel/milestones.dart';
import 'package:ratel/screens/report_queue_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('groupReports tallies, dedupes reasons, sorts by count', () {
    final g = groupReports([
      {'lesson_id': 'u1l2', 'exercise_index': 5, 'reason': 'Typo'},
      {'lesson_id': 'u1l2', 'exercise_index': 5, 'reason': 'Typo'},
      {'lesson_id': 'u1l2', 'exercise_index': 5, 'reason': 'Audio problem'},
      {'lesson_id': 'u2l1', 'exercise_index': 0, 'reason': 'Typo'},
    ]);
    expect(g.length, 2);
    expect(g.first.key, 'u1l2:5'); // most reported first
    expect(g.first.count, 3);
    expect(g.first.reasons, 'Typo · Audio problem');
    expect(g.last.count, 1);
  });

  testWidgets('the queue lists groups with prompts and resolves',
      (tester) async {
    await tester.pumpWidget(const MaterialApp(
        home: ReportQueueScreen(rowsOverride: [
      {'lesson_id': 'u1l1', 'exercise_index': 0, 'reason': 'Typo'},
      {'lesson_id': 'u1l1', 'exercise_index': 0, 'reason': 'Something is wrong here'},
    ])));
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.textContaining('u1l1:0 · 2 reports'), findsOneWidget);
    expect(find.text('Which word is a greeting?'), findsOneWidget);
    await tester.tap(find.text('Resolve'));
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.textContaining('No open reports'), findsOneWidget);
  });
}
