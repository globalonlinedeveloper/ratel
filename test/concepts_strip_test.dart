import 'package:flutter_test/flutter_test.dart';
import 'package:ratel/models.dart';
import 'package:ratel/exercise_art.dart';

// Inc 159 — the completion "concepts you practiced" recap. lessonConcepts()
// collects the deduped, in-order object-art cells touched anywhere in a
// FINISHED lesson (every exercise type, all content text — no answer left to
// reveal once the lesson is done), restricted to the object theme sets.
void main() {
  final paths = {
    'mk_apples': 'mk/mk_apples.webp',
    'kt_whisk': 'kt/kt_whisk.webp',
    'tr_suitcase': 'tr/tr_suitcase.webp',
    'md_stethoscope': 'md/md_stethoscope.webp',
    'emo_proud': 'emotions/emo_proud.webp', // mascot set -> excluded
  };
  final vocab = buildVocab(paths);

  test('collects deduped, in-order object concepts across the whole lesson', () {
    const lesson = <Exercise>[
      Exercise.choice(
          prompt: 'Pick the fruit',
          options: ['apple', 'car'],
          correctIndex: 0),
      Exercise.wordBank(
          prompt: 'Build it',
          options: ['I', 'pack', 'a', 'suitcase'],
          correctOrder: ['I', 'pack', 'a', 'suitcase']),
      Exercise.matchPairs(
          prompt: 'Match', left: ['whisk'], right: ['kitchen']),
    ];
    expect(lessonConcepts(lesson, vocab),
        ['mk_apples', 'tr_suitcase', 'kt_whisk']);
  });

  test('scans unsafe types too — finished lesson, no answer to reveal', () {
    // A choice item is never illustrated MID-lesson (exerciseArt = safe types
    // only) but DOES contribute its object to the post-lesson recap.
    const choice = Exercise.choice(
        prompt: 'x', options: ['stethoscope', 'spoon'], correctIndex: 0);
    expect(exerciseArt(choice, vocab), isNull);
    expect(lessonConcepts([choice], vocab), ['md_stethoscope']);
  });

  test('dedupes repeats, keeps first-seen order', () {
    const lesson = <Exercise>[
      Exercise.typed(prompt: 'x', accepted: ['an apple']),
      Exercise.wordBank(
          prompt: 'y', options: ['apple'], correctOrder: ['apple']),
    ];
    expect(lessonConcepts(lesson, vocab), ['mk_apples']);
  });

  test('caps the result at max', () {
    const lesson = <Exercise>[
      Exercise.wordBank(
          prompt: 'x',
          options: ['apple', 'whisk', 'suitcase', 'stethoscope'],
          correctOrder: ['apple', 'whisk', 'suitcase', 'stethoscope']),
    ];
    expect(lessonConcepts(lesson, vocab, max: 2), ['mk_apples', 'kt_whisk']);
  });

  test('no object words / empty vocab / empty lesson -> []', () {
    const greetings = <Exercise>[
      Exercise.wordBank(
          prompt: 'x',
          options: ['hello', 'how', 'you'],
          correctOrder: ['hello', 'how', 'you']),
    ];
    expect(lessonConcepts(greetings, vocab), isEmpty);
    expect(lessonConcepts(greetings, const {}), isEmpty);
    expect(lessonConcepts(const <Exercise>[], vocab), isEmpty);
  });

  test('object sets only — mascot/UI cells never surface in the recap', () {
    // 'proud' would map to emo_proud IF the mascot set fed the vocab; it does
    // not, so only the object word 'apple' surfaces.
    const lesson = <Exercise>[
      Exercise.typed(prompt: 'x', accepted: ['proud apple']),
    ];
    expect(lessonConcepts(lesson, vocab), ['mk_apples']);
  });
}
