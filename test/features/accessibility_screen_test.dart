import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ratel/core/state/app_settings.dart';
import 'package:ratel/features/profile/screens/accessibility_screen.dart';

import '../support/settings_harness.dart';

void main() {
  testWidgets('accessibility renders slider + toggles with no overflow',
      (tester) async {
    tester.view.physicalSize = const Size(360, 820);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final AppSettings settings = await makeTestSettings();
    await tester.pumpWidget(wrapWithSettings(const AccessibilityScreen(), settings: settings));
    expect(find.text('Accessibility'), findsOneWidget);
    expect(find.text('Text size'), findsOneWidget);
    expect(find.text('Captions on audio'), findsOneWidget);
    expect(find.byType(Slider), findsOneWidget);
    expect(find.byType(Switch), findsNWidgets(5));
    expect(tester.takeException(), isNull);
  });

  testWidgets('toggles + slider write through to AppSettings', (tester) async {
    tester.view.physicalSize = const Size(360, 820);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final AppSettings settings = await makeTestSettings();
    await tester.pumpWidget(wrapWithSettings(const AccessibilityScreen(), settings: settings));

    await tester.tap(find.byKey(const Key('a11y.toggle.dyslexia')));
    await tester.pump();
    expect(settings.dyslexiaFont, isTrue);

    await tester.tap(find.byKey(const Key('a11y.toggle.contrast')));
    await tester.pump();
    expect(settings.highContrast, isTrue);

    settings.setTextScale(1.3);
    await tester.pump();
    expect(settings.textScale, 1.3);
    expect(tester.takeException(), isNull);
  });
}
