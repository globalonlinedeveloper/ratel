import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ratel/core/theme/theme.dart';
import 'package:ratel/features/profile/screens/referral_hub_screen.dart';

void main() {
  testWidgets('referral hub renders link + stats with no overflow',
      (tester) async {
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      MaterialApp(theme: ratelTheme(), home: const ReferralHubScreen()),
    );
    expect(find.text('Invite friends, earn gems'), findsOneWidget);
    expect(find.text('ratel.app/r/RAJ7K'), findsOneWidget);
    expect(find.text('Share on WhatsApp'), findsOneWidget);
    expect(find.text('Invited 3'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
