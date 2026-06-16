import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ratel/core/theme/theme.dart';
import 'package:ratel/features/learn/screens/ai_roleplay_screen.dart';

void main() {
  testWidgets('ai roleplay renders chat at 360px with no overflow',
      (tester) async {
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      MaterialApp(theme: ratelTheme(), home: const AiRoleplayScreen()),
    );
    expect(find.text('Café roleplay'), findsOneWidget);
    expect(find.text('Hi! What can I get you today?'), findsOneWidget);
    expect(find.text("I'd like a coffee, please."), findsOneWidget);
    expect(find.text('great phrasing'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
