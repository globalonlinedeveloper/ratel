import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ratel/app_state.dart';
import 'package:ratel/screens/settings_screen.dart';
import 'package:ratel/locales.dart';
import 'package:ratel/strings.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    S.instance.debugClear();
    S.instance.locale = 'en';
    Locales.instance.debugSet(
        const [LocaleEntry('en', 'English'), LocaleEntry('ta', 'தமிழ்')]);
    appState.reset();
  });

  test('setLocale persists and restoreLocale replays it', () async {
    await S.instance.setLocale('ta');
    expect(S.instance.locale, 'ta');
    S.instance.locale = 'en';
    await S.instance.restoreLocale();
    expect(S.instance.locale, 'ta');
    await S.instance.setLocale('klingon'); // unknown -> en
    expect(S.instance.locale, 'en');
  });

  testWidgets('the Profile language control flips wired copy to Tamil',
      (tester) async {
    S.instance.debugSet('quit_title',
        en: "Wait, don't go!", ta: 'இருங்கள், போகாதீர்கள்!');
    // Inc 175: the language control moved to the dedicated Settings page.
    await tester.pumpWidget(const MaterialApp(home: SettingsScreen()));
    await tester.pump(const Duration(milliseconds: 400));
    await tester.scrollUntilVisible(find.text('App language'), 240,
        scrollable: find.byType(Scrollable).first);
    await tester.tap(find.text('App language')); // open the picker dialog
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    await tester.tap(find.text('தமிழ்')); // choose Tamil from the dialog
    await tester.pump(const Duration(milliseconds: 400));
    expect(S.instance.locale, 'ta');
    expect(S.instance.t('quit_title', 'x'), 'இருங்கள், போகாதீர்கள்!');
    final p = await SharedPreferences.getInstance();
    expect(p.getString('app_locale'), 'ta');
  });
}
