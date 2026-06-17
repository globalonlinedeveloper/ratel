import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ratel/core/theme/theme.dart';
import 'package:ratel/features/profile/screens/checkout_success_screen.dart';

void main() {
  testWidgets('checkout success renders summary with no overflow',
      (tester) async {
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      MaterialApp(theme: ratelTheme(), home: const CheckoutSuccessScreen()),
    );
    expect(find.text("You're Super!"), findsOneWidget);
    expect(find.text('Plan'), findsOneWidget);
    expect(find.text('Start learning'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
