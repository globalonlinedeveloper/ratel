import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ratel/core/theme/theme.dart';
import 'package:ratel/features/profile/screens/cancel_winback_screen.dart';

void main() {
  testWidgets('cancel / win-back renders both easy choices with no overflow',
      (tester) async {
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      MaterialApp(theme: ratelTheme(), home: const CancelWinbackScreen()),
    );
    expect(find.text('Before you go'), findsOneWidget);
    expect(find.text('Stay for 50% off 3 months?'), findsOneWidget);
    expect(find.text('Keep Super at 50% off'), findsOneWidget);
    expect(find.text('Cancel anyway'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
