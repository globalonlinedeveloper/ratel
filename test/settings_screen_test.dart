import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ratel/app_state.dart';
import 'package:ratel/screens/settings_screen.dart';
import 'package:ratel/widgets/ratel_scaffold.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Inc 175 (Standardization Master Plan, Phase 1 -- Pillar D): the dedicated
/// Settings page. The preference controls were lifted out of the Profile tab
/// body into this pushed [RatelScaffold] route (reached by a gear entry in
/// Profile). Renders the moved controls at 360px with no overflow.
void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    appState.reset();
    appState.loaded = true;
  });

  Future<void> pumpScreen(WidgetTester t) async {
    t.view.physicalSize = const Size(360, 800);
    t.view.devicePixelRatio = 1.0;
    addTearDown(t.view.resetPhysicalSize);
    addTearDown(t.view.resetDevicePixelRatio);
    await t.pumpWidget(const MaterialApp(home: SettingsScreen()));
    // Embeds a push-status FutureBuilder + looping anims -> advance a fixed
    // slice, never pumpAndSettle (Inc 164 gotcha).
    await t.pump(const Duration(milliseconds: 300));
  }

  testWidgets('renders settings in a RatelScaffold at 360px, no overflow',
      (tester) async {
    await pumpScreen(tester);
    expect(tester.takeException(), isNull); // a RenderFlex overflow auto-fails
    expect(find.byType(RatelScaffold), findsOneWidget);
    expect(find.text('Settings'), findsOneWidget); // the header title
    expect(find.text('Sound effects'), findsOneWidget); // a moved control
  });
}
