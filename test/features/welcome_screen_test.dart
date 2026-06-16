import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ratel/core/theme/theme.dart';
import 'package:ratel/features/auth/screens/welcome_screen.dart';

void main() {
  testWidgets('renders the welcome screen at 360px with no overflow',
      (tester) async {
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
        MaterialApp(theme: ratelTheme(), home: const WelcomeScreen()));
    expect(tester.takeException(), isNull);
    expect(find.text('Get started'), findsOneWidget);
    expect(find.text('I already have an account'), findsOneWidget);
    expect(find.textContaining('5 minutes a day'), findsOneWidget);
    expect(find.text('2M+ learners'), findsOneWidget);
  });
}
