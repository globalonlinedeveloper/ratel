import 'package:flutter_test/flutter_test.dart';
import 'package:ratel/models.dart';
import 'package:ratel/exercise_art.dart';

void main() {
  final paths = {
    'mk_apples': 'mk/mk_apples.webp',
    'kt_whisk': 'kt/kt_whisk.webp',
    'md_stethoscope': 'md/md_stethoscope.webp',
    'emo_proud': 'emotions/emo_proud.webp', // mascot set -> excluded
  };
  final vocab = buildVocab(paths);

  test('buildVocab indexes only object sets, stemmed', () {
    expect(vocab['apple'], 'mk_apples'); // apples -> apple
    expect(vocab['whisk'], 'kt_whisk');
    expect(vocab.containsValue('emo_proud'), isFalse);
  });

  test('wordBank: a content word in the target sentence -> its art', () {
    const ex = Exercise.wordBank(
        prompt: 'Build the sentence',
        options: ['an', 'apple', 'eat', 'I'],
        correctOrder: ['I', 'eat', 'an', 'apple']);
    expect(exerciseArt(ex, vocab), 'mk_apples');
  });

  test('matchPairs: a left item maps to art', () {
    const ex = Exercise.matchPairs(
        prompt: 'Match', left: ['whisk', 'spoon'], right: ['a', 'b']);
    expect(exerciseArt(ex, vocab), 'kt_whisk');
  });

  test('unsafe types are never illustrated (no answer reveal)', () {
    const ex = Exercise.choice(
        prompt: 'Pick apple', options: ['apple', 'bread'], correctIndex: 0);
    expect(exerciseArt(ex, vocab), isNull);
  });

  test('no object word -> null; empty vocab -> null', () {
    const ex = Exercise.wordBank(
        prompt: 'x', options: ['the', 'and', 'you'],
        correctOrder: ['you', 'and', 'the']);
    expect(exerciseArt(ex, vocab), isNull);
    expect(exerciseArt(ex, const {}), isNull);
  });
}
