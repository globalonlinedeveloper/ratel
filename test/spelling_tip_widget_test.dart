import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ratel/app_state.dart';
import 'package:ratel/models.dart';
import 'package:ratel/screens/lesson_screen.dart';
import 'package:ratel/strings.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Part B end-to-end: a correct answer in the OTHER English variant earns full
/// credit AND surfaces the kind, locale-aware tip in the feedback slot.
const _lesson = Lesson(id: 'sp1', title: 'Spelling', exercises: [
  Exercise.typed(prompt: 'Type a primary colour', accepted: ['color']),
]);

Future<void> _open(WidgetTester t) async {
  await t.pumpWidget(MaterialApp(
    home: Builder(
      builder: (c) => Scaffold(
        body: Center(
          child: FilledButton(
            onPressed: () => Navigator.of(c).push(MaterialPageRoute(
                builder: (_) => LessonScreen(lesson: _lesson))),
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
    appState.reset();
    appState.hearts = 5;
    S.instance.locale = 'en';
    S.instance.debugClear();
  });

  testWidgets('US/UK variant answer = full credit + a kind locale-aware tip',
      (tester) async {
    await _open(tester);
    await tester.enterText(find.byKey(const Key('typed-field')), 'colour');
    await tester.pump(const Duration(milliseconds: 200));
    await tester.tap(find.text('Check'));
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.text('Correct!'), findsOneWidget); // full credit
    expect(find.text('In US English it\'s "color".'), findsOneWidget); // tip
  });
}
