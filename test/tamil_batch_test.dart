import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ratel/app_state.dart';
import 'package:ratel/content.dart';
import 'package:ratel/screens/lesson_screen.dart';
import 'package:ratel/screens/onboarding_screen.dart';
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

  testWidgets("onboarding's I-speak control sets and persists the locale",
      (tester) async {
    await tester.pumpWidget(
        const MaterialApp(home: OnboardingScreen()));
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.text('I speak English'), findsOneWidget);
    await tester.tap(find.text('நான் தமிழ் பேசுகிறேன்'));
    await tester.pump(const Duration(milliseconds: 300));
    expect(S.instance.locale, 'ta');
    final p = await SharedPreferences.getInstance();
    expect(p.getString('app_locale'), 'ta');
  });

  testWidgets('the completion headline localizes from the database',
      (tester) async {
    S.instance.debugSet('lesson_complete',
        en: 'Lesson complete!', ta: 'பாடம் முடிந்தது!');
    S.instance.locale = 'ta';
    await tester.pumpWidget(MaterialApp(
        home: LessonScreen(lesson: builtInCourse.first.lessons.first)));
    await tester.pump(const Duration(milliseconds: 400));
    Future<void> answer(String t) async {
      await tester.tap(find.text(t).first);
      await tester.pump(const Duration(milliseconds: 150));
      await tester.tap(find.text('Check'));
      await tester.pump(const Duration(milliseconds: 400));
      await tester.tap(find.text('Continue'));
      await tester.pump(const Duration(milliseconds: 400));
    }
    await answer('Hello');
    await answer('How');
    await tester.tap(find.text('Good').first);
    await tester.pump(const Duration(milliseconds: 150));
    await tester.tap(find.text('morning').first);
    await tester.pump(const Duration(milliseconds: 150));
    await tester.tap(find.text('Check'));
    await tester.pump(const Duration(milliseconds: 400));
    await tester.tap(find.text('Continue'));
    await tester.pump(const Duration(milliseconds: 400));
    await answer("I'm fine, thanks");
    await tester.tap(find.text('meet').first);
    await tester.pump(const Duration(milliseconds: 150));
    await tester.tap(find.text('Check'));
    await tester.pump(const Duration(milliseconds: 400));
    await tester.tap(find.text('Finish'));
    await tester.pump(const Duration(milliseconds: 700));
    expect(find.text('பாடம் முடிந்தது!'), findsOneWidget);
    await tester.pump(const Duration(seconds: 1));
  });
}
