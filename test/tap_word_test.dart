import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ratel/app_state.dart';
import 'package:ratel/flags.dart';
import 'package:ratel/models.dart';
import 'package:ratel/screens/lesson_screen.dart';
import 'package:ratel/widgets/word_tap_text.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _l = Lesson(id: 'tw1', title: 'TapWord', exercises: [
  Exercise.choice(
      prompt: 'Pick the greeting',
      sentence: 'apples',
      options: ['Hello', 'Apple'],
      correctIndex: 0),
]);

Future<void> _open(WidgetTester t, Lesson l) async {
  await t.pumpWidget(MaterialApp(home: LessonScreen(lesson: l)));
  await t.pump(const Duration(milliseconds: 400));
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    Flags.instance.debugSet({});
    appState.reset();
    appState.hearts = 5;
  });

  testWidgets('tap a stimulus word opens the hint sheet (hear)', (tester) async {
    await _open(tester, _l);
    expect(find.byType(WordTapText), findsOneWidget);
    // Tap the actual glyph (the word sits at the left of an Expanded, so a
    // center tap would miss it) via the rich-text range finder.
    await tester.tapOnText(find.textRange.ofSubstring('apples'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 450));
    expect(find.text('Hear'), findsOneWidget);
    await tester.pump(const Duration(seconds: 1));
  });

  testWidgets('tap_word flag off -> plain text, no WordTapText', (tester) async {
    Flags.instance.debugSet({'tap_word': 'false'});
    await _open(tester, _l);
    expect(find.byType(WordTapText), findsNothing);
    await tester.pump(const Duration(seconds: 1));
  });
}
