import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ratel/core/theme/theme.dart';
import 'package:ratel/design_system/components/ratel_password_strength.dart';

void main() {
  Widget host(Widget child) =>
      MaterialApp(theme: ratelTheme(), home: Scaffold(body: child));

  testWidgets('strength 0 shows no label', (tester) async {
    await tester.pumpWidget(host(const RatelPasswordStrength(strength: 0)));
    expect(find.text('Weak'), findsNothing);
    expect(find.text('Fair'), findsNothing);
    expect(find.text('Good'), findsNothing);
  });

  testWidgets('strength 1 shows Weak', (tester) async {
    await tester.pumpWidget(host(const RatelPasswordStrength(strength: 1)));
    expect(find.text('Weak'), findsOneWidget);
  });

  testWidgets('strength 3 shows Good', (tester) async {
    await tester.pumpWidget(host(const RatelPasswordStrength(strength: 3)));
    expect(find.text('Good'), findsOneWidget);
  });

  testWidgets('360px no overflow', (tester) async {
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(host(const RatelPasswordStrength(strength: 2)));
    expect(tester.takeException(), isNull);
  });
}
