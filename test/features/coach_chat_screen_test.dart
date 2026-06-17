import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ratel/core/theme/theme.dart';
import 'package:ratel/features/practice/screens/coach_chat_screen.dart';

void main() {
  testWidgets('coach chat renders at 360px with no overflow', (tester) async {
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      MaterialApp(theme: ratelTheme(), home: const CoachChatScreen()),
    );
    expect(find.text('Coach'), findsOneWidget);
    expect(find.text('Want to review past tense, or free chat today?'), findsOneWidget);
    expect(find.text('Explain a word'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
