import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ratel/core/theme/theme.dart';
import 'package:ratel/features/practice/screens/timed_challenge_screen.dart';

void main() {
  Future<void> pump(WidgetTester tester) async {
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      MaterialApp(theme: ratelTheme(), home: const TimedChallengeScreen()),
    );
  }

  testWidgets('idle renders stats + CTA at 360px (byte-stable)',
      (tester) async {
    await pump(tester);
    expect(find.text('Timed challenge'), findsOneWidget);
    expect(find.text('60s'), findsOneWidget);
    expect(find.text('42'), findsOneWidget);
    expect(find.text('Start challenge'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('start runs a live countdown that ticks then finishes',
      (tester) async {
    await pump(tester);
    await tester.tap(find.text('Start challenge'));
    await tester.pump();
    expect(find.text('Past tense of go'), findsOneWidget); // running question
    await tester.pump(const Duration(seconds: 1));
    expect(find.text('59'), findsOneWidget); // countdown ticked
    expect(tester.takeException(), isNull);
    await tester.pump(const Duration(seconds: 60)); // time runs out -> done
    expect(find.text("Time's up!"), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
