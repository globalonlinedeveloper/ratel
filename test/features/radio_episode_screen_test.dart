import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ratel/core/theme/theme.dart';
import 'package:ratel/features/learn/screens/radio_episode_screen.dart';

void main() {
  testWidgets('radio episode renders at 360px with no overflow',
      (tester) async {
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      MaterialApp(theme: ratelTheme(), home: const RadioEpisodeScreen()),
    );
    expect(find.text('Morning news, slowly'), findsOneWidget);
    expect(find.text('00:00'), findsOneWidget);
    expect(find.text('04:00'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
