import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ratel/widgets/empty_state.dart';
import 'package:ratel/widgets/error_state.dart';
import 'package:ratel/widgets/ratel_mascot.dart';
import 'package:ratel/widgets/skeleton.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Phase 0.2 (Standardization Master Plan, Pillar A): the data-screen state
/// trio. Confirms loading (skeleton) + empty (RatelEmptyState) primitives
/// exist and renders the NEW ErrorState (message + retry). A RenderFlex
/// overflow fails the narrow-width test automatically.
void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  Widget host(Widget child) => MaterialApp(home: Scaffold(body: child));

  testWidgets('ErrorState renders mascot, title, message and a retry button',
      (tester) async {
    await tester.pumpWidget(host(ErrorState(onRetry: () {})));
    await tester.pump();
    expect(find.byType(RatelMascot), findsOneWidget);
    expect(find.text('Something went wrong'), findsOneWidget);
    expect(find.textContaining('another try'), findsOneWidget);
    expect(find.widgetWithText(FilledButton, 'Try again'), findsOneWidget);
  });

  testWidgets('ErrorState retry button fires the callback', (tester) async {
    var tries = 0;
    await tester.pumpWidget(host(ErrorState(onRetry: () => tries++)));
    await tester.pump();
    await tester.tap(find.widgetWithText(FilledButton, 'Try again'));
    expect(tries, 1);
  });

  testWidgets('ErrorState accepts custom copy', (tester) async {
    await tester.pumpWidget(host(ErrorState(
        title: 'No connection',
        message: 'Check your network.',
        retryLabel: 'Retry',
        onRetry: () {})));
    await tester.pump();
    expect(find.text('No connection'), findsOneWidget);
    expect(find.widgetWithText(FilledButton, 'Retry'), findsOneWidget);
  });

  testWidgets('ErrorState: no overflow at 320px with long copy',
      (tester) async {
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(host(ErrorState(
        title: 'A longer error headline that should wrap cleanly on a phone',
        message:
            'A longer explanatory sentence that must wrap without any overflow at a narrow phone width.',
        onRetry: () {})));
    await tester.pump();
  });

  testWidgets('state trio: skeleton + empty primitives still render',
      (tester) async {
    await tester.pumpWidget(host(ListView(children: const [
      SkeletonList(rows: 2),
      RatelEmptyState(title: 'Nothing here', subtitle: 'Add something.'),
    ])));
    await tester.pump();
    expect(find.byType(SkeletonBox), findsWidgets);
    expect(find.text('Nothing here'), findsOneWidget);
  });
}
