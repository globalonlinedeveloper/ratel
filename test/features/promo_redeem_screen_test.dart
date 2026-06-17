import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ratel/core/theme/theme.dart';
import 'package:ratel/features/profile/screens/promo_redeem_screen.dart';

void main() {
  testWidgets('promo redeem renders code entry with no overflow',
      (tester) async {
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      MaterialApp(theme: ratelTheme(), home: const PromoRedeemScreen()),
    );
    expect(find.text('Redeem a code'), findsOneWidget);
    expect(find.text('CODE'), findsOneWidget);
    expect(find.text('Redeem'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
