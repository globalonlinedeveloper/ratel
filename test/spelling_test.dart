import 'package:flutter_test/flutter_test.dart';
import 'package:ratel/exercise_kit.dart';
import 'package:ratel/models.dart';
import 'package:ratel/spelling.dart';
import 'package:ratel/typed_match.dart';

/// Part B (W1): the pure canonicalize() answer-checker. Spelling/vocab variants
/// match (full credit); real typos do NOT (no fuzzy/edit-distance). A kind,
/// locale-aware tip fires only cross-variant.
void main() {
  group('canonicalizeWord — variants collapse to one canonical token', () {
    test('curated US/UK pairs are equal', () {
      expect(canonicalizeWord('colour'), canonicalizeWord('color'));
      expect(canonicalizeWord('favourite'), canonicalizeWord('favorite'));
      expect(canonicalizeWord('centre'), canonicalizeWord('center'));
      expect(canonicalizeWord('travelling'), canonicalizeWord('traveling'));
      expect(canonicalizeWord('realise'), canonicalizeWord('realize'));
      expect(canonicalizeWord('grey'), canonicalizeWord('gray'));
    });
    test('rule fallback handles unlisted variants', () {
      expect(canonicalizeWord('rumour'), 'rumor'); // -our/-or
      expect(canonicalizeWord('criticise'), 'criticize'); // -ise/-ize
      expect(canonicalizeWord('litre'), 'liter'); // map, but proves -re intent
      expect(canonicalizeWord('calibre'), 'caliber'); // -re/-er rule
      expect(canonicalizeWord('signalling'), 'signaling'); // -lling rule
    });
  });

  group('NOT fuzzy — real typos and non-variant words stay distinct', () {
    test('a dropped/extra letter typo is still wrong', () {
      expect(canonicalizeWord('collor') == canonicalizeWord('color'), false);
      expect(canonicalizeWord('helo') == canonicalizeWord('hello'), false);
    });
    test('non-variant -ise words are not mangled (exercise/noise/raise)', () {
      expect(canonicalizeWord('exercise'), 'exercise');
      expect(canonicalizeWord('noise'), 'noise');
      expect(canonicalizeWord('raise'), 'raise');
      // so a typo against them is rejected:
      expect(canonicalizeWord('exercize') == canonicalizeWord('exercise'), false);
    });
    test('doubled-l base verbs (fill/call/spell) are never collapsed', () {
      expect(canonicalizeWord('filling'), 'filling');
      expect(canonicalizeWord('calling'), 'calling');
      // crucially filling != filing (would be a teaching failure)
      expect(canonicalizeWord('filling') == canonicalizeWord('filing'), false);
    });
  });

  group('typedAnswerMatches — variant accept, typo reject, vocab accept', () {
    test('US/UK spelling both accepted, both directions', () {
      expect(typedAnswerMatches('colour', ['color']), true);
      expect(typedAnswerMatches('color', ['colour']), true);
      expect(typedAnswerMatches('I like colour', ['I like color']), true);
    });
    test('a real typo is rejected', () {
      expect(typedAnswerMatches('collor', ['color']), false);
      expect(typedAnswerMatches('exercize', ['exercise']), false);
    });
    test('vocab synonyms accepted (default allow-list)', () {
      expect(typedAnswerMatches('lift', ['elevator']), true);
      expect(typedAnswerMatches('flat', ['apartment']), true);
    });
    test('existing lenient behavior preserved', () {
      expect(typedAnswerMatches('Hello!', ['hello']), true);
      expect(typedAnswerMatches('The shop.', ['shop']), true);
    });
  });

  group('orderCanonMatches — tile lists, order preserved, spelling tolerant',
      () {
    test('variant tile matches; wrong order/length does not', () {
      expect(orderCanonMatches(['I', 'like', 'colour'], ['I', 'like', 'color']),
          true);
      expect(orderCanonMatches(['like', 'I', 'color'], ['I', 'like', 'color']),
          false);
      expect(orderCanonMatches(['cat'], ['the', 'cat']), false);
    });
  });

  group('spellingTip — kind, locale-aware, only cross-variant', () {
    test('names the learner-locale preferred form, both directions', () {
      expect(spellingTip('colour', 'color', 'en'),
          'In US English it\'s "color".');
      expect(spellingTip('color', 'colour', 'en-GB'),
          'In British English it\'s "colour".');
      expect(spellingTip('color', 'colour', 'en-IN'),
          'In Indian English it\'s "colour".');
    });
    test('vocab synonyms get a tip too', () {
      expect(spellingTip('lift', 'elevator', 'en'),
          'In US English it\'s "elevator".');
    });
    test('no tip when the form already matches the locale, or no variant', () {
      expect(spellingTip('color', 'color', 'en'), isNull);
      expect(spellingTip('colour', 'colour', 'en-GB'), isNull);
      expect(spellingTip('hello', 'hello', 'en'), isNull);
      expect(spellingTip('', 'color', 'en'), isNull);
    });
  });

  group('gradeAnswer wiring (typed + word-bank)', () {
    const typed = Exercise.typed(prompt: 'p', accepted: ['color']);
    const bank = Exercise.wordBank(
        prompt: 'p', options: ['colour', 'I', 'like'],
        correctOrder: ['I', 'like', 'color']);
    test('typed accepts the variant, rejects the typo', () {
      expect(gradeAnswer(typed, typed: 'colour'), true);
      expect(gradeAnswer(typed, typed: 'collor'), false);
    });
    test('word-bank accepts a variant tile in the right order', () {
      expect(gradeAnswer(bank, pickedWords: ['I', 'like', 'colour']), true);
      expect(gradeAnswer(bank, pickedWords: ['colour', 'I', 'like']), false);
    });
  });
}
