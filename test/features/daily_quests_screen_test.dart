import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ratel/core/theme/theme.dart';
import 'package:ratel/features/social/screens/daily_quests_screen.dart';

void main() {
  testWidgets('daily quests render tabs + co-op with no overflow',
      (tester) async {
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      MaterialApp(theme: ratelTheme(), home: const DailyQuestsScreen()),
    );
    expect(find.text('Daily'), findsOneWidget);
    expect(find.text('Earn 30 XP'), findsOneWidget);
    expect(find.text('Friends Quest · 100 gems'), findsOneWidget);
    expect(find.text('Start a quest'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
