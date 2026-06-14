import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ratel/widgets/leagues_board.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Inc 173 (Standardization Master Plan, Phase 1): the Leagues tab body
/// (LeaguesBoard) token/a11y migration — RatelSpacing exact-match swaps + the
/// promotion-zone trophy mascot wrapped in ExcludeSemantics (already hex-clean
/// -> added to the tokens_test allowlist). With no Supabase client in a widget
/// test, the [_client] getter returns null and the signed-out branch renders;
/// this is the first dedicated 360px gauntlet for the widget.
void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('renders at 360px with no overflow (signed-out branch)',
      (tester) async {
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: LeaguesBoard())));
    // A signed-in load shows a looping SkeletonList -> advance a fixed slice,
    // never pumpAndSettle (Inc 164 gotcha). Offline it renders synchronously.
    await tester.pump(const Duration(milliseconds: 300));
    expect(tester.takeException(), isNull); // a RenderFlex overflow auto-fails
    expect(find.text('Sign in to join a league.'), findsOneWidget);
  });
}
