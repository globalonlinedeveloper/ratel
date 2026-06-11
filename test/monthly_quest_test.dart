import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ratel/app_state.dart';
import 'package:ratel/milestones.dart';
import 'package:ratel/widgets/monthly_quest.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    appState.reset();
  });

  test('monthKey and monthName', () {
    expect(monthKey(DateTime(2026, 6, 11)), '2026-06');
    expect(monthKey(DateTime(2026, 12, 1)), '2026-12');
    expect(monthName(DateTime(2026, 6, 1)), 'June');
  });

  testWidgets('monthly quest shows progress, pays once at the goal',
      (tester) async {
    await tester.pumpWidget(const MaterialApp(
        home: Scaffold(body: MonthlyQuestCard(monthXp: 400))));
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.textContaining('quest: earn 1000 XP'), findsOneWidget);
    expect(find.text('400 / 1000 XP'), findsOneWidget);
    expect(find.text('+30 gems'), findsNothing); // not earned yet
    // earned state
    await tester.pumpWidget(const MaterialApp(
        home: Scaffold(body: MonthlyQuestCard(monthXp: 1200))));
    await tester.pump(const Duration(milliseconds: 300));
    await tester.tap(find.text('+30 gems'));
    await tester.pump(const Duration(milliseconds: 300));
    expect(appState.gems, 30);
    expect(find.textContaining('complete'), findsOneWidget);
    // fresh build the same month: hidden, no double pay
    await tester.pumpWidget(const MaterialApp(
        home: Scaffold(
            body: Padding(
                padding: EdgeInsets.all(1),
                child: MonthlyQuestCard(monthXp: 1200)))));
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.textContaining('quest'), findsNothing);
    expect(appState.gems, 30);
  });
}
