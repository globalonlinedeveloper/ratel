import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ratel/content.dart';
import 'package:ratel/screens/lesson_screen.dart';
import 'package:ratel/theme.dart';

double _contrast(Color a, Color b) {
  final la = a.computeLuminance(), lb = b.computeLuminance();
  final hi = la > lb ? la : lb, lo = la > lb ? lb : la;
  return (hi + 0.05) / (lo + 0.05);
}

void main() {
  testWidgets('answer-state tints keep text readable in BOTH themes',
      (tester) async {
    for (final theme in [ratelTheme(), ratelDarkTheme()]) {
      late Color text, teal, coral, honey, surface, faint;
      await tester.pumpWidget(const SizedBox());
      await tester.pumpWidget(MaterialApp(
          theme: theme,
          home: Builder(builder: (c) {
            text = c.textC;
            teal = c.tintC(RatelColors.teal);
            coral = c.tintC(RatelColors.coral);
            honey = c.tintC(RatelColors.honey);
            surface = c.surfaceC;
            faint = c.faintBorderC;
            return const SizedBox();
          })));
      final mode = theme.brightness;
      expect(_contrast(text, teal), greaterThan(4.0),
          reason: 'teal tint unreadable in $mode');
      expect(_contrast(text, coral), greaterThan(4.0),
          reason: 'coral tint unreadable in $mode');
      expect(_contrast(text, honey), greaterThan(4.0),
          reason: 'honey tint (explanation card) unreadable in $mode');
      expect(_contrast(text, surface), greaterThan(7.0),
          reason: 'body text weak on surface in $mode');
      expect(_contrast(faint, surface), lessThan(2.0),
          reason: 'faint border should stay subtle in $mode');
    }
  });

  testWidgets('lesson: select + check stays visible in dark mode',
      (tester) async {
    final lesson = builtInCourse.first.lessons.first; // u1l1
    await tester.pumpWidget(MaterialApp(
        theme: ratelDarkTheme(), home: LessonScreen(lesson: lesson)));
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.text('Hello'), findsWidgets);
    await tester.tap(find.text('Hello').first);
    await tester.pump();
    await tester.tap(find.text('Check'));
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.textContaining('Correct'), findsOneWidget);
    await tester.pump(const Duration(seconds: 2));
  });
}
