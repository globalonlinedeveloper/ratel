import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'flow_harness.dart';

/// Profile: English-Score card / Edit / settings gear route correctly.
void main() {
  testWidgets('English-Score card -> english score', (tester) async {
    await pumpFlow(tester, '/profile');
    await tester.tap(find.text('English Score · 95'));
    await tester.pumpAndSettle();
    expect(find.text('12-week trend'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Edit profile -> avatar builder', (tester) async {
    await pumpFlow(tester, '/profile');
    await tester.tap(find.text('Edit profile'));
    await tester.pumpAndSettle();
    expect(find.text('Edit avatar'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('settings gear -> settings hub', (tester) async {
    await pumpFlow(tester, '/profile');
    await tester.tap(find.byIcon(Icons.settings_outlined));
    await tester.pumpAndSettle();
    expect(find.text('Audio'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
