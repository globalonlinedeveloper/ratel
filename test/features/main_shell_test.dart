import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ratel/core/theme/theme.dart';
import 'package:ratel/design_system/components/ratel_bottom_nav.dart';
import 'package:ratel/features/shell/screens/main_shell.dart';

void main() {
  testWidgets('main shell opens on Home with one shared bottom nav', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      MaterialApp(theme: ratelTheme(), home: const MainShell()),
    );
    expect(find.byType(RatelBottomNav), findsOneWidget);
    expect(find.text('Unit 3 · Everyday phrases'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('main shell switches tab to Practice on nav tap', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      MaterialApp(theme: ratelTheme(), home: const MainShell()),
    );
    await tester.tap(find.byIcon(Icons.fitness_center));
    await tester.pumpAndSettle();
    // Home's unit label is offstage once Practice is foregrounded.
    expect(find.text('Unit 3 · Everyday phrases'), findsNothing);
    expect(tester.takeException(), isNull);
  });
}
