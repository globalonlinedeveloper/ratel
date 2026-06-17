import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ratel/core/theme/theme.dart';
import 'package:ratel/features/social/screens/notification_inbox_screen.dart';

void main() {
  testWidgets('notification inbox renders feed at 360px with no overflow',
      (tester) async {
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      MaterialApp(
        theme: ratelTheme(),
        home: const NotificationInboxScreen(),
      ),
    );
    expect(find.text('Notifications'), findsOneWidget);
    expect(find.text('Mark all read'), findsOneWidget);
    expect(find.text('Streak saved!'), findsOneWidget);
    expect(find.text('deepak_r started following you.'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
