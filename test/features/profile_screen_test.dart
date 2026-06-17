import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ratel/core/theme/theme.dart';
import 'package:ratel/features/profile/screens/profile_screen.dart';

void main() {
  testWidgets('profile renders score card with no overflow', (tester) async {
    tester.view.physicalSize = const Size(360, 820);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      MaterialApp(theme: ratelTheme(), home: const ProfileScreen()),
    );
    expect(find.text('raj_learns'), findsOneWidget);
    expect(find.text('English Score · 95'), findsOneWidget);
    expect(find.text('Edit profile'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
