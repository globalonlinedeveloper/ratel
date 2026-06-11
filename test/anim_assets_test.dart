import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('all 25 mascot action loops ship, rebuilt by assembler v2', () {
    const actions = [
      'jump', 'perfect', 'karate', 'listening', 'crying', 'dustoff',
      'flex', 'trophy', 'thumbsup', 'sleeping', 'morningstretch',
      'medalbite', 'tired', 'shrugok', 'digging', 'honeyjar',
      'snakestare', 'headphones', 'gradcap', 'partyhat', 'teacher',
      'nod', 'fistpump', 'wink', 'walk',
    ];
    for (final a in actions) {
      final f = File('assets/images/ratel-$a-anim.webp');
      expect(f.existsSync(), isTrue, reason: '$a loop missing');
      expect(f.lengthSync(), greaterThan(10000),
          reason: '$a loop suspiciously small');
    }
  });
}
