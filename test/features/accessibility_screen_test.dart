import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ratel/core/theme/theme.dart';
import 'package:ratel/features/profile/screens/accessibility_screen.dart';

void main() {
  testWidgets('accessibility renders slider + toggles with no overflow',
      (tester) async {
    tester.view.physicalSize = const Size(360, 820);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      MaterialApp(theme: ratelTheme(), home: const AccessibilityScreen()),
    );
    expect(find.text('Accessibility'), findsOneWidget);
    expect(find.text('Text size'), findsOneWidget);
    expect(find.text('Captions on audio'), findsOneWidget);
    expect(find.byType(Slider), findsOneWidget);
    expect(find.byType(Switch), findsNWidgets(5));
    expect(tester.takeException(), isNull);
  });
}
