import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'flow_harness.dart';

/// Home launchpad: every stat / pill / node / banner opens the right screen.
void main() {
  testWidgets('streak stat -> streak hub', (tester) async {
    await pumpFlow(tester, '/home');
    await tester.tap(find.byIcon(Icons.local_fire_department));
    await tester.pumpAndSettle();
    expect(find.text('Double or nothing'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('gems stat -> shop', (tester) async {
    await pumpFlow(tester, '/home');
    await tester.tap(find.byIcon(Icons.diamond_outlined));
    await tester.pumpAndSettle();
    expect(find.text('Energy refill'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('energy stat -> out of energy', (tester) async {
    await pumpFlow(tester, '/home');
    await tester.tap(
      find
          .ancestor(
            of: find.text('18/25'),
            matching: find.byType(GestureDetector),
          )
          .first,
    );
    await tester.pumpAndSettle();
    expect(find.text('Out of energy'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('goal stat -> goal ring', (tester) async {
    await pumpFlow(tester, '/home');
    await tester.tap(find.byIcon(Icons.track_changes));
    await tester.pumpAndSettle();
    expect(find.text('Daily chest'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('league pill -> leagues', (tester) async {
    await pumpFlow(tester, '/home');
    await tester.tap(find.text('Gold league'));
    await tester.pumpAndSettle();
    expect(find.text('5 days left'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('quests pill -> quests', (tester) async {
    await pumpFlow(tester, '/home');
    await tester.tap(find.text('Quests 2/3'));
    await tester.pumpAndSettle();
    expect(find.text('Monthly'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('chest pill -> goal ring', (tester) async {
    await pumpFlow(tester, '/home');
    await tester.tap(find.text('Chest'));
    await tester.pumpAndSettle();
    expect(find.text('Daily chest'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('lesson star node -> lesson choice', (tester) async {
    await pumpFlow(tester, '/home');
    await tester.tap(find.byIcon(Icons.star));
    await tester.pumpAndSettle();
    expect(find.text('Select the translation'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('tune-up banner -> smart practice', (tester) async {
    await pumpFlow(tester, '/home');
    await tester.tap(find.text('7 weak skills · 4-min tune-up'));
    await tester.pumpAndSettle();
    expect(find.text('Verb agreement'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Friends pill -> friends feed', (tester) async {
    await pumpFlow(tester, '/home');
    await tester.tap(find.text('Friends'));
    await tester.pumpAndSettle();
    expect(find.text('Asha hit a 30-day streak'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Go-Super pill -> paywall', (tester) async {
    await pumpFlow(tester, '/home');
    await tester.tap(find.text('Go Super ✦'));
    await tester.pumpAndSettle();
    expect(find.text('Family · 6 seats'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('inbox bell -> notification inbox', (tester) async {
    await pumpFlow(tester, '/home');
    await tester.tap(find.byIcon(Icons.notifications_none));
    await tester.pumpAndSettle();
    expect(find.text('Mark all read'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('search icon -> global search', (tester) async {
    await pumpFlow(tester, '/home');
    await tester.tap(find.byIcon(Icons.search));
    await tester.pumpAndSettle();
    expect(find.text('Suggested'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
