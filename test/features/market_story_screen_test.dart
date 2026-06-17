import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ratel/core/theme/theme.dart';
import 'package:ratel/features/practice/screens/market_story_screen.dart';

void main() {
  testWidgets('market story renders and answers are tappable', (tester) async {
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      MaterialApp(theme: ratelTheme(), home: const MarketStoryScreen()),
    );
    expect(find.text('At the market'), findsOneWidget);
    expect(find.text('Comprehension: what did he buy?'), findsOneWidget);
    expect(find.text('Mangoes'), findsOneWidget);
    await tester.tap(find.text('Bread'));
    await tester.pump();
    expect(tester.takeException(), isNull);
  });
}
