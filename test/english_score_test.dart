import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ratel/app_state.dart';
import 'package:ratel/milestones.dart';
import 'package:ratel/screens/home_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    appState.reset();
  });

  test('englishScore weights completion 90 and caps streak at 10', () {
    expect(
        englishScore(lessonsDone: 0, lessonsTotal: 49, streak: 0), 0);
    expect(
        englishScore(lessonsDone: 49, lessonsTotal: 49, streak: 25), 100);
    expect(
        englishScore(lessonsDone: 0, lessonsTotal: 49, streak: 7), 7);
    expect(englishScore(lessonsDone: 99, lessonsTotal: 49, streak: 0),
        90); // overflow clamps
    expect(englishScore(lessonsDone: 1, lessonsTotal: 0, streak: 0), 90);
  });

  test('cefrFor bands and toNextBand gaps', () {
    expect(cefrFor(0), 'A1');
    expect(cefrFor(24), 'A1');
    expect(cefrFor(25), 'A2');
    expect(cefrFor(49), 'A2');
    expect(cefrFor(50), 'B1');
    expect(cefrFor(75), 'B2');
    expect(toNextBand(20), 5);
    expect(toNextBand(74), 1);
    expect(toNextBand(80), 0);
  });

  testWidgets('the Profile shows the score card with its band',
      (tester) async {
    appState.streak = 3;
    await tester.pumpWidget(const MaterialApp(home: HomeScreen()));
    await tester.pump(const Duration(milliseconds: 600));
    await tester.tap(find.text('Profile'));
    await tester.pump(const Duration(milliseconds: 600));
    expect(find.text('English Score'), findsOneWidget);
    expect(find.text('A1'), findsOneWidget);
    expect(find.textContaining('to A2'), findsOneWidget);
    await tester.pump(const Duration(seconds: 1));
  });
}
