import 'package:flutter_test/flutter_test.dart';
import 'flow_harness.dart';

/// Tap-to-define: highlighted words in Stories & Video open the define sheet.
void main() {
  testWidgets('Stories: tap "into" opens the define sheet', (tester) async {
    await pumpFlow(tester, '/stories');
    await tester.tap(find.text('into'));
    await tester.pumpAndSettle();
    expect(find.text('Add to flashcards'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Video: tap "train" opens the define sheet', (tester) async {
    await pumpFlow(tester, '/video');
    await tester.tap(find.text('train'));
    await tester.pumpAndSettle();
    expect(find.text('Add to flashcards'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
