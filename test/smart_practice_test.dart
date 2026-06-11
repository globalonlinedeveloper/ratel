import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ratel/app_state.dart';
import 'package:ratel/milestones.dart';
import 'package:ratel/widgets/smart_practice.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    appState.reset();
    appState.hearts = 5;
  });

  test('composeDrill prioritizes, dedupes and caps', () {
    final out = composeDrill(
      due: ['a', 'b'],
      mistakes: ['b', 'c', ''],
      weak: ['d', 'e', 'f', 'g', 'h'],
      cap: 6,
    );
    expect(out, ['a', 'b', 'c', 'd', 'e', 'f']); // order + dedupe + cap
    expect(composeDrill(due: [], mistakes: [], weak: []), isEmpty);
  });

  testWidgets('Smart practice assembles and opens a review drill',
      (tester) async {
    await tester.pumpWidget(const MaterialApp(
        home: Scaffold(
            body: SmartPracticeCard(
                keysOverride: ['u1l1:0', 'u1l1:1', 'u1l2:0']))));
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('Smart practice'), findsOneWidget);
    expect(find.textContaining('3 items picked'), findsOneWidget);
    await tester.tap(find.text('Start'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 700));
    expect(find.text('Check'), findsOneWidget); // the drill opened
    expect(find.text('1/3'), findsOneWidget); // all three resolved
    await tester.pump(const Duration(seconds: 1));
  });
}
