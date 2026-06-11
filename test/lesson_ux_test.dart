import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ratel/app_state.dart';
import 'package:ratel/content.dart';
import 'package:ratel/milestones.dart';
import 'package:ratel/models.dart';
import 'package:ratel/screens/home_screen.dart';
import 'package:ratel/screens/lesson_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

const Lesson _listenLesson = Lesson(id: 'tl1', title: 'Listen', exercises: [
  Exercise.listen(prompt: 'Type the word you hear', accepted: ['Hello']),
  Exercise.choice(
      prompt: 'Pick the greeting',
      options: ['Hello', 'Apple'],
      correctIndex: 0),
  Exercise.listen(prompt: 'Type the word you hear', accepted: ['Water']),
]);

Future<void> _open(WidgetTester t, Lesson lesson) async {
  await t.pumpWidget(MaterialApp(
    home: Builder(
      builder: (c) => Scaffold(
        body: Center(
          child: FilledButton(
            onPressed: () => Navigator.of(c).push(
                MaterialPageRoute(builder: (_) => LessonScreen(lesson: lesson))),
            child: const Text('open'),
          ),
        ),
      ),
    ),
  ));
  await t.tap(find.text('open'));
  await t.pump();
  await t.pump(const Duration(milliseconds: 600));
}

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('solutionText fills the blank when there is one', () {
    expect(solutionText('___ are you?', 'How'), 'How are you?');
    expect(solutionText(null, 'Hello'), 'Hello');
    expect(solutionText('No blank here', 'Hi'), 'Hi');
  });

  testWidgets('quit confirm protects progress; Keep learning stays',
      (tester) async {
    appState.hearts = 5;
    await _open(tester, builtInCourse.first.lessons.first);
    await tester.tap(find.text('Hello').first);
    await tester.pump(const Duration(milliseconds: 150));
    await tester.tap(find.text('Check'));
    await tester.pump(const Duration(milliseconds: 400));
    await tester.tap(find.byIcon(Icons.close));
    await tester.pump(const Duration(milliseconds: 350));
    expect(find.text("Wait, don't go!"), findsOneWidget);
    await tester.tap(find.text('Keep learning'));
    await tester.pump(const Duration(milliseconds: 350));
    expect(find.text("Wait, don't go!"), findsNothing);
    expect(find.text('Continue'), findsOneWidget); // still in the lesson
    await tester.tap(find.byIcon(Icons.close));
    await tester.pump(const Duration(milliseconds: 350));
    await tester.tap(find.text('Quit'));
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.text('open'), findsOneWidget); // back on the launcher
    appState.hearts = 5;
  });

  testWidgets('Skip reveals the full solution and costs no heart',
      (tester) async {
    appState.hearts = 5;
    await _open(tester, builtInCourse.first.lessons.first);
    // Q1 right, then SKIP Q2 (a fill-the-blank: "___ are you?")
    await tester.tap(find.text('Hello').first);
    await tester.pump(const Duration(milliseconds: 150));
    await tester.tap(find.text('Check'));
    await tester.pump(const Duration(milliseconds: 400));
    await tester.tap(find.text('Continue'));
    await tester.pump(const Duration(milliseconds: 400));
    await tester.tap(find.text('Skip'));
    await tester.pump(const Duration(milliseconds: 400));
    expect(appState.hearts, 5);
    expect(find.textContaining('Answer: How are you?'), findsOneWidget);
    await tester.pump(const Duration(seconds: 1));
  });

  testWidgets('keyboard: 1 selects an option and Enter checks',
      (tester) async {
    appState.hearts = 5;
    await _open(tester, builtInCourse.first.lessons.first);
    await tester.sendKeyEvent(LogicalKeyboardKey.digit1);
    await tester.pump(const Duration(milliseconds: 150));
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.text('Continue'), findsOneWidget); // graded either way
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.text('Check'), findsOneWidget); // advanced to Q2
    await tester.pump(const Duration(seconds: 1));
    appState.hearts = 5;
  });

  testWidgets("Can't listen right now mutes the rest of the lesson",
      (tester) async {
    appState.hearts = 5;
    await _open(tester, _listenLesson);
    await tester.tap(find.text("Can't listen right now"));
    await tester.pump(const Duration(milliseconds: 400));
    expect(appState.hearts, 5);
    expect(find.text('1/2'), findsOneWidget); // future listen item dropped
    await tester.tap(find.text('Continue'));
    await tester.pump(const Duration(milliseconds: 400));
    await tester.tap(find.text('Hello').first);
    await tester.pump(const Duration(milliseconds: 150));
    await tester.tap(find.text('Check'));
    await tester.pump(const Duration(milliseconds: 400));
    await tester.tap(find.text('Finish'));
    await tester.pump(const Duration(milliseconds: 600));
    expect(find.textContaining('1 / 3 correct'), findsOneWidget);
    await tester.pump(const Duration(seconds: 1));
  });

  testWidgets('listen_on=false filters listening items at lesson start',
      (tester) async {
    SharedPreferences.setMockInitialValues({'listen_on': false});
    appState.hearts = 5;
    await _open(tester, _listenLesson);
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('Play'), findsNothing); // no listen exercise shown
    expect(find.text('1/1'), findsOneWidget); // only the choice remains
  });

  testWidgets('Profile switch writes the listen_on preference',
      (tester) async {
    await tester.pumpWidget(const MaterialApp(home: HomeScreen()));
    await tester.pump(const Duration(milliseconds: 600));
    await tester.tap(find.text('Profile'));
    await tester.pump(const Duration(milliseconds: 600));
    await tester.scrollUntilVisible(find.text('Listening exercises'), 240,
        scrollable: find.byType(Scrollable).first);
    await tester.tap(find.text('Listening exercises'));
    await tester.pump(const Duration(milliseconds: 400));
    final p = await SharedPreferences.getInstance();
    expect(p.getBool('listen_on'), false);
    await tester.pump(const Duration(seconds: 1));
  });
}
