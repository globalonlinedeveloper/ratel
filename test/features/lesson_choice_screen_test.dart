import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ratel/core/theme/theme.dart';
import 'package:ratel/design_system/components/ratel_option_tile.dart';
import 'package:ratel/features/learn/screens/lesson_choice_screen.dart';

void main() {
  testWidgets('lesson choice renders and moves answer on tap', (tester) async {
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      MaterialApp(theme: ratelTheme(), home: const LessonChoiceScreen()),
    );
    expect(find.text('Select the translation'), findsOneWidget);
    expect(find.text('Check'), findsOneWidget);
    final Finder tiles = find.byType(RatelOptionTile);
    expect(tiles, findsNWidgets(3));
    expect(tester.widget<RatelOptionTile>(tiles.at(0)).selected, isTrue);
    await tester.tap(tiles.at(1));
    await tester.pump();
    expect(tester.widget<RatelOptionTile>(tiles.at(1)).selected, isTrue);
    expect(tester.widget<RatelOptionTile>(tiles.at(0)).selected, isFalse);
    expect(tester.takeException(), isNull);
  });
}
