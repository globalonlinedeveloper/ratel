import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ratel/app_state.dart';
import 'package:ratel/screens/home/learn_tab.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Inc 171 (Standardization Master Plan, Phase 1): the Learn/home tab body —
/// the lessons path + the in-path header (streak/gems/hearts stats) — was
/// extracted verbatim from the home god-screen into [LearnTab]. A tab body is
/// NOT a pushed route (no AppBar/back header); tab switches go through the
/// [onSwitchTab] callback. The header stat keys must survive the move.
/// Inc 172: token/a11y migration (RatelSpacing + the 3 raw hex moved to
/// theme.dart tokens [BuildContext.lockedNodeC]/[RatelColors.enBadge] +
/// decorative mascots wrapped in ExcludeSemantics) — a no-visual-change
/// pass these render+no-overflow tests guard for free.
void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    appState.reset();
    appState.loaded = true;
  });

  Future<void> pumpTab(WidgetTester t) async {
    t.view.physicalSize = const Size(360, 800);
    t.view.devicePixelRatio = 1.0;
    addTearDown(t.view.resetPhysicalSize);
    addTearDown(t.view.resetDevicePixelRatio);
    await t.pumpWidget(
        MaterialApp(home: Scaffold(body: LearnTab(onSwitchTab: (_) {}))));
    // The path has a looping walk mascot -> advance a fixed slice, never
    // pumpAndSettle (it would hang; session-craft §11).
    await t.pump(const Duration(milliseconds: 300));
  }

  testWidgets('renders the path + header stat keys at 360px, no overflow',
      (tester) async {
    await pumpTab(tester);
    expect(tester.takeException(), isNull); // a RenderFlex overflow auto-fails
    expect(find.byKey(const Key('streak_stat')), findsOneWidget);
    expect(find.byKey(const Key('gems_stat')), findsOneWidget);
    expect(find.byKey(const Key('hearts_stat')), findsOneWidget);
  });

  testWidgets('is a no-back-header tab body (no AppBar)', (tester) async {
    await pumpTab(tester);
    expect(find.byType(AppBar), findsNothing);
  });
}
