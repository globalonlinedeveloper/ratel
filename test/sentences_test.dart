import 'package:flutter_test/flutter_test.dart';
import 'package:ratel/sentences.dart';
import 'package:ratel/locales.dart';

// Inc 202 -- the curated example-sentence reuse layer. ingest() is the pure,
// network-free core; meanings resolve through the locale fallback chain.
void main() {
  tearDown(() => Locales.instance.debugSetFallback(const {}));

  test('sentenceUnitOf + unitOfLessonId parse their ids', () {
    expect(sentenceUnitOf('sent:u1.how-are-you'), 'u1');
    expect(sentenceUnitOf('sent:u11.it-is-snowing'), 'u11');
    expect(sentenceUnitOf('bogus'), '');
    expect(unitOfLessonId('u1l1'), 'u1');
    expect(unitOfLessonId('u11l5'), 'u11');
    expect(unitOfLessonId('review-x'), '');
  });

  test('ingest groups by unit, requires an English anchor, sorts by id', () {
    Sentences.instance.ingest(<Map<String, dynamic>>[
      {'meaning_id': 'sent:u1.how-are-you', 'lang': 'en', 'text': 'How are you?'},
      {'meaning_id': 'sent:u1.how-are-you', 'lang': 'ta', 'text': 'eppadi'},
      {'meaning_id': 'sent:u1.i-eat-an-apple', 'lang': 'en', 'text': 'I eat an apple.'},
      {'meaning_id': 'sent:u1.no-anchor', 'lang': 'ta', 'text': 'x'},
      {'meaning_id': 'sent:u2.good-night', 'lang': 'en', 'text': 'Good night.'},
    ]);
    expect(Sentences.instance.forUnit('u1').map((e) => e.meaningId).toList(),
        ['sent:u1.how-are-you', 'sent:u1.i-eat-an-apple']);
    expect(Sentences.instance.forUnit('u1').first.en, 'How are you?');
    expect(Sentences.instance.forUnit('u2').single.en, 'Good night.');
    expect(Sentences.instance.forUnit('u9'), isEmpty);
  });

  test('sentenceMeaning: native, fallback chain, EN self-gloss = null', () {
    Locales.instance.debugSetFallback({'es-US': 'es', 'es': 'en'});
    Sentences.instance.ingest(<Map<String, dynamic>>[
      {'meaning_id': 'sent:u1.how-are-you', 'lang': 'en', 'text': 'How are you?'},
      {'meaning_id': 'sent:u1.how-are-you', 'lang': 'ta', 'text': 'eppadi'},
      {'meaning_id': 'sent:u1.how-are-you', 'lang': 'es', 'text': 'como estas'},
    ]);
    final s = Sentences.instance.forUnit('u1').single;
    expect(sentenceMeaning(s, 'ta'), 'eppadi');
    expect(sentenceMeaning(s, 'es-US'), 'como estas');
    expect(sentenceMeaning(s, 'en'), isNull);
    expect(sentenceMeaning(s, 'de'), isNull);
  });
}
