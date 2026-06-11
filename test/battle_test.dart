import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/services.dart';
import 'package:ratel/theme.dart';
import 'package:ratel/widgets/battle_stage.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('battle controller maps events to duel beats', () {
    final c = BattleController();
    c.fire(BattleEvent.correct, combo: 2);
    expect(c.ratel, RatelBattleState.swipe);
    expect(c.cobra, CobraState.recoil);
    c.settle();
    expect(c.ratel, RatelBattleState.guard);
    c.fire(BattleEvent.finisher, combo: 5);
    expect(c.ratel, RatelBattleState.karate);
    expect(c.cobra, CobraState.dizzy);
    c.settle();
    c.fire(BattleEvent.wrong, combo: 0);
    expect(c.cobra, CobraState.strike);
    c.fire(BattleEvent.victory);
    expect(c.over, isTrue);
    expect(c.cobra, CobraState.defeated);
    c.settle(); // over: settle must not reset the ending
    expect(c.cobra, CobraState.defeated);
  });

  test('all battle assets are bundled', () async {
    for (final side in [
      'cobra', 'boss', 'scorpion', 'bees', 'jackal', 'vulture',
      'frostgolem', 'pumpkincrow', 'firecrackerimp'
    ]) {
      for (final st in [
        'idle', 'taunt', 'strike', 'recoil', 'dizzy', 'defeated'
      ]) {
        final d =
            await rootBundle.load('assets/battle/${side}_$st.webp');
        expect(d.lengthInBytes, greaterThan(5000), reason: '$side $st');
      }
    }
    for (final st in [
      'guard1', 'guard2', 'swipe1', 'swipe2', 'stagger1', 'stagger2'
    ]) {
      final d = await rootBundle.load('assets/battle/ratel_$st.webp');
      expect(d.lengthInBytes, greaterThan(5000), reason: st);
    }
  });

  testWidgets('battle stage renders and survives a full duel',
      (tester) async {
    reduceMotionNotifier.value = true; // freeze sway for the test
    final c = BattleController();
    await tester.pumpWidget(MaterialApp(
        home: Scaffold(body: BattleStage(controller: c))));
    expect(find.byType(Image), findsNWidgets(2));
    for (final e in [
      BattleEvent.correct, BattleEvent.wrong,
      BattleEvent.finisher, BattleEvent.victory
    ]) {
      c.fire(e, combo: 3);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));
    }
    expect(tester.takeException(), isNull);
    reduceMotionNotifier.value = false;
  });
}
