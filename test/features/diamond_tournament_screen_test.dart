import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ratel/core/theme/theme.dart';
import 'package:ratel/features/social/screens/diamond_tournament_screen.dart';

void main() {
  testWidgets('diamond tournament renders rounds with no overflow',
      (tester) async {
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      MaterialApp(theme: ratelTheme(), home: const DiamondTournamentScreen()),
    );
    expect(find.text('Diamond Tournament'), findsOneWidget);
    expect(find.text('Quarter-final'), findsOneWidget);
    expect(find.text('Compete now'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
