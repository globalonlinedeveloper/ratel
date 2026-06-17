import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'flow_harness.dart';

/// Entry flows: auth/onboarding -> the app shell.
void main() {
  testWidgets('login: Log in -> Home shell', (tester) async {
    await pumpFlow(tester, '/login');
    await tester.tap(find.text('Log in'));
    await tester.pumpAndSettle();
    expect(find.text('Unit 3 · Everyday phrases'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('signup: tick agree + Create account -> language picker', (
    tester,
  ) async {
    await pumpFlow(tester, '/signup');
    await tester.tap(find.byIcon(Icons.check_box_outline_blank));
    await tester.pump();
    await tester.tap(find.text('Create account'));
    await tester.pumpAndSettle();
    expect(find.text('Welcome to Ratel'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('onboarding first-win: Continue -> Home shell', (tester) async {
    await pumpFlow(tester, '/onboarding/first-win');
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();
    expect(find.text('Unit 3 · Everyday phrases'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
