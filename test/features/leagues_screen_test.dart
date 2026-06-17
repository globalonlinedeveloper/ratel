import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ratel/core/theme/theme.dart';
import 'package:ratel/features/social/screens/leagues_screen.dart';

void main() {
  testWidgets('leagues render rank rows with no overflow', (tester) async {
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      MaterialApp(theme: ratelTheme(), home: const LeaguesScreen()),
    );
    expect(find.text('Gold League'), findsOneWidget);
    expect(find.text('You'), findsOneWidget);
    expect(find.text('820 XP'), findsOneWidget);
    expect(find.text('Full leaderboard'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
