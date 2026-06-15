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

  // ---- Phase 2.2: per-type answer-safe source ----
  test('choice IS illustrated from its sentence (the stimulus)', () {
    const ex = Exercise.choice(
        prompt: 'Pick the colour',
        sentence: 'I see an apple',
        options: ['red', 'green'],
        correctIndex: 0);
    expect(exerciseArt(ex, vocab), 'mk_apples');
  });

  test('choice is NEVER illustrated from its options (answer field)', () {
    // object word lives only in the OPTIONS, not the visible sentence.
    const ex = Exercise.choice(
        prompt: 'Pick the food',
        sentence: 'Which one can you eat?',
        options: ['apple', 'rock'],
        correctIndex: 0);
    expect(exerciseArt(ex, vocab), isNull);
  });

  test('choice without a sentence -> null (nothing safe to show)', () {
    const ex = Exercise.choice(
        prompt: 'Pick apple', options: ['apple', 'bread'], correctIndex: 0);
    expect(exerciseArt(ex, vocab), isNull);
  });

  test('typed: illustrated from its sentence, not the accepted answer', () {
    const ex = Exercise.typed(
        prompt: 'Type it', sentence: 'Pass the whisk', accepted: ['ok']);
    expect(exerciseArt(ex, vocab), 'kt_whisk');
    const ans = Exercise.typed(
        prompt: 'Name the tool', sentence: 'What stirs batter?',
        accepted: ['whisk']);
    expect(exerciseArt(ans, vocab), isNull); // answer not revealed
  });

  test('chat: illustrated from the npc line', () {
    const ex = Exercise.chat(
        prompt: 'Reply', npcLine: 'Do you like apples?', accepted: ['yes']);
    expect(exerciseArt(ex, vocab), 'mk_apples');
  });

  test('dialogueOrder: illustrated from the lines (order not revealed)', () {
    const ex = Exercise.dialogueOrder(
        prompt: 'Order it',
        lines: ['Hand me the whisk', 'Thanks'],
        correctOrder: ['Hand me the whisk', 'Thanks']);
    expect(exerciseArt(ex, vocab), 'kt_whisk');
  });

  test('multiBlank: from the template, never the blank answers', () {
    const shown = Exercise.multiBlank(
        prompt: 'Fill', template: 'The apple is ___',
        options: ['red'], answers: ['red']);
    expect(exerciseArt(shown, vocab), 'mk_apples');
    const hidden = Exercise.multiBlank(
        prompt: 'Fill', template: 'I eat an ___',
        options: ['apple'], answers: ['apple']);
    expect(exerciseArt(hidden, vocab), isNull); // object only in the blank
  });

  test('listen / listenRespond are audio-first -> never illustrated', () {
    const l = Exercise.listen(prompt: 'Type it', accepted: ['apple']);
    const lr = Exercise.listenRespond(
        prompt: 'Answer', say: 'Pass the whisk',
        options: ['ok', 'no'], correctIndex: 0);
    expect(exerciseArt(l, vocab), isNull);
    expect(exerciseArt(lr, vocab), isNull);
  });

  test('no object word -> null; empty vocab -> null', () {
    const ex = Exercise.wordBank(
        prompt: 'x', options: ['the', 'and', 'you'],
        correctOrder: ['you', 'and', 'the']);
    expect(exerciseArt(ex, vocab), isNull);
    expect(exerciseArt(ex, const {}), isNull);
  });
}
