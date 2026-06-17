import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ratel/core/theme/theme.dart';
import 'package:ratel/design_system/components/ratel_settings_row.dart';
import 'package:ratel/features/profile/screens/help_legal_screen.dart';

void main() {
  testWidgets('help & legal renders links with no overflow', (tester) async {
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      MaterialApp(theme: ratelTheme(), home: const HelpLegalScreen()),
    );
    expect(find.text('Help & about'), findsOneWidget);
    expect(find.text('FAQ & help centre'), findsOneWidget);
    expect(find.text('Privacy Policy'), findsOneWidget);
    expect(find.text('Ratel v2.0 · made with care'), findsOneWidget);
    expect(find.byType(RatelSettingsRow), findsNWidgets(5));
    expect(tester.takeException(), isNull);
  });
}
