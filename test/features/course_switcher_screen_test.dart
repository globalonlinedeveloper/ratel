import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ratel/core/theme/theme.dart';
import 'package:ratel/design_system/components/ratel_option_tile.dart';
import 'package:ratel/features/learn/screens/course_switcher_screen.dart';

void main() {
  testWidgets('course switcher renders and moves selection on tap',
      (tester) async {
    tester.view.physicalSize = const Size(360, 820);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      MaterialApp(theme: ratelTheme(), home: const CourseSwitcherScreen()),
    );
    expect(find.text('My courses'), findsOneWidget);
    expect(find.text('Add a language'), findsOneWidget);
    RatelOptionTile tile(String t) =>
        tester.widget<RatelOptionTile>(find.widgetWithText(RatelOptionTile, t));
    expect(tile('English').selected, isTrue);
    await tester.tap(find.text('Spanish'));
    await tester.pump();
    expect(tile('Spanish').selected, isTrue);
    expect(tile('English').selected, isFalse);
    expect(tester.takeException(), isNull);
  });
}
