import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ratel/core/theme/theme.dart';
import 'package:ratel/design_system/components/ratel_option_tile.dart';
import 'package:ratel/features/onboarding/screens/start_point_screen.dart';

void main() {
  testWidgets('start point renders options and moves selection on tap',
      (tester) async {
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      MaterialApp(theme: ratelTheme(), home: const StartPointScreen()),
    );
    expect(find.text('Where should we start?'), findsOneWidget);
    RatelOptionTile tile(String t) =>
        tester.widget<RatelOptionTile>(find.widgetWithText(RatelOptionTile, t));
    expect(tile('Start from scratch').selected, isTrue);
    await tester.tap(find.text('I know some — place me'));
    await tester.pump();
    expect(tile('I know some — place me').selected, isTrue);
    expect(tile('Start from scratch').selected, isFalse);
    expect(tester.takeException(), isNull);
  });
}
