import 'package:flutter_test/flutter_test.dart';
import 'flow_harness.dart';

/// Lesson loop: choice -> complete -> back into the shell.
void main() {
  testWidgets('lesson choice: Check -> lesson complete', (tester) async {
    await pumpFlow(tester, '/lesson/choice');
    await tester.tap(find.text('Check'));
    await tester.pumpAndSettle();
    expect(find.text('Lesson complete!'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('lesson complete: Continue -> Home shell', (tester) async {
    await pumpFlow(tester, '/complete');
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();
    expect(find.text('Unit 3 · Everyday phrases'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
