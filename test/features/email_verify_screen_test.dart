import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ratel/core/theme/theme.dart';
import 'package:ratel/features/auth/screens/email_verify_screen.dart';

void main() {
  testWidgets('email-verify renders at 360px with no overflow', (tester) async {
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      MaterialApp(theme: ratelTheme(), home: const EmailVerifyScreen()),
    );
    expect(find.text('Verify your email'), findsOneWidget);
    expect(find.text("I've verified — continue"), findsOneWidget);
    expect(find.text('Resend email'), findsOneWidget);
    expect(find.text('Change email address'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
