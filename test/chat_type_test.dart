import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ratel/app_state.dart';
import 'package:ratel/exercise_kit.dart';
import 'package:ratel/models.dart';
import 'package:ratel/screens/lesson_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

const Exercise _chat = Exercise.chat(
    prompt: 'Reply to your friend',
    npcLine: 'Hi! How was your weekend?',
    accepted: ['It was great', 'It was great, thanks', 'Great, thanks']);

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    appState.reset();
    appState.hearts = 5;
  });

  test('kit handles chat', () {
    expect(canCheckAnswer(_chat), false);
    expect(canCheckAnswer(_chat, typed: 'hello'), true);
    expect(gradeAnswer(_chat, typed: 'it was great!'), true); // lenient
    expect(gradeAnswer(_chat, typed: 'no idea'), false);
    expect(correctTextFor(_chat), 'It was great');
    expect(explainSuffixFor(_chat), 'ch');
  });

  testWidgets('chat shows the bubble once and grades a typed reply',
      (tester) async {
    const lesson = Lesson(id: 'tc1', title: 'Chat', exercises: [_chat]);
    await tester.pumpWidget(
        const MaterialApp(home: LessonScreen(lesson: lesson)));
    await tester.pump(const Duration(milliseconds: 400));
    // the NPC line lives in the bubble ONLY (generic header suppressed)
    expect(find.text('Hi! How was your weekend?'), findsOneWidget);
    await tester.enterText(find.byType(TextField), 'It was great, thanks');
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
}
