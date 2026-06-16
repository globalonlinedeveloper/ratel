import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ratel/core/theme/theme.dart';
import 'package:ratel/design_system/components/lesson_top_bar.dart';

void main() {
  testWidgets('LessonTopBar shows close, progress and energy', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: ratelTheme(),
        home: const Scaffold(
          body: LessonTopBar(progress: 0.5, energy: 18),
        ),
      ),
    );
    expect(find.byIcon(Icons.close), findsOneWidget);
    expect(find.byType(LinearProgressIndicator), findsOneWidget);
    expect(find.text('18'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
