import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ratel/app_state.dart';
import 'package:ratel/strings.dart';
import 'package:ratel/widgets/daily_chest.dart';
import 'package:ratel/widgets/monthly_quest.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    S.instance.debugClear();
    S.instance.locale = 'en';
    appState.reset();
  });

  testWidgets('server copy reaches the daily chest CTA', (tester) async {
    S.instance.debugSet('daily_chest_cta', en: 'Open your gift!');
    await tester.pumpWidget(const MaterialApp(
        home: Scaffold(body: DailyChestCard())));
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('Open your gift!'), findsOneWidget);
  });

  testWidgets('monthly quest title substitutes {month} and {goal}',
      (tester) async {
    S.instance.debugSet('monthly_quest_title',
        en: 'The {month} hunt: {goal} XP!');
    await tester.pumpWidget(const MaterialApp(
        home: Scaffold(
            body: MonthlyQuestCard(
                key: ValueKey('q'), monthXp: 10))));
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.textContaining('hunt: 1000 XP!'), findsOneWidget);
    expect(find.textContaining('{month}'), findsNothing);
  });
}
