import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ratel/core/theme/theme.dart';
import 'package:ratel/features/auth/screens/reset_sent_screen.dart';

void main() {
  testWidgets('reset-sent renders at 360px with no overflow', (tester) async {
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      MaterialApp(theme: ratelTheme(), home: const ResetSentScreen()),
    );
    expect(find.text('Check your email'), findsOneWidget);
    expect(find.text('Open email app'), findsOneWidget);
    expect(find.text('Resend'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
