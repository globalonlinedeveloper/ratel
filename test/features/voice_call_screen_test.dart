import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ratel/core/theme/theme.dart';
import 'package:ratel/features/practice/screens/voice_call_screen.dart';

void main() {
  testWidgets('voice call renders immersive UI with no overflow',
      (tester) async {
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      MaterialApp(theme: ratelTheme(), home: const VoiceCallScreen()),
    );
    expect(find.text('Maya · café scene'), findsOneWidget);
    expect(find.text('live · 02:14'), findsOneWidget);
    expect(find.byIcon(Icons.call_end), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
