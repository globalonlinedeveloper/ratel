import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ratel/flags.dart';
import 'package:ratel/widgets/motd_card.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  test('flags fall back to defaults and parse set values', () {
    final f = Flags.instance;
    f.debugSet({});
    expect(f.flag('battle_default_on', true), isTrue);
    expect(f.intOf('xp_bonus_one_in', 5), 5);
    expect(f.str('motd', ''), '');
    f.debugSet(
        {'battle_default_on': 'false', 'xp_bonus_one_in': '9', 'motd': 'Hi'});
    expect(f.flag('battle_default_on', true), isFalse);
    expect(f.intOf('xp_bonus_one_in', 5), 9);
    expect(f.str('motd', ''), 'Hi');
    f.debugSet({});
  });

  testWidgets('MotdCard shows the motd and hides once dismissed',
      (tester) async {
    SharedPreferences.setMockInitialValues({});
    Flags.instance.debugSet({'motd': 'Season event this weekend!'});
    await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: MotdCard())));
    await tester.pumpAndSettle();
    expect(find.text('Season event this weekend!'), findsOneWidget);
    await tester.tap(find.byIcon(Icons.close));
    await tester.pumpAndSettle();
    expect(find.text('Season event this weekend!'), findsNothing);
    Flags.instance.debugSet({});
  });

  testWidgets('MotdCard renders nothing when no motd', (tester) async {
    SharedPreferences.setMockInitialValues({});
    Flags.instance.debugSet({});
    await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: MotdCard())));
    await tester.pumpAndSettle();
    expect(find.byType(Card), findsNothing);
  });
}
