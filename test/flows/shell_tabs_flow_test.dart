import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'flow_harness.dart';

/// Shell tabs: Home is default; Practice / Leagues / Profile each show on tap.
void main() {
  testWidgets('shell opens on Home by default', (tester) async {
    await pumpFlow(tester, '/app');
    expect(find.text('Unit 3 · Everyday phrases'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('shell: Practice tab shows', (tester) async {
    await pumpFlow(tester, '/app');
    await tester.tap(find.byIcon(Icons.fitness_center));
    await tester.pumpAndSettle();
    expect(find.text("Today's smart session"), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('shell: Leagues tab shows', (tester) async {
    await pumpFlow(tester, '/app');
    await tester.tap(find.byIcon(Icons.emoji_events_outlined));
    await tester.pumpAndSettle();
    expect(find.text('5 days left'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('shell: Profile tab shows', (tester) async {
    await pumpFlow(tester, '/app');
    await tester.tap(find.byIcon(Icons.person_outline));
    await tester.pumpAndSettle();
    expect(find.text('English Score · 95'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
