import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ratel/core/theme/theme.dart';
import 'package:ratel/features/profile/screens/appearance_screen.dart';

void main() {
  testWidgets('appearance renders theme + accent with no overflow',
      (tester) async {
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      MaterialApp(theme: ratelTheme(), home: const AppearanceScreen()),
    );
    expect(find.text('Appearance & language'), findsOneWidget);
    expect(find.text('Theme'), findsOneWidget);
    expect(find.text('Reduce motion'), findsOneWidget);
    expect(find.text('Accent colour'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
