import 'package:flutter_test/flutter_test.dart';
import 'package:ratel/core/i18n/strings.dart';
import 'package:ratel/core/state/app_settings.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  // S holds global static locale state; reset to English between tests.
  tearDown(() => S.loadLocale('en'));

  test('English is the default; unknown keys fall back to their default', () {
    expect(S.localeCode, 'en');
    expect(S.t('appear_theme', 'Theme'), 'Theme');
    expect(S.t('totally_unknown_key', 'Fallback'), 'Fallback');
  });

  test('loadLocale(ta) returns Tamil but still falls back for untranslated keys', () {
    S.loadLocale('ta');
    expect(S.localeCode, 'ta');
    expect(S.t('appear_theme', 'Theme'), 'தீம்');
    expect(S.t('nav_home', 'Home'), 'முகப்பு');
    // a key with no Tamil entry falls back to the English source-of-truth
    expect(S.t('home_super', 'Go Super ✦'), 'Go Super ✦');
  });

  test('unknown locale codes fall back to English', () {
    S.loadLocale('zz');
    expect(S.localeCode, 'en');
    expect(S.t('nav_home', 'Home'), 'Home');
  });

  test('availableLocales is exactly the bundled set', () {
    expect(S.availableLocales.keys.toSet(), <String>{'en', 'ta'});
  });

  test('AppSettings persists localeCode and applies it to S', () async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final AppSettings s = AppSettings(prefs);
    expect(s.localeCode, 'en');

    int notifications = 0;
    s.addListener(() => notifications++);
    s.setLocaleCode('ta');
    expect(notifications, 1);
    expect(s.localeCode, 'ta');
    expect(S.localeCode, 'ta'); // switched in-session

    s.setLocaleCode('ta'); // same value -> no-op
    expect(notifications, 1);

    // a fresh AppSettings over the same prefs reloads the persisted locale
    expect(AppSettings(prefs).localeCode, 'ta');
  });
}
