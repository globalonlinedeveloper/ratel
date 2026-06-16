import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ratel/core/theme/theme.dart';
import 'package:ratel/features/auth/screens/otp_screen.dart';

void main() {
  testWidgets('otp renders at 360px with no overflow', (tester) async {
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      MaterialApp(theme: ratelTheme(), home: const OtpScreen()),
    );
    expect(find.text('Enter the 6-digit code'), findsOneWidget);
    expect(find.text('Verify'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('typing fills the otp boxes', (tester) async {
    await tester.pumpWidget(
      MaterialApp(theme: ratelTheme(), home: const OtpScreen()),
    );
    await tester.enterText(
      find.byKey(const ValueKey<String>('otp_input')),
      '42',
    );
    await tester.pump();
    expect(find.text('4'), findsOneWidget);
    expect(find.text('2'), findsOneWidget);
  });
}
