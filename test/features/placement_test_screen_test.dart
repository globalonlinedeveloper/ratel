import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ratel/core/theme/theme.dart';
import 'package:ratel/design_system/components/ratel_button.dart';
import 'package:ratel/design_system/components/ratel_option_tile.dart';
import 'package:ratel/features/onboarding/screens/placement_test_screen.dart';

void main() {
  Future<void> pump(WidgetTester tester) async {
    tester.view.physicalSize = const Size(360, 820);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      MaterialApp(theme: ratelTheme(), home: const PlacementTestScreen()),
    );
  }

  testWidgets('step 1 renders question, options, progress and note',
      (tester) async {
    await pump(tester);
    expect(find.text('Choose the correct word'), findsOneWidget);
    expect(find.text('She ___ to school every day.'), findsOneWidget);
    expect(find.text('1 / 5'), findsOneWidget);
    expect(find.widgetWithText(RatelOptionTile, 'goes'), findsOneWidget);
    expect(find.widgetWithText(RatelOptionTile, 'going'), findsOneWidget);
    expect(
      find.text('Sample questions — full adaptive test coming soon.'),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('Next stays disabled until an option is selected',
      (tester) async {
    await pump(tester);
    RatelButton cta() =>
        tester.widget<RatelButton>(find.byType(RatelButton));
    expect(find.text('Next'), findsOneWidget);
    expect(cta().onPressed, isNull);
    await tester.tap(find.widgetWithText(RatelOptionTile, 'goes'));
    await tester.pump();
    expect(cta().onPressed, isNotNull);
  });

  testWidgets('selecting then Next advances to step 2', (tester) async {
    await pump(tester);
    RatelOptionTile tile(String t) =>
        tester.widget<RatelOptionTile>(find.widgetWithText(RatelOptionTile, t));
    await tester.tap(find.widgetWithText(RatelOptionTile, 'goes'));
    await tester.pump();
    expect(tile('goes').selected, isTrue);
    await tester.tap(find.byType(RatelButton));
    await tester.pumpAndSettle();
    expect(find.text('Pick the correct past tense'), findsOneWidget);
    expect(find.text('2 / 5'), findsOneWidget);
    expect(find.text('Choose the correct word'), findsNothing);
    expect(tester.takeException(), isNull);
  });
}
