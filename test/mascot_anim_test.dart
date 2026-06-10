import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ratel/theme.dart';
import 'package:ratel/widgets/mascot_anim.dart';
import 'package:ratel/widgets/ratel_mascot.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('all animated mascot assets are bundled and non-trivial', () async {
    for (final name in [
      'ratel-jump.webp',
      'ratel-karate-anim.webp',
      'ratel-crying-anim.webp',
      'ratel-sleeping-anim.webp',
      'ratel-thumbsup-anim.webp',
      'ratel-perfect-anim.webp',
      'ratel-tired-anim.webp',
      'ratel-listening-anim.webp',
      'ratel-flex-anim.webp',
      'ratel-trophy-anim.webp',
      'ratel-dustoff-anim.webp',
      'ratel-morningstretch-anim.webp',
      'ratel-digging-anim.webp',
      'ratel-medalbite-anim.webp',
      'ratel-teacher-anim.webp',
      'ratel-shrugok-anim.webp',
      'ratel-nod-anim.webp',
      'ratel-fistpump-anim.webp',
    ]) {
      final data = await rootBundle.load('assets/images/$name');
      expect(data.lengthInBytes, greaterThan(20000), reason: name);
    }
  });

  test('all puppet parts are bundled', () async {
    for (final name in [
      'body', 'head_neutral', 'head_blink', 'head_talk',
      'arm_left', 'arm_right', 'tail',
    ]) {
      final data = await rootBundle.load('assets/puppet/$name.webp');
      expect(data.lengthInBytes, greaterThan(3000), reason: name);
    }
  });

  testWidgets('RatelActionAnim renders the animated asset', (tester) async {
    reduceMotionNotifier.value = false;
    await tester.pumpWidget(const MaterialApp(
        home: RatelActionAnim(
            action: 'thumbsup', fallbackPose: RatelPose.celebrate)));
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.byType(Image), findsOneWidget);
    expect(find.byType(RatelMascot), findsNothing);
  });

  testWidgets('RatelActionAnim falls back under reduce-motion',
      (tester) async {
    reduceMotionNotifier.value = true;
    await tester.pumpWidget(const MaterialApp(
        home: RatelActionAnim(
            action: 'thumbsup', fallbackPose: RatelPose.celebrate)));
    expect(find.byType(RatelMascot), findsOneWidget);
    reduceMotionNotifier.value = false;
  });
}
