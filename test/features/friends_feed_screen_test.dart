import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ratel/core/theme/theme.dart';
import 'package:ratel/features/social/screens/friends_feed_screen.dart';

void main() {
  testWidgets('friends feed renders activity with no overflow', (tester) async {
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      MaterialApp(theme: ratelTheme(), home: const FriendsFeedScreen()),
    );
    expect(find.text('Friends'), findsOneWidget);
    expect(find.text('Activity'), findsOneWidget);
    expect(find.text('Asha hit a 30-day streak'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
