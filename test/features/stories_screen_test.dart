import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ratel/core/theme/theme.dart';
import 'package:ratel/features/learn/screens/stories_screen.dart';

void main() {
  testWidgets('stories renders and answers are tappable', (tester) async {
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      MaterialApp(theme: ratelTheme(), home: const StoriesScreen()),
    );
    expect(find.text('At the café'), findsOneWidget);
    expect(find.text('What did she order?'), findsOneWidget);
    expect(find.text('Coffee'), findsOneWidget);
    expect(find.text('Continue'), findsOneWidget);
    await tester.tap(find.text('Tea'));
    await tester.pump();
    expect(tester.takeException(), isNull);
  });
}
