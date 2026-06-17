import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:ratel/core/router/app_router.dart';
import 'package:ratel/core/state/app_settings.dart';
import 'package:ratel/core/state/app_settings_scope.dart';
import 'package:ratel/core/theme/theme.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Shared harness for flow/navigation tests. Mounts the REAL app route table
/// (`appRoutes`) inside a `MaterialApp.router` at [start], wrapped in the same
/// `AppSettingsScope` + `AnimatedBuilder` the real app uses (so settings-bound
/// screens like Appearance/Accessibility have their scope ancestor). Sized tall
/// enough that every affordance is on-screen and hit-testable. Static start
/// routes only — `/splash` (auto-advance timer) is driven by hand in its own
/// test. Returns the live [AppSettings] so tests can assert persisted changes.
Future<AppSettings> pumpFlow(WidgetTester tester, String start) async {
  tester.view.physicalSize = const Size(390, 1600);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  SharedPreferences.setMockInitialValues(<String, Object>{});
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  final AppSettings settings = AppSettings(prefs);
  await tester.pumpWidget(
    AppSettingsScope(
      settings: settings,
      child: AnimatedBuilder(
        animation: settings,
        builder: (_, _) => MaterialApp.router(
          theme: ratelTheme(accentIndex: settings.accentIndex),
          darkTheme: ratelDarkTheme(accentIndex: settings.accentIndex),
          themeMode: settings.themeMode,
          routerConfig: GoRouter(initialLocation: start, routes: appRoutes),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
  return settings;
}
