import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ratel/app_state.dart';
import 'package:ratel/locales.dart';
import 'package:ratel/screens/settings_screen.dart';
import 'package:ratel/strings.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Part A2 (W1): the Settings App-language picker is DATA-DRIVEN over
/// `locales.enabled` and SCALES — a tap-to-open dialog list (a SegmentedButton
/// would overflow once many locales enable). Selecting drives S.setLocale,
/// which now accepts any enabled locale (here en-GB).
void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    appState.reset();
    appState.loaded = true;
    S.instance.locale = 'en';
    S.instance.debugClear();
  });
  tearDown(() {
    Locales.instance.debugSet(
        const [LocaleEntry('en', 'English'), LocaleEntry('ta', 'தமிழ்')]);
    S.instance.locale = 'en';
  });

  testWidgets('lists every enabled locale and selects a non-default one (en-GB)',
      (tester) async {
    Locales.instance.debugSet(const [
      LocaleEntry('en', 'English'),
      LocaleEntry('en-GB', 'English (UK)'),
      LocaleEntry('ta', 'தமிழ்'),
      LocaleEntry('hi', 'हिन्दी'),
    ]);
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const MaterialApp(home: SettingsScreen()));
    await tester.pump(const Duration(milliseconds: 300));
    expect(tester.takeException(), isNull); // 4 locales, no overflow

    await tester.scrollUntilVisible(find.text('App language'), 240,
        scrollable: find.byType(Scrollable).first);
    // Inc 201 — current-language tile subtitle now shows native \u00b7 English
    expect(find.text('English \u00b7 English (US)'), findsOneWidget);
    await tester.tap(find.text('App language')); // open the picker dialog
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    // the dialog lists every enabled locale by native name
    expect(find.text('English (UK)'), findsOneWidget);
    expect(find.text('हिन्दी'), findsOneWidget);
    expect(find.text('தமிழ்'), findsOneWidget);
    // Inc 200 — English name now shows as a subtitle under the native name
    expect(find.text('Hindi'), findsOneWidget);
    expect(find.text('Tamil'), findsOneWidget);

    await tester.tap(find.text('English (UK)'));
    await tester.pump(const Duration(milliseconds: 300));

    expect(S.instance.locale, 'en-GB');
    final p = await SharedPreferences.getInstance();
    expect(p.getString('app_locale'), 'en-GB');
  });

  testWidgets('picking a language notifies appState so other tabs re-localize',
      (tester) async {
    Locales.instance.debugSet(const [
      LocaleEntry('en', 'English'),
      LocaleEntry('hi', 'हिन्दी'),
    ]);
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    var notified = 0;
    void onChange() => notified++;
    appState.addListener(onChange);
    addTearDown(() => appState.removeListener(onChange));

    await tester.pumpWidget(const MaterialApp(home: SettingsScreen()));
    await tester.pump(const Duration(milliseconds: 300));

    await tester.scrollUntilVisible(find.text('App language'), 240,
        scrollable: find.byType(Scrollable).first);
    await tester.tap(find.text('App language'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    final before = notified; // ignore any incidental notifies during build
    await tester.tap(find.text('हिन्दी'));
    await tester.pump(const Duration(milliseconds: 300));

    expect(S.instance.locale, 'hi');
    // The locale PICK itself must notify appState; without it the home never
    // rebuilds and other tabs stay in the old language until reload.
    expect(notified, greaterThan(before));
  });
}
