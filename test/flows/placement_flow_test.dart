import 'package:flutter_test/flutter_test.dart';
import 'flow_harness.dart';

void main() {
  testWidgets('placement: answer all 5 sample steps -> level result',
      (tester) async {
    await pumpFlow(tester, '/onboarding/placement');

    const List<String> prompts = <String>[
      'Choose the correct word',
      'Pick the correct past tense',
      'Choose the right article',
      'Select the correct preposition',
      'Choose the best word',
    ];
    const List<String> firstOption = <String>[
      'goes',
      'watched',
      'an',
      'on',
      'interesting',
    ];

    for (int i = 0; i < prompts.length; i++) {
      expect(find.text(prompts[i]), findsOneWidget);
      expect(find.text('${i + 1} / 5'), findsOneWidget);
      await tester.tap(find.text(firstOption[i]));
      await tester.pumpAndSettle();
      final String cta = i == prompts.length - 1 ? 'See my level' : 'Next';
      await tester.tap(find.text(cta));
      await tester.pumpAndSettle();
    }

    expect(find.text("You're at A2 — Elementary"), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
