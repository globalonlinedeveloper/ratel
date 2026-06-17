import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ratel/core/theme/theme.dart';
import 'package:ratel/features/profile/screens/notifications_screen.dart';

void main() {
  testWidgets('notifications render 5 toggles with no overflow',
      (tester) async {
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      MaterialApp(theme: ratelTheme(), home: const NotificationsScreen()),
    );
    expect(find.text('Notifications'), findsOneWidget);
    expect(find.text('Streak reminder'), findsOneWidget);
    expect(find.text('Product & offers'), findsOneWidget);
    expect(find.byType(Switch), findsNWidgets(5));
    expect(tester.takeException(), isNull);
  });
}
