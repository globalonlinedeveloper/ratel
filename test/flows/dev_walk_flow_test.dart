import 'package:flutter_test/flutter_test.dart';
import 'flow_harness.dart';

/// Dev gallery: the index "Walk the app" launcher opens the real entry (splash).
void main() {
  testWidgets('index Walk-the-app -> splash', (tester) async {
    await pumpFlow(tester, '/index');
    await tester.tap(
      find.text('Walk the app — Splash → Welcome → Auth → Home'),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.text('Be fearless in any language'), findsOneWidget);
    expect(tester.takeException(), isNull);
    // Let the splash auto-advance timer (1.5s) fire so no timer stays pending.
    await tester.pump(const Duration(milliseconds: 1200));
    await tester.pumpAndSettle();
  });
}
