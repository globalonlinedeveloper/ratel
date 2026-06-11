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
    appState.hearts = 5;
  });

  test('fmtCountdown renders m:ss', () {
    expect(fmtCountdown(const Duration(minutes: 12, seconds: 5)), '12:05');
    expect(fmtCountdown(const Duration(seconds: 9)), '0:09');
  });

  testWidgets('done node opens a practice popup that starts a review',
      (tester) async {
    appState.completeLesson('u1l1', 0);
    await tester.pumpWidget(const MaterialApp(home: HomeScreen()));
    await tester.pump(const Duration(milliseconds: 600));
    await tester.ensureVisible(find.text('Greetings').first);
    await tester.tap(find.text('Greetings').first);
    await tester.pump(const Duration(milliseconds: 350));
    expect(find.text('Practice again'), findsOneWidget);
    await tester.tap(find.text('Practice again'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 700));
    expect(find.text('Check'), findsOneWidget); // the review lesson opened
    await tester.pump(const Duration(seconds: 1));
  });

  testWidgets('locked node explains itself', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: HomeScreen()));
    await tester.pump(const Duration(milliseconds: 600));
    await tester.ensureVisible(find.text('Family').first);
    await tester.tap(find.text('Family').first);
    await tester.pump(const Duration(milliseconds: 350));
    expect(find.text('Complete the path above to unlock!'), findsOneWidget);
    await tester.tap(find.text('Close'));
    await tester.pump(const Duration(milliseconds: 350));
  });

  testWidgets('chest unlocks after 3 lessons and pays exactly once',
      (tester) async {
    appState.completeLesson('u1l1', 0);
    appState.completeLesson('u1l2', 0);
    appState.completeLesson('u1l3', 0);
    final int before = appState.xp;
    await tester.pumpWidget(const MaterialApp(home: HomeScreen()));
    await tester.pump(const Duration(milliseconds: 600));
    await tester.ensureVisible(find.byKey(const Key('chest_0')));
    await tester.tap(find.byKey(const Key('chest_0')));
    await tester.pump(const Duration(milliseconds: 350));
    expect(find.text('You found 20 XP!'), findsOneWidget);
    await tester.tap(find.text('Claim'));
    await tester.pump(const Duration(milliseconds: 350));
    expect(appState.xp, before + 20);
    await tester.tap(find.byKey(const Key('chest_0')));
    await tester.pump(const Duration(milliseconds: 350));
    expect(find.text('You found 20 XP!'), findsNothing); // pays once
    expect(appState.xp, before + 20);
  });

  testWidgets('locked chest nudges instead of paying', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: HomeScreen()));
    await tester.pump(const Duration(milliseconds: 600));
    await tester.ensureVisible(find.byKey(const Key('chest_0')));
    await tester.tap(find.byKey(const Key('chest_0')));
    await tester.pump(const Duration(milliseconds: 350));
    expect(find.text('Finish the three lessons above to open it.'),
        findsOneWidget);
    expect(appState.xp, 0);
  });

  testWidgets('streak stat opens the week calendar popover', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: HomeScreen()));
    await tester.pump(const Duration(milliseconds: 600));
    await tester.tap(find.byKey(const Key('streak_stat')));
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.textContaining('day streak'), findsOneWidget);
    expect(find.textContaining("won't break"), findsOneWidget);
    await tester.pump(const Duration(seconds: 1));
  });

  testWidgets('hearts stat opens fill view with practice CTA',
      (tester) async {
    await tester.pumpWidget(const MaterialApp(home: HomeScreen()));
    await tester.pump(const Duration(milliseconds: 600));
    await tester.tap(find.byKey(const Key('hearts_stat')));
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.text('Hearts full — go get them!'), findsOneWidget);
    await tester.tap(find.text('Practice — earn a heart'));
    await tester.pump(const Duration(milliseconds: 600));
    expect(find.text('Practice'), findsWidgets); // practice tab opened
  });
}
