import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ratel/core/theme/theme.dart';
import 'package:ratel/design_system/components/ratel_error_retry.dart';

void main() {
  Widget host(Widget child) =>
      MaterialApp(theme: ratelTheme(), home: Scaffold(body: child));

  testWidgets('renders default title + retry label', (tester) async {
    await tester.pumpWidget(host(RatelErrorRetry(onRetry: () {})));
    expect(find.text('Something went wrong'), findsOneWidget);
    expect(find.text('Retry'), findsOneWidget);
  });

  testWidgets('tapping Retry fires onRetry', (tester) async {
    int taps = 0;
    await tester.pumpWidget(host(RatelErrorRetry(onRetry: () => taps++)));
    await tester.tap(find.text('Retry'));
    expect(taps, 1);
  });

  testWidgets('no onRetry -> no Retry button; 360px no overflow', (tester) async {
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(host(const RatelErrorRetry()));
    expect(find.text('Retry'), findsNothing);
    expect(tester.takeException(), isNull);
  });
}
