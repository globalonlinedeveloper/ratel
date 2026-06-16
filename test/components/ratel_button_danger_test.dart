import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ratel/core/theme/theme.dart';
import 'package:ratel/design_system/components/ratel_button.dart';

Widget _wrap(Widget child) =>
    MaterialApp(theme: ratelTheme(), home: Scaffold(body: Center(child: child)));

void main() {
  testWidgets('dangerFilled shows its label and fires onPressed',
      (tester) async {
    var taps = 0;
    await tester.pumpWidget(
      _wrap(RatelButton.dangerFilled(
          label: 'Delete account', onPressed: () => taps++)),
    );
    expect(find.text('Delete account'), findsOneWidget);
    await tester.tap(find.text('Delete account'));
    expect(taps, 1);
  });

  testWidgets('dangerOutline renders its label', (tester) async {
    await tester.pumpWidget(
      _wrap(RatelButton.dangerOutline(label: 'Log out', onPressed: () {})),
    );
    expect(find.text('Log out'), findsOneWidget);
  });
}
