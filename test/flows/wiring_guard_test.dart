import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ratel/core/theme/theme.dart';
import 'package:ratel/features/profile/screens/help_legal_screen.dart';
import 'package:ratel/features/profile/screens/settings_hub_screen.dart';

/// Wiring guard: a row that isn't wired (onTap == null) must NOT show a chevron
/// or open-in-new affordance, so nothing looks tappable-but-dead. If someone
/// adds an unwired RatelSettingsRow with a trailing affordance, this fails.
Future<void> _pump(WidgetTester tester, Widget screen) async {
  tester.view.physicalSize = const Size(390, 1200);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  await tester.pumpWidget(MaterialApp(theme: ratelTheme(), home: screen));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('Settings: only the 5 wired rows show a chevron', (tester) async {
    await _pump(tester, const SettingsHubScreen());
    // Appearance / Accessibility / Privacy & data / Notifications / Account
    // are wired; Audio / Learning / Widgets remain non-interactive labels.
    expect(find.byIcon(Icons.chevron_right), findsNWidgets(5));
    expect(find.text('Audio'), findsOneWidget);
    expect(find.text('Account'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Help & about: only the 3 wired rows show an affordance', (tester) async {
    await _pump(tester, const HelpLegalScreen());
    // FAQ / Contact / OSS are wired (chevron). Terms / Privacy remain
    // non-interactive (onTap == null) so their open_in_new never renders.
    expect(find.byIcon(Icons.chevron_right), findsNWidgets(3));
    expect(find.byIcon(Icons.open_in_new), findsNothing);
    expect(find.text('Privacy Policy'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
