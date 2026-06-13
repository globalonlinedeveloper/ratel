import 'package:flutter_test/flutter_test.dart';
import 'package:ratel/score.dart';

void main() {
  // A tiny node universe: two A1 skills + one B1 skill.
  const bands = {
    'n.a1.alpha': 'A1',
    'n.a1.beta': 'A1',
    'n.b1.gamma': 'B1',
  };
  const lessonNode = {
    'l1': 'n.a1.alpha',
    'l2': 'n.a1.beta',
    'l3': 'n.b1.gamma',
  };
  List<({String key, bool correct})> att(String lesson, int correct, int wrong) =>
      [
        for (var i = 0; i < correct; i++) (key: '$lesson:0', correct: true),
        for (var i = 0; i < wrong; i++) (key: '$lesson:0', correct: false),
      ];

  test('MIN_ATTEMPTS gates an under-sampled node to 0', () {
    expect(nodeMastery(att('l1', 2, 0), lessonNode)['n.a1.alpha'], 0.0);
    expect(nodeMastery(att('l1', 3, 0), lessonNode)['n.a1.alpha'], 1.0);
  });

  test('mastery is the correct-rate once assessed', () {
    expect(nodeMastery(att('l1', 3, 1), lessonNode)['n.a1.alpha'],
        closeTo(0.75, 1e-9));
  });

  test('attempts on unmapped lessons are ignored', () {
    final t = nodeTallies(
        [(key: 'smart:0', correct: true), (key: 'l1:0', correct: true)],
        lessonNode);
    expect(t.length, 1);
    expect(t.containsKey('n.a1.alpha'), true);
  });

  test('un-attempted nodes count as 0 (breadth pressure)', () {
    // Only alpha mastered; beta + gamma untouched. weights 1+1+3=5 => 1/5=20.
    expect(nodeEnglishScore(nodeMastery(att('l1', 3, 0), lessonNode), bands), 20);
  });

  test('higher CEFR mastery is worth more', () {
    final a1 = nodeEnglishScore(nodeMastery(att('l1', 3, 0), lessonNode), bands);
    final b1 = nodeEnglishScore(nodeMastery(att('l3', 3, 0), lessonNode), bands);
    expect(b1, greaterThan(a1));
  });

  test('mastery beats sloppy completion, and full mastery = 100', () {
    final sloppy = nodeEnglishScore(
        nodeMastery([...att('l1', 1, 2), ...att('l2', 1, 2), ...att('l3', 1, 2)],
            lessonNode),
        bands);
    final mastered = nodeEnglishScore(
        nodeMastery([...att('l1', 3, 0), ...att('l2', 3, 0), ...att('l3', 3, 0)],
            lessonNode),
        bands);
    expect(mastered, greaterThan(sloppy));
    expect(mastered, 100);
  });

  test('score stays within 0..100, empty node set = 0', () {
    expect(nodeEnglishScore(const {}, const {}), 0);
    expect(nodeEnglishScore(nodeMastery(att('l1', 3, 0), lessonNode), bands),
        inInclusiveRange(0, 100));
  });

  test('weakNodes: assessed + below threshold, worst-first', () {
    final tallies = nodeTallies([
      ...att('l1', 1, 3), // alpha 1/4 = 0.25 (weak)
      ...att('l2', 3, 1), // beta 3/4 = 0.75 (ok)
      ...att('l3', 1, 4), // gamma 1/5 = 0.20 (weakest)
    ], lessonNode);
    final w = weakNodes(tallies);
    expect(w.first, 'n.b1.gamma'); // worst first
    expect(w.contains('n.a1.beta'), false); // not weak
    expect(w.contains('n.a1.alpha'), true);
  });

  test('an unassessed node is never called weak', () {
    final tallies = nodeTallies(att('l1', 0, 2), lessonNode); // 2 < MIN, all wrong
    expect(weakNodes(tallies), isEmpty);
  });

  test('nodeLabel humanizes a node id', () {
    expect(nodeLabel('node:gen.a1.past-simple'), 'Past simple');
    expect(nodeLabel('node:gen.b1.vocabulary'), 'Vocabulary');
  });

  test('weakNodeDrillKeys: worst-first nodes -> their lessons first exercises',
      () {
    // alpha 1/4=0.25 (weak), beta 3/4=0.75 (ok), gamma 1/5=0.20 (weakest).
    final tallies = nodeTallies([
      ...att('l1', 1, 3),
      ...att('l2', 3, 1),
      ...att('l3', 1, 4),
    ], lessonNode);
    const lessons = [
      (id: 'l1', len: 3),
      (id: 'l2', len: 1),
      (id: 'l3', len: 5),
    ];
    final keys = weakNodeDrillKeys(tallies, lessonNode, lessons);
    // gamma (worst) before alpha; beta (ok) excluded; <=2 exercises per lesson.
    expect(keys, ['l3:0', 'l3:1', 'l1:0', 'l1:1']);
  });

  test('weakNodeDrillKeys: many lessons per node, perLesson cap, unmapped skip',
      () {
    final tally = <String, ({int correct, int total})>{
      'n.x': (correct: 1, total: 5), // 0.20 -> weak
      'n.y': (correct: 5, total: 5), // strong -> excluded
    };
    const lessonNode2 = {'la': 'n.x', 'lb': 'n.x', 'lc': 'n.y'};
    const lessons = [
      (id: 'la', len: 2),
      (id: 'lb', len: 1),
      (id: 'lc', len: 9), // maps to a non-weak node -> contributes nothing
    ];
    final keys = weakNodeDrillKeys(tally, lessonNode2, lessons);
    expect(keys, ['la:0', 'la:1', 'lb:0']); // both weak-node lessons, cap honored
    expect(weakNodeDrillKeys(const {}, lessonNode2, lessons), isEmpty);
  });
}
