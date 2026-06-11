import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ratel/app_state.dart';
import 'package:ratel/milestones.dart';
import 'package:ratel/widgets/daily_chest.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    appState.reset();
  });

  test('dailyChestReward pays the time-of-day bonus', () {
    expect(dailyChestReward(DateTime(2026, 6, 11, 7)), (3, 'Early bird bonus!'));
    expect(dailyChestReward(DateTime(2026, 6, 11, 23)), (3, 'Night owl bonus!'));
    expect(dailyChestReward(DateTime(2026, 6, 11, 12)), (2, ''));
  });

  testWidgets('daily chest pays once and hides on the next visit',
      (tester) async {
    final int expected = dailyChestReward(DateTime.now()).$1;
    await tester.pumpWidget(const MaterialApp(
        home: Scaffold(body: DailyChestCard())));
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('Daily chest — tap to open!'), findsOneWidget);
    await tester.tap(find.text('Daily chest — tap to open!'));
    await tester.pump(const Duration(milliseconds: 300));
    expect(appState.gems, expected);
    expect(find.textContaining('See you tomorrow'), findsOneWidget);
    // a fresh build the same day shows nothing
    await tester.pumpWidget(const MaterialApp(
        home: Scaffold(body: Padding(
            padding: EdgeInsets.all(1), child: DailyChestCard()))));
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.textContaining('Daily chest'), findsNothing);
    expect(appState.gems, expected); // unchanged
  });
}
