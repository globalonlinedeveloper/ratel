import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ratel/app_state.dart';
import 'package:ratel/content.dart';
import 'package:ratel/screens/home_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    appState.reset();
  });

  testWidgets('the pinned bar names the current unit and advances',
      (tester) async {
    await tester.pumpWidget(const MaterialApp(home: HomeScreen()));
    await tester.pump(const Duration(milliseconds: 600));
    expect(find.textContaining('Unit 1 ·'), findsOneWidget);
    await tester.pump(const Duration(seconds: 1));
    // complete unit 1 -> the bar follows the learner to unit 2
    for (final l in builtInCourse.first.lessons) {
      appState.completeLesson(l.id, 0);
    }
    await tester.pumpWidget(const MaterialApp(
        home: Padding(padding: EdgeInsets.all(1), child: HomeScreen())));
    await tester.pump(const Duration(milliseconds: 600));
    expect(find.textContaining('Unit 2 ·'), findsOneWidget);
    expect(find.textContaining('Unit 1 ·'), findsNothing);
    await tester.pump(const Duration(seconds: 1));
  });
}
