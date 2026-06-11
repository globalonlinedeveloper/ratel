import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ratel/widgets/campaign_cards.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('campaignAction parses safely', () {
    expect(campaignAction('paywall').$1, 'paywall');
    expect(campaignAction('coach').$1, 'coach');
    expect(campaignAction('url:https://ratel.app'),
        ('url', 'https://ratel.app'));
    expect(campaignAction('url:javascript:alert(1)').$1, 'none');
    expect(campaignAction('rm -rf /').$1, 'none');
    expect(campaignAction('').$1, 'none');
  });

  testWidgets('campaign card renders, acts and dismisses', (tester) async {
    bool coached = false;
    const camp = Campaign(
        id: 7,
        title: 'Frost week!',
        body: 'Beat the golem.',
        button: 'Practice talking',
        action: 'coach');
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: CampaignCards(
            campaigns: const [camp], onCoach: () => coached = true),
      ),
    ));
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('Frost week!'), findsOneWidget);
    await tester.tap(find.text('Practice talking'));
    await tester.pump(const Duration(milliseconds: 100));
    expect(coached, isTrue);
    await tester.tap(find.byIcon(Icons.close));
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('Frost week!'), findsNothing);
  });
}
