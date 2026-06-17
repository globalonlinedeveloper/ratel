import 'package:flutter/material.dart';
import 'package:ratel/core/state/app_settings.dart';
import 'package:ratel/core/state/app_settings_scope.dart';
import 'package:ratel/core/theme/theme.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Builds a mock-backed [AppSettings] for tests. Pass [seed] to preload prefs.
Future<AppSettings> makeTestSettings([
  Map<String, Object> seed = const <String, Object>{},
]) async {
  SharedPreferences.setMockInitialValues(seed);
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  return AppSettings(prefs);
}

/// Wraps [child] in the same scope + themed [MaterialApp] the real app uses,
/// so settings-driven theme changes are observable in widget tests.
Widget wrapWithSettings(Widget child, {required AppSettings settings}) {
  return AppSettingsScope(
    settings: settings,
    child: AnimatedBuilder(
      animation: settings,
      builder: (_, _) => MaterialApp(
        theme: ratelTheme(),
        darkTheme: ratelDarkTheme(),
        themeMode: settings.themeMode,
        home: child,
      ),
    ),
  );
}
