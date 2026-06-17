import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ratel/core/theme/theme.dart';
import 'package:ratel/features/profile/screens/manage_subscription_screen.dart';

void main() {
  testWidgets('manage subscription renders status with no overflow',
      (tester) async {
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      MaterialApp(theme: ratelTheme(), home: const ManageSubscriptionScreen()),
    );
    expect(find.text('Your subscription'), findsOneWidget);
    expect(find.text('Ratel Super · yearly'), findsOneWidget);
    expect(find.text('Manage in App Store'), findsOneWidget);
    expect(find.text('Cancel subscription'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
