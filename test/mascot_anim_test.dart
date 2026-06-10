import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ratel/theme.dart';
import 'package:ratel/widgets/mascot_anim.dart';
import 'package:ratel/widgets/ratel_mascot.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('all puppet parts are bundled', () async {
    for (final name in [
      'torso', 'leg_left', 'leg_right',
      'head_neutral', 'head_blink', 'head_talk',
      'arm_left', 'arm_right', 'tail',
    ]) {
      final data = await rootBundle.load('assets/puppet/$name.webp');
      expect(data.lengthInBytes, greaterThan(3000), reason: name);
    }
  });

  test('baked pose statics are bundled (the new base design)', () async {
    for (final pose in [
      'idle', 'wave', 'celebrate', 'encourage',
      'think', 'oops', 'speak', 'point',
    ]) {
      final data =
          await rootBundle.load('assets/images/ratel-$pose.webp');
      expect(data.lengthInBytes, greaterThan(8000), reason: pose);
    }
  });

  testWidgets('RatelActionAnim falls back under reduce-motion',
      (tester) async {
    reduceMotionNotifier.value = true;
    await tester.pumpWidget(const MaterialApp(
        home: RatelActionAnim(
            action: 'anything', fallbackPose: RatelPose.celebrate)));
    expect(find.byType(RatelMascot), findsOneWidget);
    reduceMotionNotifier.value = false;
  });

  testWidgets('RatelActionAnim with a missing asset never crashes',
      (tester) async {
    reduceMotionNotifier.value = false;
    await tester.pumpWidget(const MaterialApp(
        home: RatelActionAnim(
            action: 'does-not-exist', fallbackPose: RatelPose.oops)));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));
    expect(tester.takeException(), isNull);
  });
}
