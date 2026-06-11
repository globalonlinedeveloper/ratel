import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ratel/app_state.dart';
import 'package:ratel/content.dart';
import 'package:ratel/screens/lesson_screen.dart';
import 'package:ratel/strings.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    S.instance.debugClear();
    S.instance.locale = 'en';
    appState.reset();
    appState.hearts = 5;
  });

  test('t() falls back: missing row -> default, empty -> default', () {
    expect(S.instance.t('nope', 'fallback'), 'fallback');
    S.instance.debugSet('k', en: '');
    expect(S.instance.t('k', 'fallback'), 'fallback'); // empty = unset
    S.instance.debugSet('k', en: 'server says hi');
    expect(S.instance.t('k', 'fallback'), 'server says hi');
  });

  test('locale column wins, falls back to en, then default', () {
    S.instance.debugSet('k', en: 'hello', ta: 'வணக்கம்');
    expect(S.instance.t('k', 'd'), 'hello');
    S.instance.locale = 'ta';
    expect(S.instance.t('k', 'd'), 'வணக்கம்');
    S.instance.debugSet('k2', en: 'only en');
    expect(S.instance.t('k2', 'd'), 'only en'); // ta empty -> en
  });

  testWidgets('server copy reaches the quit dialog', (tester) async {
    S.instance.debugSet('quit_title', en: 'Hold on, badger!');
    await tester.pumpWidget(MaterialApp(
        home: LessonScreen(lesson: builtInCourse.first.lessons.first)));
    await tester.pump(const Duration(milliseconds: 400));
    // create stakes, then hit X
    await tester.tap(find.text('Hello').first);
    await tester.pump(const Duration(milliseconds: 150));
    await tester.tap(find.text('Check'));
    await tester.pump(const Duration(milliseconds: 400));
    await tester.tap(find.byIcon(Icons.close));
    await tester.pump(const Duration(milliseconds: 350));
    expect(find.text('Hold on, badger!'), findsOneWidget);
    await tester.tap(find.text('Keep learning'));
    await tester.pump(const Duration(milliseconds: 350));
    await tester.pump(const Duration(seconds: 1));
    appState.hearts = 5;
  });
}
