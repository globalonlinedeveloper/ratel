import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ratel/theme.dart';
import 'package:ratel/widgets/age_gate.dart';

void main() {
  Widget host(Widget child, {ThemeData? theme}) => MaterialApp(
    theme: theme ?? ratelTheme(),
    home: Scaffold(body: child),
  );

  testWidgets('valid year confirms', (tester) async {
    int? year;
    await tester.pumpWidget(host(AgeGate(onConfirm: (y) => year = y)));
    await tester.enterText(find.byType(TextField), '1995');
    await tester.tap(find.text('Continue'));
    await tester.pump();
    expect(year, 1995);
  });

  testWidgets('invalid year shows an error and does not confirm', (
    tester,
  ) async {
    int? year;
    await tester.pumpWidget(host(AgeGate(onConfirm: (y) => year = y)));
    await tester.enterText(find.byType(TextField), '12');
    await tester.tap(find.text('Continue'));
    await tester.pump();
    expect(find.text('Enter a valid year'), findsOneWidget);
    expect(year, isNull);
  });
}
