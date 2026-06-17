import 'package:flutter_test/flutter_test.dart';
import 'flow_harness.dart';

/// Social + monetization cross-links.
void main() {
  testWidgets('leagues Full leaderboard -> tournament', (tester) async {
    await pumpFlow(tester, '/leagues');
    await tester.tap(find.text('Full leaderboard'));
    await tester.pumpAndSettle();
    expect(find.text('Diamond Tournament'), findsOneWidget);
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
