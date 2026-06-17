import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ratel/core/theme/theme.dart';
import 'package:ratel/features/profile/screens/faq_screen.dart';

void main() {
  testWidgets('faq renders at 360px with no overflow', (tester) async {
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      MaterialApp(theme: ratelTheme(), home: const FaqScreen()),
    );
    expect(find.text('Help centre'), findsOneWidget);
    expect(find.text('How do streaks work?'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
