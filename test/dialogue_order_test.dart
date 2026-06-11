import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ratel/app_state.dart';
import 'package:ratel/exercise_kit.dart';
import 'package:ratel/models.dart';
import 'package:ratel/screens/lesson_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

const Exercise _dlg = Exercise.dialogueOrder(
    prompt: 'Order the conversation',
    lines: ['Hello!', 'Hi, how are you?', 'Fine, thanks.'],
    correctOrder: ['Hello!', 'Hi, how are you?', 'Fine, thanks.']);

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    appState.reset();
    appState.hearts = 5;
  });

  test('kit handles dialogueOrder', () {
    expect(canCheckAnswer(_dlg, pickedCount: 2), false);
    expect(canCheckAnswer(_dlg, pickedCount: 3), true);
    expect(
        gradeAnswer(_dlg,
            pickedWords: ['Hello!', 'Hi, how are you?', 'Fine, thanks.']),
        true);
    expect(gradeAnswer(_dlg, pickedWords: ['Fine, thanks.', 'Hello!']),
        false);
    expect(correctTextFor(_dlg),
        'Hello!  ·  Hi, how are you?  ·  Fine, thanks.');
    expect(explainSuffixFor(_dlg), 'do');
  });

  testWidgets('wrong order costs a heart, replays, then resolves',
      (tester) async {
    const lesson = Lesson(id: 'td1', title: 'Dialogue', exercises: [_dlg]);
    await tester.pumpWidget(
        const MaterialApp(home: LessonScreen(lesson: lesson)));
    await tester.pump(const Duration(milliseconds: 400));
    // assemble in the WRONG order
    await tester.tap(find.text('Fine, thanks.'));
    await tester.pump(const Duration(milliseconds: 100));
    await tester.tap(find.text('Hello!'));
    await tester.pump(const Duration(milliseconds: 100));
    await tester.tap(find.text('Hi, how are you?'));
    await tester.pump(const Duration(milliseconds: 150));
    await tester.tap(find.text('Check'));
    await tester.pump(const Duration(milliseconds: 400));
    expect(appState.hearts, 4); // first-pass miss
    expect(find.textContaining('Answer: Hello!'), findsOneWidget);
    await tester.tap(find.text('Continue'));
    await tester.pump(const Duration(milliseconds: 400));
    // fix phase begins; drain its toast, then rebuild correctly
    expect(find.text('FIXING MISTAKES'), findsOneWidget);
    await tester.pump(const Duration(milliseconds: 2400));
    await tester.pump(const Duration(milliseconds: 350));
    await tester.tap(find.text('Hello!'));
    await tester.pump(const Duration(milliseconds: 100));
    await tester.tap(find.text('Hi, how are you?'));
    await tester.pump(const Duration(milliseconds: 100));
    await tester.tap(find.text('Fine, thanks.'));
    await tester.pump(const Duration(milliseconds: 150));
    await tester.tap(find.text('Check'));
    await tester.pump(const Duration(milliseconds: 400));
    expect(appState.hearts, 4); // fix-phase grading is heart-free
    expect(find.text('Correct!'), findsOneWidget);
    await tester.tap(find.text('Finish'));
    await tester.pump(const Duration(milliseconds: 600));
    expect(find.textContaining('0 / 1 correct'), findsOneWidget);
    await tester.pump(const Duration(seconds: 1));
    appState.hearts = 5;
  });
}
