import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ratel/core/theme/theme.dart';
import 'package:ratel/features/auth/screens/signup_screen.dart';

void main() {
  testWidgets('renders the sign-up form at 360px with no overflow',
      (tester) async {
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
        MaterialApp(theme: ratelTheme(), home: const SignupScreen()));
    expect(tester.takeException(), isNull);
    expect(find.text('Create your account'), findsOneWidget);
    expect(find.text('Create account'), findsOneWidget);
    expect(find.byType(TextField), findsNWidgets(3));
    expect(find.text('Terms & Privacy'), findsOneWidget);
  });

  testWidgets('agree checkbox toggles its state', (tester) async {
    await tester.pumpWidget(
        MaterialApp(theme: ratelTheme(), home: const SignupScreen()));
    expect(find.byIcon(Icons.check_box_outline_blank), findsOneWidget);
    expect(find.byIcon(Icons.check_box), findsNothing);
    await tester.tap(find.byIcon(Icons.check_box_outline_blank));
    await tester.pump();
    expect(find.byIcon(Icons.check_box), findsOneWidget);
  });
}
