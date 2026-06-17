import 'package:flutter_test/flutter_test.dart';
import 'flow_harness.dart';

/// Social + monetization cross-links.
void main() {
  testWidgets('leagues Full leaderboard -> full leaderboard cohort',
      (tester) async {
    await pumpFlow(tester, '/leagues');
    await tester.tap(find.text('Full leaderboard'));
    await tester.pumpAndSettle();
    // Lands on the real cohort list (distinct from the tournament). The cohort
    // subtitle is unique to the leaderboard screen.
    expect(find.text('Your cohort this week · 30 learners'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('leaderboard rank row -> friend profile', (tester) async {
    await pumpFlow(tester, '/leaderboard');
    await tester.tap(find.text('mira_x'));
    await tester.pumpAndSettle();
    expect(find.text('12-day friend streak with you'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('friends row -> friend profile', (tester) async {
    await pumpFlow(tester, '/friends');
    await tester.tap(find.text('Asha'));
    await tester.pumpAndSettle();
    expect(find.text('12-day friend streak with you'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('paywall Start free trial -> checkout', (tester) async {
    await pumpFlow(tester, '/paywall');
    await tester.tap(find.text('Start free trial'));
    await tester.pumpAndSettle();
    expect(find.text('Next charge'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('manage subscription -> cancel / win-back', (tester) async {
    await pumpFlow(tester, '/subscription');
    await tester.tap(find.text('Cancel subscription'));
    await tester.pumpAndSettle();
    expect(find.text('Before you go'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
