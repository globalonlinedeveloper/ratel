import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ratel/app_state.dart';
import 'package:ratel/screens/home_screen.dart';
import 'package:ratel/widgets/hearts_sheet.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    appState.reset();
  });

  test('buyStreakFreeze respects balance and the cap of 2', () async {
    appState.streakFreezes = 0;
    appState.addGems(250);
    expect(await appState.buyStreakFreeze(), true);
    expect(appState.streakFreezes, 1);
    expect(appState.gems, 50);
    expect(await appState.buyStreakFreeze(), false); // short on gems
    appState.addGems(400);
    expect(await appState.buyStreakFreeze(), true);
    expect(appState.streakFreezes, 2);
    expect(await appState.buyStreakFreeze(), false); // cap
  });

  testWidgets('hearts popover refill pays gems and fills hearts',
      (tester) async {
    appState.hearts = 2;
    appState.addGems(400);
    await tester.pumpWidget(const MaterialApp(home: HomeScreen()));
    await tester.pump(const Duration(milliseconds: 600));
    await tester.tap(find.byKey(const Key('hearts_stat')));
    await tester.pump(const Duration(milliseconds: 400));
    await tester.tap(find.textContaining('Refill hearts'));
    await tester.pump(const Duration(milliseconds: 400));
    expect(appState.hearts, 5);
    expect(appState.gems, 50);
  });

  testWidgets('hearts popover refill with a thin wallet only nudges',
      (tester) async {
    appState.hearts = 2;
    appState.addGems(10);
    await tester.pumpWidget(const MaterialApp(home: HomeScreen()));
    await tester.pump(const Duration(milliseconds: 600));
    await tester.tap(find.byKey(const Key('hearts_stat')));
    await tester.pump(const Duration(milliseconds: 400));
    await tester.tap(find.textContaining('Refill hearts'));
    await tester.pump(const Duration(milliseconds: 400));
    expect(appState.hearts, 2);
    expect(appState.gems, 10);
    expect(find.text('Not enough gems yet — keep learning!'), findsOneWidget);
    await tester.pump(const Duration(seconds: 5)); // drain the snackbar
  });

  testWidgets('streak sheet sells a freeze', (tester) async {
    appState.streakFreezes = 1;
    appState.addGems(250);
    await tester.pumpWidget(const MaterialApp(home: HomeScreen()));
    await tester.pump(const Duration(milliseconds: 600));
    await tester.tap(find.byKey(const Key('streak_stat')));
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.text('Freezes: 1/2'), findsOneWidget);
    await tester.tap(find.textContaining('Get one'));
    await tester.pump(const Duration(milliseconds: 500));
    expect(appState.streakFreezes, 2);
    expect(appState.gems, 50);
    expect(find.text('Streak freeze added!'), findsOneWidget);
    await tester.pump(const Duration(seconds: 5)); // drain the snackbar
  });

  testWidgets('out-of-hearts sheet offers refill when affordable',
      (tester) async {
    appState.hearts = 0;
    appState.addGems(400);
    await tester.pumpWidget(MaterialApp(
      home: Builder(
        builder: (c) => Scaffold(
          body: Center(
            child: FilledButton(
              onPressed: () => showHeartsSheet(c),
              child: const Text('open'),
            ),
          ),
        ),
      ),
    ));
    await tester.tap(find.text('open'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.textContaining('Refill now'), findsOneWidget);
    await tester.tap(find.textContaining('Refill now'));
    await tester.pump(const Duration(milliseconds: 600));
    expect(appState.hearts, 5);
    expect(appState.gems, 50);
    await tester.pump(const Duration(seconds: 1)); // sheet auto-pop settles
  });
}
