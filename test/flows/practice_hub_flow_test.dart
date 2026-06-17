import 'package:flutter_test/flutter_test.dart';
import 'flow_harness.dart';

/// Practice hub: the smart-session card + all six tiles route correctly.
void main() {
  testWidgets('smart-session card -> smart practice', (tester) async {
    await pumpFlow(tester, '/practice');
    await tester.tap(find.text("Today's smart session"));
    await tester.pumpAndSettle();
    expect(find.text('Verb agreement'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('tile Smart practice -> smart practice', (tester) async {
    await pumpFlow(tester, '/practice');
    await tester.tap(find.text('Smart practice'));
    await tester.pumpAndSettle();
    expect(find.text('Verb agreement'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('tile Due review -> smart practice', (tester) async {
    await pumpFlow(tester, '/practice');
    await tester.tap(find.text('Due review · 12'));
    await tester.pumpAndSettle();
    expect(find.text('Verb agreement'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('tile Speaking -> speaking practice', (tester) async {
    await pumpFlow(tester, '/practice');
    await tester.tap(find.text('Speaking'));
    await tester.pumpAndSettle();
    expect(find.text('Say this sentence'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('tile Coach & call -> coach', (tester) async {
    await pumpFlow(tester, '/practice');
    await tester.tap(find.text('Coach & call'));
    await tester.pumpAndSettle();
    expect(find.text('AI tutor · remembers your sessions'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('tile Stories -> market story', (tester) async {
    await pumpFlow(tester, '/practice');
    await tester.tap(find.text('Stories'));
    await tester.pumpAndSettle();
    expect(find.text('At the market'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('tile Timed -> timed challenge', (tester) async {
    await pumpFlow(tester, '/practice');
    await tester.tap(find.text('Timed · Mistakes'));
    await tester.pumpAndSettle();
    expect(find.text('Timed challenge'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('tile Listening -> listening feed', (tester) async {
    await pumpFlow(tester, '/practice');
    await tester.tap(find.text('Listening'));
    await tester.pumpAndSettle();
    expect(find.text('Morning news, slowly'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
