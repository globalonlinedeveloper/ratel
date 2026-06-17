import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ratel/core/theme/theme.dart';
import 'package:ratel/design_system/components/ratel_skeleton.dart';

void main() {
  Widget host(Widget child) =>
      MaterialApp(theme: ratelTheme(), home: Scaffold(body: child));

  testWidgets('renders a skeleton without exception', (tester) async {
    await tester.pumpWidget(host(const SizedBox(width: 200, child: RatelSkeleton())));
    await tester.pump(const Duration(milliseconds: 50));
    expect(find.byType(RatelSkeleton), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('RatelSkeletonList renders N rows', (tester) async {
    await tester.pumpWidget(host(const RatelSkeletonList(rows: 3)));
    await tester.pump(const Duration(milliseconds: 50));
    expect(find.byType(RatelSkeleton), findsNWidgets(3));
  });

  testWidgets('360px no overflow', (tester) async {
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(host(const RatelSkeletonList(rows: 4)));
    await tester.pump(const Duration(milliseconds: 50));
    expect(tester.takeException(), isNull);
  });
}
