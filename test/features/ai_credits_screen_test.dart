import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ratel/core/theme/theme.dart';
import 'package:ratel/features/practice/screens/ai_credits_screen.dart';

void main() {
  testWidgets('ai credits sheet renders with no overflow', (tester) async {
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      MaterialApp(theme: ratelTheme(), home: const AiCreditsScreen()),
    );
    expect(find.text("You've used today's AI"), findsOneWidget);
    expect(find.text('Keep practising free (text & review)'), findsOneWidget);
    expect(find.text('Unlimited AI with Super'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
