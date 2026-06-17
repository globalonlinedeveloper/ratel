import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ratel/core/theme/theme.dart';
import 'package:ratel/features/social/screens/family_plan_screen.dart';

void main() {
  testWidgets('family plan renders members with no overflow', (tester) async {
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      MaterialApp(theme: ratelTheme(), home: const FamilyPlanScreen()),
    );
    expect(find.text('Family'), findsOneWidget);
    expect(find.text('You · manager'), findsOneWidget);
    expect(find.text('Send invite'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
