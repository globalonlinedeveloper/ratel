import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ratel/core/state/app_settings.dart';
import 'package:ratel/features/profile/screens/appearance_screen.dart';

import '../support/settings_harness.dart';

void main() {
  testWidgets('appearance renders theme + accent with no overflow', (tester) async {
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final AppSettings settings = await makeTestSettings();
    await tester.pumpWidget(wrapWithSettings(const AppearanceScreen(), settings: settings));
    expect(find.text('Appearance & language'), findsOneWidget);
    expect(find.text('Theme'), findsOneWidget);
    expect(find.text('Reduce motion'), findsOneWidget);
    expect(find.text('Accent colour'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Dark pill sets themeMode; accent dot sets accentIndex', (tester) async {
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final AppSettings settings = await makeTestSettings();
    await tester.pumpWidget(wrapWithSettings(const AppearanceScreen(), settings: settings));

    await tester.tap(find.byKey(const Key('appearance.pill.dark')));
    await tester.pump();
    expect(settings.themeMode, ThemeMode.dark);

    await tester.tap(find.byKey(const Key('appearance.accent.2')));
    await tester.pump();
    expect(settings.accentIndex, 2);
    expect(tester.takeException(), isNull);
  });
}
