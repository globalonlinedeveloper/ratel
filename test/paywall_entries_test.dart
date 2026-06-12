import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ratel/app_state.dart';
import 'package:ratel/screens/home_screen.dart';
import 'package:ratel/screens/paywall_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Inc 139 (QA #2 P4 — paywall reachability, owner: BOTH entry points).
/// Visibility is auth-independent by design: neither entry branches on
/// guest vs signed-in (only on isPro), so these tests cover both states;
/// the live tour re-verifies as a real guest AND a signed-in user.
void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    appState.reset();
    appState.loaded = true;
    appState.hearts = 5; // hearts-FULL — the state QA toured with no CTA
  });

  Future<void> pumpHome(WidgetTester t) async {
    await t.pumpWidget(const MaterialApp(home: HomeScreen()));
    await t.pump(const Duration(milliseconds: 800));
  }

  testWidgets(
      'hearts popover: kind upsell BELOW the practice option, opens paywall',
      (tester) async {
    await pumpHome(tester);
    await tester.tap(find.byKey(const Key('hearts_stat')));
    await tester.pump(const Duration(milliseconds: 400));

    final practice = find.text('Practice — earn a heart');
    final upsell = find.byKey(const Key('hearts_pro_upsell'));
    expect(practice, findsOneWidget);
    expect(upsell, findsOneWidget);
    expect(find.text('Ratel Pro — unlimited hearts'), findsOneWidget);
    // anti-goal guard: the upsell never replaces or precedes the
    // practice-earns-heart option — it sits strictly BELOW it.
    expect(tester.getTopLeft(upsell).dy > tester.getBottomLeft(practice).dy,
        isTrue);

    await tester.tap(upsell);
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.byType(PaywallScreen), findsOneWidget);
  });

  testWidgets('hearts popover: Pro user sees no upsell row', (tester) async {
    appState.isPro = true;
    await pumpHome(tester);
    await tester.tap(find.byKey(const Key('hearts_stat')));
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.byKey(const Key('hearts_pro_upsell')), findsNothing);
    expect(find.text('Unlimited hearts with Ratel Pro'), findsOneWidget);
  });

  testWidgets(
      'Profile Pro row: label-addressable button, opens paywall (non-Pro)',
      (tester) async {
    final handle = tester.ensureSemantics();
    await pumpHome(tester);
    await tester.tap(find.text('Profile'));
    await tester.pump(const Duration(milliseconds: 600));

    // the getByRole contract: addressable by accessible NAME
    expect(find.bySemanticsLabel(RegExp('Ratel Pro — unlimited hearts')),
        findsOneWidget);
    await tester.ensureVisible(find.byKey(const Key('pro_row')));
    await tester.pump(const Duration(milliseconds: 200));
    await tester.tap(find.byKey(const Key('pro_row')));
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.byType(PaywallScreen), findsOneWidget);
    handle.dispose();
  });

  testWidgets('Profile Pro row: active label when Pro', (tester) async {
    appState.isPro = true;
    await pumpHome(tester);
    await tester.tap(find.text('Profile'));
    await tester.pump(const Duration(milliseconds: 600));
    await tester.ensureVisible(find.byKey(const Key('pro_row')));
    await tester.pump(const Duration(milliseconds: 200));
    expect(find.text('Ratel Pro is active ✨'), findsOneWidget);
  });
}
