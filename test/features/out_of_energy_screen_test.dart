import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ratel/core/theme/theme.dart';
import 'package:ratel/features/learn/screens/out_of_energy_screen.dart';

void main() {
  testWidgets('out of energy renders refill options with no overflow',
      (tester) async {
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      MaterialApp(theme: ratelTheme(), home: const OutOfEnergyScreen()),
    );
    expect(find.text('Out of energy'), findsOneWidget);
    expect(find.text('Practice to earn energy'), findsOneWidget);
    expect(find.text('Watch ad +5'), findsOneWidget);
    expect(find.text('Unlimited with Super'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
