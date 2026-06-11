import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ratel/app_state.dart';
import 'package:ratel/exercise_kit.dart';
import 'package:ratel/models.dart';
import 'package:ratel/screens/lesson_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

const Exercise _mb = Exercise.multiBlank(
    prompt: 'Fill the blanks',
    template: 'She ___ to school ___ bus.',
    options: ['goes', 'by', 'sleeps', 'on'],
    answers: ['goes', 'by']);

const Exercise _lr = Exercise.listenRespond(
    prompt: 'Pick the best reply',
    say: 'How are you today?',
    options: ["I'm fine, thanks!", 'A blue car.', 'On Monday.'],
    correctIndex: 0);

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    appState.reset();
    appState.hearts = 5;
  });

  test('kit handles multiBlank and listenRespond', () {
    expect(canCheckAnswer(_mb, pickedCount: 1), false);
    expect(canCheckAnswer(_mb, pickedCount: 2), true);
    expect(gradeAnswer(_mb, pickedWords: ['goes', 'by']), true);
    expect(gradeAnswer(_mb, pickedWords: ['by', 'goes']), false);
    expect(correctTextFor(_mb), 'She goes to school by bus.');
    expect(explainSuffixFor(_mb), 'mb');
    expect(canCheckAnswer(_lr), false);
    expect(canCheckAnswer(_lr, selected: 2), true);
    expect(gradeAnswer(_lr, selected: 0), true);
    expect(gradeAnswer(_lr, selected: 1), false);
    expect(correctTextFor(_lr), "I'm fine, thanks!");
    expect(explainSuffixFor(_lr, selected: 1), '1');
  });

  testWidgets('multi-blank fills in order and grades', (tester) async {
    const lesson = Lesson(id: 'tmb', title: 'Blanks', exercises: [_mb]);
    await tester.pumpWidget(
        const MaterialApp(home: LessonScreen(lesson: lesson)));
    await tester.pump(const Duration(milliseconds: 400));
    await tester.tap(find.text('goes'));
    await tester.pump(const Duration(milliseconds: 100));
    await tester.tap(find.text('by'));
    await tester.pump(const Duration(milliseconds: 150));
    await tester.tap(find.text('Check'));
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.text('Correct!'), findsOneWidget);
    expect(appState.hearts, 5);
    await tester.tap(find.text('Finish'));
    await tester.pump(const Duration(milliseconds: 600));
    expect(find.textContaining('1 / 1 correct'), findsOneWidget);
    await tester.pump(const Duration(seconds: 1));
  });

  testWidgets('listen-respond never shows the spoken line', (tester) async {
    const lesson = Lesson(id: 'tlr', title: 'Reply', exercises: [_lr]);
    await tester.pumpWidget(
        const MaterialApp(home: LessonScreen(lesson: lesson)));
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.text('How are you today?'), findsNothing); // heard, not read
    expect(find.text('Play'), findsOneWidget);
    await tester.tap(find.text("I'm fine, thanks!"));
    await tester.pump(const Duration(milliseconds: 150));
    await tester.tap(find.text('Check'));
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.text('Correct!'), findsOneWidget);
    await tester.pump(const Duration(seconds: 1));
  });
}
