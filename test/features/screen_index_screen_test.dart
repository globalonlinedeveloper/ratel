import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ratel/core/theme/theme.dart';
import 'package:ratel/features/dev/screens/screen_index_screen.dart';

void main() {
  testWidgets('screen index renders the gallery header + first section',
      (tester) async {
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      MaterialApp(theme: ratelTheme(), home: const ScreenIndexScreen()),
    );
    expect(find.text('Ratel — all screens'), findsOneWidget);
    expect(find.text('Page 1 · Auth & entry'), findsOneWidget);
    expect(find.text('1 · Splash'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
