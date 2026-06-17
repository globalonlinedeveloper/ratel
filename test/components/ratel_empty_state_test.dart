import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ratel/core/theme/theme.dart';
import 'package:ratel/design_system/components/ratel_button.dart';
import 'package:ratel/design_system/components/ratel_empty_state.dart';

void main() {
  Widget host(Widget child) =>
      MaterialApp(theme: ratelTheme(), home: Scaffold(body: child));

  testWidgets('renders title + message', (tester) async {
    await tester.pumpWidget(host(const RatelEmptyState(
      icon: Icons.inbox_outlined,
      title: 'No items',
      message: 'Add one to get started',
    )));
    expect(find.text('No items'), findsOneWidget);
    expect(find.text('Add one to get started'), findsOneWidget);
  });

  testWidgets('action button fires onAction', (tester) async {
    int taps = 0;
    await tester.pumpWidget(host(RatelEmptyState(
      icon: Icons.inbox_outlined,
      title: 'Empty',
      actionLabel: 'Add',
      onAction: () => taps++,
    )));
    await tester.tap(find.text('Add'));
    expect(taps, 1);
  });

  testWidgets('no action -> no RatelButton', (tester) async {
    await tester.pumpWidget(host(const RatelEmptyState(
      icon: Icons.inbox_outlined,
      title: 'Empty',
    )));
    expect(find.byType(RatelButton), findsNothing);
  });

  testWidgets('360px no overflow', (tester) async {
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(host(const RatelEmptyState(
      icon: Icons.inbox_outlined,
      title: 'Empty',
      message: 'Nothing here yet at all',
    )));
    expect(tester.takeException(), isNull);
  });
}
