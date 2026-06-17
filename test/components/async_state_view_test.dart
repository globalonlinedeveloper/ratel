import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ratel/core/theme/theme.dart';
import 'package:ratel/design_system/components/async_state_view.dart';
import 'package:ratel/design_system/components/ratel_empty_state.dart';
import 'package:ratel/design_system/components/ratel_error_retry.dart';
import 'package:ratel/design_system/components/ratel_skeleton.dart';

void main() {
  Widget host(Widget child) =>
      MaterialApp(theme: ratelTheme(), home: Scaffold(body: child));
  Widget view(RatelLoadState s, {VoidCallback? onRetry}) => AsyncStateView(
        state: s,
        onRetry: onRetry,
        data: (_) => const Text('loaded'),
      );

  testWidgets('loading shows a skeleton', (tester) async {
    await tester.pumpWidget(host(view(RatelLoadState.loading)));
    await tester.pump(const Duration(milliseconds: 50));
    expect(find.byType(RatelSkeleton), findsWidgets);
  });

  testWidgets('empty shows RatelEmptyState', (tester) async {
    await tester.pumpWidget(host(view(RatelLoadState.empty)));
    expect(find.byType(RatelEmptyState), findsOneWidget);
  });

  testWidgets('error shows RatelErrorRetry and Retry fires', (tester) async {
    int taps = 0;
    await tester.pumpWidget(host(view(RatelLoadState.error, onRetry: () => taps++)));
    expect(find.byType(RatelErrorRetry), findsOneWidget);
    await tester.tap(find.text('Retry'));
    expect(taps, 1);
  });

  testWidgets('data shows the data builder', (tester) async {
    await tester.pumpWidget(host(view(RatelLoadState.data)));
    expect(find.text('loaded'), findsOneWidget);
  });

  testWidgets('360px no overflow across states', (tester) async {
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    for (final RatelLoadState s in RatelLoadState.values) {
      await tester.pumpWidget(host(view(s, onRetry: () {})));
      await tester.pump(const Duration(milliseconds: 50));
      expect(tester.takeException(), isNull);
    }
  });
}
