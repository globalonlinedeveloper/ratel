import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ratel/core/theme/theme.dart';
import 'package:ratel/design_system/components/ratel_button.dart';
import 'package:ratel/features/auth/screens/login_screen.dart';

void main() {
  Widget host() => MaterialApp(theme: ratelTheme(), home: const LoginScreen());
  RatelButton cta(WidgetTester t) =>
      t.widget<RatelButton>(find.widgetWithText(RatelButton, 'Log in'));

  testWidgets('CTA disabled until email + password valid; 360px clean',
      (tester) async {
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(host());
    expect(cta(tester).onPressed, isNull);

    await tester.enterText(find.byType(TextField).at(0), 'nope');
    await tester.pump();
    expect(find.text('Enter a valid email'), findsOneWidget);
    expect(cta(tester).onPressed, isNull);

    await tester.enterText(find.byType(TextField).at(0), 'a@b.com');
    await tester.enterText(find.byType(TextField).at(1), 'abcd1234');
    await tester.pump();
    expect(find.text('Enter a valid email'), findsNothing);
    expect(cta(tester).onPressed, isNotNull);
    expect(tester.takeException(), isNull);
  });
}
