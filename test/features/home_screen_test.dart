import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ratel/core/theme/theme.dart';
import 'package:ratel/design_system/components/ratel_bottom_nav.dart';
import 'package:ratel/features/learn/screens/home_screen.dart';

void main() {
  testWidgets('home renders stats, unit and bottom nav with no overflow',
      (tester) async {
    tester.view.physicalSize = const Size(360, 820);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      MaterialApp(theme: ratelTheme(), home: const HomeScreen()),
    );
    expect(find.text('Unit 3 · Everyday phrases'), findsOneWidget);
    expect(find.text('320'), findsOneWidget);
    expect(find.byType(RatelBottomNav), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
