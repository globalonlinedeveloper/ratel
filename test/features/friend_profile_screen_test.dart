import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ratel/core/theme/theme.dart';
import 'package:ratel/features/social/screens/friend_profile_screen.dart';

void main() {
  testWidgets('friend profile renders safety actions with no overflow',
      (tester) async {
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      MaterialApp(theme: ratelTheme(), home: const FriendProfileScreen()),
    );
    expect(find.text('asha_learns'), findsOneWidget);
    expect(find.text('Send kudos'), findsOneWidget);
    expect(find.text('Block'), findsOneWidget);
    expect(find.text('Report'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
