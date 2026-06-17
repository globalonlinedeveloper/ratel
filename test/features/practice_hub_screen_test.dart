import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ratel/core/theme/theme.dart';
import 'package:ratel/features/practice/screens/practice_hub_screen.dart';

void main() {
  testWidgets('practice hub renders modes at 360px with no overflow',
      (tester) async {
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      MaterialApp(theme: ratelTheme(), home: const PracticeHubScreen()),
    );
    expect(find.text('Practice'), findsOneWidget);
    expect(find.text("Today's smart session"), findsOneWidget);
    expect(find.text('Smart practice'), findsOneWidget);
    expect(find.text('Speaking'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
