import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ratel/app_state.dart';
import 'package:ratel/exercise_kit.dart';
import 'package:ratel/models.dart';
import 'package:ratel/screens/lesson_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

const Exercise _mp = Exercise.matchPairs(
    prompt: 'Match the pairs',
    left: ['dog', 'big', 'happy'],
    right: ['puppy', 'large', 'glad']);

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    appState.reset();
    appState.hearts = 5;
  });

  test('kit handles matchPairs', () {
    expect(canCheckAnswer(_mp, pickedCount: 2), false);
    expect(canCheckAnswer(_mp, pickedCount: 3), true);
    expect(gradeAnswer(_mp), true);
    expect(correctTextFor(_mp), 'dog — puppy, big — large, happy — glad');
    expect(explainSuffixFor(_mp), 'mp');
  });

  testWidgets('match board locks pairs, forgives misses, self-completes',
      (tester) async {
    const lesson = Lesson(id: 'tm1', title: 'Match', exercises: [_mp]);
    await tester.pumpWidget(
        const MaterialApp(home: LessonScreen(lesson: lesson)));
    await tester.pump(const Duration(milliseconds: 400));
    // a mismatch is cosmetic: select 'dog', tap 'large' -> nothing locks
    await tester.tap(find.text('dog'));
    await tester.pump(const Duration(milliseconds: 100));
    await tester.tap(find.text('large'));
    await tester.pump(const Duration(milliseconds: 100));
    expect(appState.hearts, 5);
    expect(find.text('Correct!'), findsNothing);
    // now match all three
    await tester.tap(find.text('dog'));
    await tester.pump(const Duration(milliseconds: 100));
    await tester.tap(find.text('puppy'));
    await tester.pump(const Duration(milliseconds: 100));
    await tester.tap(find.text('big'));
    await tester.pump(const Duration(milliseconds: 100));
    await tester.tap(find.text('large'));
    await tester.pump(const Duration(milliseconds: 100));
    await tester.tap(find.text('happy'));
    await tester.pump(const Duration(milliseconds: 100));
    await tester.tap(find.text('glad'));
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.text('Correct!'), findsOneWidget); // board graded itself
    expect(appState.hearts, 5);
    await tester.tap(find.text('Finish'));
    await tester.pump(const Duration(milliseconds: 600));
    expect(find.textContaining('1 / 1 correct'), findsOneWidget);
    await tester.pump(const Duration(seconds: 1));
  });
}
