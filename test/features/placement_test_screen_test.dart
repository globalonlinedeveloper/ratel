import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ratel/core/theme/theme.dart';
import 'package:ratel/design_system/components/ratel_option_tile.dart';
import 'package:ratel/features/onboarding/screens/placement_test_screen.dart';

void main() {
  testWidgets('placement test renders and moves answer on tap', (tester) async {
    tester.view.physicalSize = const Size(360, 820);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      MaterialApp(theme: ratelTheme(), home: const PlacementTestScreen()),
    );
    expect(find.text('Choose the correct word'), findsOneWidget);
    expect(find.text('3 / 7'), findsOneWidget);
    RatelOptionTile tile(String t) =>
        tester.widget<RatelOptionTile>(find.widgetWithText(RatelOptionTile, t));
    expect(tile('goes').selected, isTrue);
    await tester.tap(find.text('go'));
    await tester.pump();
    expect(tile('go').selected, isTrue);
    expect(tile('goes').selected, isFalse);
    expect(tester.takeException(), isNull);
  });
}
