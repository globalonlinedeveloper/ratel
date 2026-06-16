import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ratel/core/theme/theme.dart';
import 'package:ratel/design_system/components/ratel_choice_chip.dart';
import 'package:ratel/features/onboarding/screens/motivation_screen.dart';

void main() {
  testWidgets('motivation renders chips and moves selection on tap',
      (tester) async {
    tester.view.physicalSize = const Size(360, 820);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      MaterialApp(theme: ratelTheme(), home: const MotivationScreen()),
    );
    expect(find.text('Why are you learning?'), findsOneWidget);
    RatelChoiceChip chip(String l) =>
        tester.widget<RatelChoiceChip>(find.widgetWithText(RatelChoiceChip, l));
    expect(chip('Career').selected, isTrue);
    expect(chip('Travel').selected, isFalse);
    await tester.tap(find.text('Travel'));
    await tester.pump();
    expect(chip('Travel').selected, isTrue);
    expect(chip('Career').selected, isFalse);
    expect(tester.takeException(), isNull);
  });
}
