import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:ratel/core/router/app_router.dart';
import 'package:ratel/core/theme/theme.dart';

/// Shared harness for flow/navigation tests. Mounts the REAL app route table
/// (`appRoutes`) inside a `MaterialApp.router` at [start], sized tall enough that
/// every affordance is on-screen and hit-testable. Static start routes only —
/// `/splash` (auto-advance timer) is driven by hand in its own test.
Future<void> pumpFlow(WidgetTester tester, String start) async {
  tester.view.physicalSize = const Size(390, 1600);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  await tester.pumpWidget(
    MaterialApp.router(
      theme: ratelTheme(),
      routerConfig: GoRouter(initialLocation: start, routes: appRoutes),
    ),
  );
  await tester.pumpAndSettle();
}
