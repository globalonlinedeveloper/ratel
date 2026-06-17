import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'flow_harness.dart';

/// Profile: English-Score card / Edit / settings gear route correctly;
/// Settings -> Account -> Logout/Delete reach the existing flows.
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

  testWidgets('Settings Account row -> account screen', (tester) async {
    await pumpFlow(tester, '/settings');
    await tester.tap(find.text('Account'));
    await tester.pumpAndSettle();
    expect(find.text('Change password'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Account -> Delete opens delete screen', (tester) async {
    await pumpFlow(tester, '/account');
    await tester.tap(find.text('Delete account'));
    await tester.pumpAndSettle();
    expect(find.text('Delete your account?'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Account -> Log out opens logout sheet', (tester) async {
    await pumpFlow(tester, '/account');
    await tester.tap(find.text('Log out'));
    await tester.pumpAndSettle();
    expect(find.text('Log out?'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
