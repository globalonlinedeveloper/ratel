import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ratel/core/theme/theme.dart';
import 'package:ratel/features/auth/screens/returning_unlock_screen.dart';

void main() {
  testWidgets('returning-unlock renders at 360px with no overflow',
      (tester) async {
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      MaterialApp(theme: ratelTheme(), home: const ReturningUnlockScreen()),
    );
    expect(find.text('Welcome back, Raj'), findsOneWidget);
    expect(find.text('Unlock with Face ID'), findsOneWidget);
    expect(find.text('RS'), findsOneWidget);
    expect(find.text('Use a different account'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
