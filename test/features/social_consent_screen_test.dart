import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ratel/core/theme/theme.dart';
import 'package:ratel/features/auth/screens/social_consent_screen.dart';

void main() {
  testWidgets('social-consent lists the 3 scopes at 360px with no overflow',
      (tester) async {
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      MaterialApp(theme: ratelTheme(), home: const SocialConsentScreen()),
    );
    expect(find.text('Ratel will receive'), findsOneWidget);
    expect(find.text('Your name'), findsOneWidget);
    expect(find.text('Your email address'), findsOneWidget);
    expect(find.text('Your profile photo'), findsOneWidget);
    expect(find.text('Allow & continue'), findsOneWidget);
    expect(find.text('Cancel'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
