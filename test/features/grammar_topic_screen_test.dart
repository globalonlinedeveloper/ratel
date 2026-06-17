import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ratel/core/theme/theme.dart';
import 'package:ratel/features/learn/screens/grammar_topic_screen.dart';

void main() {
  testWidgets('grammar topic renders rule, highlighted example and save action',
      (tester) async {
    tester.view.physicalSize = const Size(360, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      MaterialApp(theme: ratelTheme(), home: const GrammarTopicScreen()),
    );
    expect(find.text('Present simple'), findsOneWidget);
    expect(find.text('The rule'), findsOneWidget);
    expect(find.text('drink'), findsOneWidget);
    expect(find.text('Save to notebook'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
