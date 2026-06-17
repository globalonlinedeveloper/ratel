import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ratel/core/theme/theme.dart';
import 'package:ratel/features/practice/screens/video_lesson_screen.dart';

void main() {
  testWidgets('video lesson renders quiz with no overflow', (tester) async {
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      MaterialApp(theme: ratelTheme(), home: const VideoLessonScreen()),
    );
    expect(find.text('Quiz: how does he travel?'), findsOneWidget);
    expect(find.text('Train'), findsOneWidget);
    expect(find.text('Next clip'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
