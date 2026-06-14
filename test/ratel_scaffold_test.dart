import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ratel/app_state.dart';
import 'package:ratel/screens/friends_screen.dart';
import 'package:ratel/screens/paywall_screen.dart';
import 'package:ratel/screens/report_queue_screen.dart';
import 'package:ratel/widgets/ratel_scaffold.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Phase 0.1 (Standardization Master Plan, Pillar A): the RatelScaffold
/// primitive and its first two adoptions (report_queue, friends).
/// Covers the header (title + back/close render), the optional bottom
/// action bar, and a narrow-width layout gauntlet — a RenderFlex overflow
/// fails these tests automatically.
void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    appState.reset();
    appState.hearts = 5;
  });

  Widget host(Widget child) => MaterialApp(home: child);

  testWidgets('renders the title in the app-bar header', (tester) async {
    await tester.pumpWidget(
        host(const RatelScaffold(title: 'Settings', body: SizedBox.shrink())));
    expect(find.widgetWithText(AppBar, 'Settings'), findsOneWidget);
  });

  testWidgets('shows the back button on a pushed route', (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: Builder(
          builder: (c) => Center(
            child: TextButton(
              onPressed: () => Navigator.of(c).push(MaterialPageRoute(
                  builder: (_) => const RatelScaffold(
                      title: 'Pushed', body: SizedBox.shrink()))),
              child: const Text('go'),
            ),
          ),
        ),
      ),
    ));
    await tester.tap(find.text('go'));
    await tester.pumpAndSettle();
    expect(find.widgetWithText(AppBar, 'Pushed'), findsOneWidget);
    expect(find.byType(BackButton), findsOneWidget);
  });

  testWidgets('onClose renders a Close button instead of back and fires it',
      (tester) async {
    var closed = false;
    await tester.pumpWidget(host(RatelScaffold(
        title: 'Modal',
        onClose: () => closed = true,
        body: const SizedBox.shrink())));
    expect(find.byTooltip('Close'), findsOneWidget);
    expect(find.byType(BackButton), findsNothing);
    await tester.tap(find.byTooltip('Close'));
    expect(closed, isTrue);
  });

  testWidgets('renders a persistent bottom action bar when provided',
      (tester) async {
    await tester.pumpWidget(host(RatelScaffold(
        title: 'X',
        body: const SizedBox.shrink(),
        bottomBar:
            FilledButton(onPressed: () {}, child: const Text('Continue')))));
    expect(find.widgetWithText(FilledButton, 'Continue'), findsOneWidget);
  });

  testWidgets('layout gauntlet: no overflow at 320px (long title + actions)',
      (tester) async {
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(host(RatelScaffold(
      title: 'A rather long header title that might overflow a narrow phone',
      actions: const [Icon(Icons.search), Icon(Icons.more_vert)],
      bottomBar:
          FilledButton(onPressed: () {}, child: const Text('Primary action')),
      body: ListView(
        children: const [
          Padding(padding: EdgeInsets.all(16), child: Text('content')),
        ],
      ),
    )));
    await tester.pump();
  });

  testWidgets('report queue is wrapped in RatelScaffold and lists groups (320px)',
      (tester) async {
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(host(const ReportQueueScreen(rowsOverride: [
      {'lesson_id': 'u1l1', 'exercise_index': 0, 'reason': 'Typo'},
    ])));
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.byType(RatelScaffold), findsOneWidget);
    expect(find.widgetWithText(AppBar, 'Report queue'), findsOneWidget);
    expect(find.textContaining('u1l1:0'), findsOneWidget);
  });

  testWidgets('friends is wrapped in RatelScaffold (360px, no overflow)',
      (tester) async {
    tester.view.physicalSize = const Size(360, 690);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(host(const FriendsScreen()));
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.byType(RatelScaffold), findsOneWidget);
  });

  testWidgets('paywall is wrapped in RatelScaffold (360px, no overflow)',
      (tester) async {
    tester.view.physicalSize = const Size(360, 760);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(host(const PaywallScreen()));
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.byType(RatelScaffold), findsOneWidget);
    expect(find.widgetWithText(AppBar, 'Ratel Pro'), findsOneWidget);
  });
}
