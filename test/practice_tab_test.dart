import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ratel/app_state.dart';
import 'package:ratel/screens/home/practice_tab.dart';
import 'package:ratel/widgets/smart_practice.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Inc 169 (Standardization Master Plan, Phase 1): the Practice tab body was
/// extracted from the home god-screen into [PracticeTab]. A tab body is NOT a
/// pushed route, so it must render with NO back header, and survive a narrow
/// 360px width without overflow.
void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    appState.reset();
    appState.loaded = true;
    appState.hearts = 5;
  });

  Future<void> pumpTab(WidgetTester t) async {
    t.view.physicalSize = const Size(360, 800);
    t.view.devicePixelRatio = 1.0;
    addTearDown(t.view.resetPhysicalSize);
    addTearDown(t.view.resetDevicePixelRatio);
    await t.pumpWidget(const MaterialApp(home: Scaffold(body: PracticeTab())));
    // PracticeTab embeds FutureBuilder cards whose loading skeleton loops
    // forever -> advance a fixed slice, NEVER pumpAndSettle (it would hang;
    // session-craft §11 / Inc 164 gotcha).
    await t.pump(const Duration(milliseconds: 300));
  }

  testWidgets('renders top-of-fold at 360px with no overflow', (tester) async {
    await pumpTab(tester);
    expect(tester.takeException(), isNull); // a RenderFlex overflow auto-fails
    // The list is lazy: only visible children build, so assert TOP-of-fold
    // content only (Inc 168 lazy-ListView finder gotcha).
    expect(find.text('Practice'), findsOneWidget); // the section title
    expect(find.byType(SmartPracticeCard), findsOneWidget); // first card mounts
    expect(find.text('Timed challenge'), findsOneWidget); // tc card
  });

  testWidgets('is a no-back-header tab body (no RatelScaffold/AppBar)',
      (tester) async {
    await pumpTab(tester);
    expect(find.byType(AppBar), findsNothing);
    expect(find.byType(BackButton), findsNothing);
  });
}
