import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ratel/core/theme/theme.dart';
import 'package:ratel/design_system/components/ratel_button.dart';
import 'package:ratel/features/auth/screens/forgot_password_screen.dart';

void main() {
  RatelButton cta(WidgetTester t) =>
      t.widget<RatelButton>(find.widgetWithText(RatelButton, 'Send reset link'));

  testWidgets('reset CTA disabled until valid email; 360px clean',
      (tester) async {
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
        MaterialApp(theme: ratelTheme(), home: const ForgotPasswordScreen()));
    expect(cta(tester).onPressed, isNull);

    await tester.enterText(find.byType(TextField), 'bad');
    await tester.pump();
    expect(find.text('Enter a valid email'), findsOneWidget);
    expect(cta(tester).onPressed, isNull);

    await tester.enterText(find.byType(TextField), 'a@b.com');
    await tester.pump();
    expect(cta(tester).onPressed, isNotNull);
    expect(tester.takeException(), isNull);
  });
}
