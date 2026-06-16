import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ratel/core/theme/theme.dart';
import 'package:ratel/features/auth/screens/auth_hub_screen.dart';

void main() {
  testWidgets('renders the auth hub options at 360px with no overflow',
      (tester) async {
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
        MaterialApp(theme: ratelTheme(), home: const AuthHubScreen()));
    expect(tester.takeException(), isNull);
    expect(find.text('Sign in'), findsOneWidget);
    expect(find.text('Sign in with a passkey'), findsOneWidget);
    expect(find.text('Continue with Google'), findsOneWidget);
    expect(find.text('Continue with Apple'), findsOneWidget);
    expect(find.text('Continue with phone'), findsOneWidget);
    expect(find.text('Use email'), findsOneWidget);
    expect(find.text('Try it free'), findsOneWidget);
  });
}
