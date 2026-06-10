import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ratel/content.dart';
import 'package:ratel/screens/coach_screen.dart';
import 'package:ratel/screens/lesson_screen.dart';
import 'package:ratel/screens/placement_screen.dart';

Widget _scaled(Widget child, double scale) => MaterialApp(
      home: MediaQuery(
        data: MediaQueryData(textScaler: TextScaler.linear(scale)),
        child: child,
      ),
    );

void main() {
  for (final scale in [1.3, 2.0]) {
    testWidgets('coach survives font scale $scale', (tester) async {
      await tester.pumpWidget(_scaled(
          Scaffold(body: CoachScreen(sender: (h) async => 'ok')), scale));
      await tester.pump(const Duration(milliseconds: 300));
      expect(tester.takeException(), isNull);
    });

    testWidgets('lesson survives font scale $scale', (tester) async {
      await tester.pumpWidget(_scaled(
          LessonScreen(lesson: builtInCourse.first.lessons.first),
          scale));
      await tester.pump(const Duration(milliseconds: 400));
      expect(tester.takeException(), isNull);
      await tester.pump(const Duration(seconds: 1));
    });

    testWidgets('placement survives font scale $scale', (tester) async {
      await tester.pumpWidget(_scaled(
          const PlacementScreen(goal: 20), scale));
      await tester.pump(const Duration(milliseconds: 300));
      expect(tester.takeException(), isNull);
    });
  }
}
