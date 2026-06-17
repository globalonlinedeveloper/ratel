import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ratel/core/theme/theme.dart';
import 'package:ratel/features/learn/screens/listening_feed_screen.dart';

void main() {
  testWidgets('listening feed renders at 360px with no overflow',
      (tester) async {
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      MaterialApp(theme: ratelTheme(), home: const ListeningFeedScreen()),
    );
    expect(find.text('Listening'), findsOneWidget);
    expect(find.text('Morning news, slowly'), findsOneWidget);
    expect(find.text('Coffee shop chatter'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
