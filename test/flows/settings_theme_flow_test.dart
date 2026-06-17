import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ratel/core/state/app_settings.dart';

import 'flow_harness.dart';

void main() {
  testWidgets('Appearance Dark pill re-themes the routed app to dark', (tester) async {
    final AppSettings settings = await pumpFlow(tester, '/appearance');

    await tester.tap(find.byKey(const Key('appearance.pill.dark')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 350));

    expect(settings.themeMode, ThemeMode.dark);
    final BuildContext ctx = tester.element(find.text('Theme'));
    expect(Theme.of(ctx).brightness, Brightness.dark);
  });
}
