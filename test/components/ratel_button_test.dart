import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ratel/core/theme/theme.dart';
import 'package:ratel/design_system/components/ratel_button.dart';

Widget _wrap(Widget child) =>
    MaterialApp(theme: ratelTheme(), home: Scaffold(body: Center(child: child)));

void main() {
  testWidgets('filled button shows its label and fires onPressed',
      (tester) async {
    var taps = 0;
    await tester.pumpWidget(
        _wrap(RatelButton.filled(label: 'Log in', onPressed: () => taps++)));
    expect(find.text('Log in'), findsOneWidget);
    await tester.tap(find.text('Log in'));
    expect(taps, 1);
  });

  testWidgets('loading shows a spinner and blocks taps', (tester) async {
    var taps = 0;
    await tester.pumpWidget(_wrap(
        RatelButton.filled(label: 'Go', loading: true, onPressed: () => taps++)));
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    await tester.tap(find.byType(RatelButton));
    expect(taps, 0);
  });

  testWidgets('outline variant renders its label', (tester) async {
    await tester.pumpWidget(
        _wrap(RatelButton.outline(label: 'Use email', onPressed: () {})));
    expect(find.text('Use email'), findsOneWidget);
  });
}
