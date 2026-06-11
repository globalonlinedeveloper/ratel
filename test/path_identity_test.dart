import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ratel/content.dart';
import 'package:ratel/screens/home_screen.dart';
import 'package:ratel/screens/lesson_screen.dart';
import 'package:ratel/theme.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('unitAccent cycles a distinct palette', () {
    expect(unitAccent(0), isNot(unitAccent(1)));
    expect(unitAccent(0), unitAccent(kUnitAccents.length));
  });

  testWidgets('learn path shows lesson titles and unit progress',
      (tester) async {
    await tester.pumpWidget(const MaterialApp(home: HomeScreen()));
    await tester.pump(const Duration(milliseconds: 600));
    // current lesson title via its Start node row + a locked title below it
    expect(find.text('People'), findsWidgets); // u1l2 title under its node
    expect(find.text('0/5'), findsWidgets); // unit progress chips
    await tester.pump(const Duration(seconds: 1));
  });

  testWidgets('lesson HUD shows the question counter and combo chip',
      (tester) async {
    await tester.pumpWidget(MaterialApp(
        home: LessonScreen(lesson: builtInCourse.first.lessons.first)));
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.text('1/5'), findsOneWidget);
    // two correct answers -> combo chip x2
    await tester.tap(find.text('Hello').first);
    await tester.pump(const Duration(milliseconds: 150));
    await tester.tap(find.text('Check'));
    await tester.pump(const Duration(milliseconds: 400));
    await tester.tap(find.text('Continue'));
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.text('2/5'), findsOneWidget);
    await tester.tap(find.text('How').first);
    await tester.pump(const Duration(milliseconds: 150));
    await tester.tap(find.text('Check'));
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.text('\u00d72'), findsOneWidget);
    await tester.pump(const Duration(seconds: 1));
  });
}
