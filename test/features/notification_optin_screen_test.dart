import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ratel/core/theme/theme.dart';
import 'package:ratel/features/onboarding/screens/notification_optin_screen.dart';

void main() {
  testWidgets('notification opt-in renders at 360px with no overflow',
      (tester) async {
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      MaterialApp(theme: ratelTheme(), home: const NotificationOptinScreen()),
    );
    expect(find.text('Keep your streak alive'), findsOneWidget);
    expect(find.text('Turn on reminders'), findsOneWidget);
    expect(find.text('Not now'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
