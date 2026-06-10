import 'package:flutter_test/flutter_test.dart';
import 'package:ratel/milestones.dart';

void main() {
  test('milestoneFor matches landmark days only', () {
    expect(milestoneFor(7), 7);
    expect(milestoneFor(30), 30);
    expect(milestoneFor(100), 100);
    expect(milestoneFor(365), 365);
    expect(milestoneFor(6), isNull);
    expect(milestoneFor(8), isNull);
    expect(milestoneFor(0), isNull);
  });

  test('pickReaction: ~1 in 4, never during hot combo', () {
    for (int roll = 0; roll < 12; roll++) {
      expect(pickReaction(9, roll), isNull); // karate owns combo >= 5
    }
    expect(pickReaction(2, 0), 'nod');
    expect(pickReaction(2, 1), 'fistpump');
    expect(pickReaction(2, 2), 'nod');
    for (int roll = 3; roll < 12; roll++) {
      expect(pickReaction(2, roll), isNull);
    }
  });
}
