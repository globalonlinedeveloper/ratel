import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'flow_harness.dart';

/// Help cluster: FAQ / Contact / Terms / Privacy / OSS licenses route correctly.
void main() {
  testWidgets('Help -> FAQ & help centre', (tester) async {
    await pumpFlow(tester, '/help');
    await tester.tap(find.text('FAQ & help centre'));
    await tester.pumpAndSettle();
    expect(find.text('Help centre'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Help -> Contact & report a bug', (tester) async {
    await pumpFlow(tester, '/help');
    await tester.tap(find.text('Contact & report a bug'));
    await tester.pumpAndSettle();
    expect(find.text('Contact us'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Help -> Terms of Service (draft scaffold)', (tester) async {
    await pumpFlow(tester, '/help');
    await tester.tap(find.text('Terms of Service'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Draft —'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Help -> Privacy Policy (draft scaffold)', (tester) async {
    await pumpFlow(tester, '/help');
    await tester.tap(find.text('Privacy Policy'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Draft —'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Help -> Open-source licenses opens LicensePage', (tester) async {
    await pumpFlow(tester, '/help');
    await tester.tap(find.text('Open-source licenses'));
    await tester.pumpAndSettle();
    expect(find.byType(LicensePage), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
