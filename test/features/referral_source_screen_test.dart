import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ratel/core/theme/theme.dart';
import 'package:ratel/design_system/components/ratel_option_tile.dart';
import 'package:ratel/features/onboarding/screens/referral_source_screen.dart';

void main() {
  testWidgets('referral renders sources and selects on tap', (tester) async {
    tester.view.physicalSize = const Size(360, 820);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      MaterialApp(theme: ratelTheme(), home: const ReferralSourceScreen()),
    );
    expect(find.text("How'd you hear about us?"), findsOneWidget);
    expect(find.text('YouTube'), findsOneWidget);
    RatelOptionTile tile(String t) =>
        tester.widget<RatelOptionTile>(find.widgetWithText(RatelOptionTile, t));
    expect(tile('YouTube').selected, isFalse);
    await tester.tap(find.text('YouTube'));
    await tester.pump();
    expect(tile('YouTube').selected, isTrue);
    expect(tester.takeException(), isNull);
  });
}
