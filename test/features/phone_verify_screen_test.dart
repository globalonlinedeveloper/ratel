import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ratel/core/theme/theme.dart';
import 'package:ratel/design_system/components/ratel_button.dart';
import 'package:ratel/features/auth/screens/phone_verify_screen.dart';

void main() {
  testWidgets('phone verify renders both fallbacks at 360px no overflow',
      (tester) async {
    tester.view.physicalSize = const Size(360, 820);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      MaterialApp(theme: ratelTheme(), home: const PhoneVerifyScreen()),
    );
    expect(find.text('Verify your number'), findsOneWidget);
    expect(find.text('Verify automatically'), findsOneWidget);
    expect(find.text('WhatsApp'), findsOneWidget);
    expect(find.text('SMS'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('all 3 CTAs disabled until phone valid', (tester) async {
    tester.view.physicalSize = const Size(360, 820);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      MaterialApp(theme: ratelTheme(), home: const PhoneVerifyScreen()),
    );
    RatelButton btn(String l) =>
        tester.widget<RatelButton>(find.widgetWithText(RatelButton, l));
    expect(btn('Verify automatically').onPressed, isNull);
    expect(btn('WhatsApp').onPressed, isNull);
    expect(btn('SMS').onPressed, isNull);
    await tester.enterText(find.byType(TextField), '12345');
    await tester.pump();
    expect(btn('Verify automatically').onPressed, isNull);
    expect(find.text('Enter a valid phone number'), findsOneWidget);
    await tester.enterText(find.byType(TextField), '9876543210');
    await tester.pump();
    expect(btn('Verify automatically').onPressed, isNotNull);
    expect(btn('WhatsApp').onPressed, isNotNull);
    expect(btn('SMS').onPressed, isNotNull);
  });
}
