import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ratel/core/theme/theme.dart';
import 'package:ratel/features/practice/screens/adventures_roleplay_screen.dart';

void main() {
  testWidgets('adventures roleplay renders scorecard with no overflow',
      (tester) async {
    tester.view.physicalSize = const Size(360, 820);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      MaterialApp(theme: ratelTheme(), home: const AdventuresRoleplayScreen()),
    );
    expect(find.text('Job interview'), findsOneWidget);
    expect(find.text('Choose your reply:'), findsOneWidget);
    expect(find.text('Accuracy 90%'), findsOneWidget);
    expect(find.text('Reply'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
