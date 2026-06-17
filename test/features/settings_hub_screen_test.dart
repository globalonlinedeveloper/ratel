import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ratel/core/theme/theme.dart';
import 'package:ratel/design_system/components/ratel_settings_row.dart';
import 'package:ratel/features/profile/screens/settings_hub_screen.dart';

void main() {
  testWidgets('settings hub renders all rows with no overflow', (tester) async {
    tester.view.physicalSize = const Size(360, 820);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      MaterialApp(theme: ratelTheme(), home: const SettingsHubScreen()),
    );
    expect(find.text('Settings'), findsOneWidget);
    expect(find.text('Audio'), findsOneWidget);
    expect(find.text('Account'), findsOneWidget);
    expect(find.byType(RatelSettingsRow), findsNWidgets(8));
    expect(tester.takeException(), isNull);
  });
}
