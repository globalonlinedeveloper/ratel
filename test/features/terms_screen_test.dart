import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ratel/core/theme/theme.dart';
import 'package:ratel/features/profile/screens/terms_screen.dart';

void main() {
  testWidgets('terms renders with draft banner at 360px no overflow',
      (tester) async {
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      MaterialApp(theme: ratelTheme(), home: const TermsScreen()),
    );
    expect(find.text('Terms of Service'), findsOneWidget);
    expect(find.textContaining('Draft —'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
