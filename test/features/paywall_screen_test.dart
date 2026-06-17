import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ratel/core/theme/theme.dart';
import 'package:ratel/features/profile/screens/paywall_screen.dart';

void main() {
  testWidgets('paywall renders plans + single CTA with no overflow',
      (tester) async {
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      MaterialApp(theme: ratelTheme(), home: const PaywallScreen()),
    );
    expect(find.text('Ratel Super'), findsOneWidget);
    expect(find.text('Super · yearly'), findsOneWidget);
    expect(find.text('Start free trial'), findsOneWidget);
    expect(find.text('Restore'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
