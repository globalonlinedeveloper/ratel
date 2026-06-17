import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ratel/core/i18n/strings.dart';
import 'package:ratel/core/state/app_settings.dart';

import 'flow_harness.dart';

void main() {
  tearDown(() => S.loadLocale('en')); // global S — keep flows isolated

  testWidgets('Appearance Tamil pill switches the app language in-session',
      (tester) async {
    final AppSettings settings = await pumpFlow(tester, '/appearance');
    expect(find.text('Theme'), findsOneWidget);
    expect(settings.localeCode, 'en');

    await tester.tap(find.byKey(const Key('appearance.lang.ta')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 350));

    expect(settings.localeCode, 'ta');
    expect(S.localeCode, 'ta');
    // the appearance screen's own labels are now rendered in Tamil
    expect(find.text('தீம்'), findsOneWidget); // 'Theme'
    expect(find.text('Theme'), findsNothing);
    expect(tester.takeException(), isNull);
  });
}
