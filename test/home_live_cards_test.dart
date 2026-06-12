import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ratel/app_state.dart';
import 'package:ratel/daily_quests.dart';
import 'package:ratel/widgets/daily_nudge.dart';
import 'package:ratel/widgets/daily_quests_card.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Inc 135 (QA #2 P2): a guest finished u1l1 (+50 XP) but Home's goal banner
/// stayed at 0 progress and the daily quests never moved, while Profile saw
/// the same appState correctly. Root cause: DailyNudge / DailyQuestsCard are
/// const-instantiated in the always-mounted Home column, and parent rebuilds
/// SKIP identical const children — a Stateless appState reader freezes at
/// first-build values. The cards now self-listen; these tests pump them
/// exactly as Home does (const, inside a rebuild boundary) and assert they
/// track a completion on their own.
void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    appState.reset();
  });

  Widget host() => MaterialApp(
      home: Scaffold(
          body: ListenableBuilder(
              listenable: appState,
              builder: (_, __) => Column(children: const [
                    DailyNudge(),
                    DailyQuestsCard(),
                  ]))));

  testWidgets('goal banner tracks a guest completion (hides once goal met)',
      (tester) async {
    appState.dailyGoalXp = 20; // the onboarding "Regular" pick from the repro
    appState.loaded = true;
    await tester.pumpWidget(host());
    expect(find.text("20 XP to reach today's goal."), findsOneWidget);

    appState.completeLesson('u1l1', 50); // guest finishes the first lesson
    await tester.pump();

    // 50/20 — goal met: the nudge hides instead of still claiming 0 progress.
    expect(find.textContaining('to reach today'), findsNothing);
  });

  testWidgets('daily quests track XP + lesson progress live', (tester) async {
    appState.dailyGoalXp = 200; // keep the focus on the quest card
    appState.loaded = true;
    final quests = questsForToday();
    await tester.pumpWidget(host());
    expect(find.text('Daily quests (0/${quests.length})'), findsOneWidget);

    appState.completeLesson('u1l1', 50);
    await tester.pump();

    // 50 XP beats every possible date-seeded XP target (20/30/40/50).
    final done = quests.where((q) => questDone(q, appState)).length;
    expect(done, greaterThan(0));
    expect(find.text('Daily quests ($done/${quests.length})'), findsOneWidget);
  });
}
