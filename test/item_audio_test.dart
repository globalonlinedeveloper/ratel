import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ratel/app_state.dart';
import 'package:ratel/flags.dart';
import 'package:ratel/models.dart';
import 'package:ratel/screens/lesson_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _choiceLesson = Lesson(id: 'al1', title: 'Audio', exercises: [
  Exercise.choice(
      prompt: 'Pick the greeting',
      sentence: 'Say ___ to a friend',
      options: ['Hello', 'Apple'],
      correctIndex: 0),
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
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    Flags.instance.debugSet({});
  });

  testWidgets('item_audio: a Listen speaker shows on a choice item and taps cleanly',
      (tester) async {
    appState.hearts = 5;
    await _open(tester, _choiceLesson);
    expect(find.byTooltip('Listen'), findsWidgets);
    await tester.tap(find.byTooltip('Listen').first);
    await tester.pump(const Duration(milliseconds: 100));
    await tester.pump(const Duration(seconds: 1));
  });

  testWidgets('item_audio flag off hides the pre-answer speaker',
      (tester) async {
    Flags.instance.debugSet({'item_audio': 'false'});
    appState.hearts = 5;
    await _open(tester, _choiceLesson);
    expect(find.byTooltip('Listen'), findsNothing);
    await tester.pump(const Duration(seconds: 1));
  });
}
