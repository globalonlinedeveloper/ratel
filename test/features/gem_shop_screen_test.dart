import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ratel/core/theme/theme.dart';
import 'package:ratel/features/social/screens/gem_shop_screen.dart';

void main() {
  testWidgets('gem shop renders items + packs with no overflow',
      (tester) async {
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      MaterialApp(theme: ratelTheme(), home: const GemShopScreen()),
    );
    expect(find.text('Shop'), findsOneWidget);
    expect(find.text('Streak freeze'), findsOneWidget);
    expect(find.text('Top up gems'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
