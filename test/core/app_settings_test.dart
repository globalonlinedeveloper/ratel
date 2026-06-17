import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ratel/core/state/app_settings.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../support/settings_harness.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('defaults when prefs are empty', () async {
    final AppSettings s = await makeTestSettings();
    expect(s.themeMode, ThemeMode.system);
    expect(s.accentIndex, 0);
    expect(s.textScale, 1.0);
    expect(s.highContrast, isFalse);
    expect(s.reduceMotion, isFalse);
    expect(s.dyslexiaFont, isFalse);
    expect(s.captions, isTrue);
    expect(s.noTimePressure, isFalse);
  });

  test('loads seeded prefs on construction', () async {
    final AppSettings s = await makeTestSettings(<String, Object>{
      'settings.themeMode': 'dark',
      'settings.accentIndex': 2,
      'settings.highContrast': true,
    });
    expect(s.themeMode, ThemeMode.dark);
    expect(s.accentIndex, 2);
    expect(s.highContrast, isTrue);
  });

  test('setThemeMode notifies once and persists', () async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final AppSettings s = AppSettings(prefs);
    int notifications = 0;
    s.addListener(() => notifications++);
    s.setThemeMode(ThemeMode.dark);
    expect(notifications, 1);
    expect(s.themeMode, ThemeMode.dark);
    // a fresh AppSettings over the same prefs reads the persisted value
    final AppSettings reloaded = AppSettings(prefs);
    expect(reloaded.themeMode, ThemeMode.dark);
  });

  test('setting the same value is a no-op (no notification)', () async {
    final AppSettings s = await makeTestSettings();
    int notifications = 0;
    s.addListener(() => notifications++);
    s.setThemeMode(ThemeMode.system); // already system
    s.setCaptions(true); // already true
    expect(notifications, 0);
  });

  test('accent + textScale setters persist', () async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final AppSettings s = AppSettings(prefs);
    s.setAccentIndex(2);
    s.setTextScale(1.3);
    expect(AppSettings(prefs).accentIndex, 2);
    expect(AppSettings(prefs).textScale, 1.3);
  });
}
