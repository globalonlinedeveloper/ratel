import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ratel/app_state.dart';
import 'package:ratel/screens/home/profile_tab.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Inc 170 (Standardization Master Plan, Phase 1): the Profile tab body was
/// extracted from the home god-screen into [ProfileTab] (a StatefulWidget —
/// it owns the `_listenOn` setting). A tab body is NOT a pushed route, so it
/// renders with NO back header, and must survive a narrow 360px width.
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
    await t.pumpWidget(const MaterialApp(home: Scaffold(body: ProfileTab())));
    // Profile embeds FutureBuilder/looping-skeleton children -> advance a
    // fixed slice, NEVER pumpAndSettle (it would hang; session-craft §11).
    await t.pump(const Duration(milliseconds: 300));
  }

  testWidgets('renders at 360px with no overflow (guest)', (tester) async {
    await pumpTab(tester);
    expect(tester.takeException(), isNull); // a RenderFlex overflow auto-fails
    expect(find.text('Learner'), findsOneWidget); // guest display name
    expect(find.text('English Score'), findsOneWidget); // moved _englishScoreCard
  });

  testWidgets('is a no-back-header tab body (no RatelScaffold/AppBar)',
      (tester) async {
    await pumpTab(tester);
    expect(find.byType(AppBar), findsNothing);
    expect(find.byType(BackButton), findsNothing);
  });
}
