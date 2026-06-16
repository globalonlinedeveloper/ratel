import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ratel/core/theme/theme.dart';
import 'package:ratel/design_system/components/ratel_option_tile.dart';
import 'package:ratel/features/onboarding/screens/daily_goal_screen.dart';

void main() {
  testWidgets('daily goal renders options and moves selection on tap',
      (tester) async {
    tester.view.physicalSize = const Size(360, 820);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      MaterialApp(theme: ratelTheme(), home: const DailyGoalScreen()),
    );
    expect(find.text('Set your daily goal'), findsOneWidget);
    expect(find.text('20 XP / day'), findsOneWidget);
    RatelOptionTile tile(String t) =>
        tester.widget<RatelOptionTile>(find.widgetWithText(RatelOptionTile, t));
    expect(tile('Regular').selected, isTrue);
    await tester.tap(find.text('Casual'));
    await tester.pump();
    expect(tile('Casual').selected, isTrue);
    expect(tile('Regular').selected, isFalse);
    expect(tester.takeException(), isNull);
  });
}
