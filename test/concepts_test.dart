import 'package:flutter_test/flutter_test.dart';
import 'package:ratel/concepts.dart';

void main() {
  ConceptEntry e(String id, String? art, Map<String, String> terms) =>
      ConceptEntry(id, art, terms);

  final entries = [
    e('concept:apple', 'mk_apples', {'en': 'apple', 'ta': 'ஆப்பிள்'}),
    e('concept:bread', 'mk_bread', {'en': 'bread'}), // EN live; ta = owner-QA
    e('concept:park', null, {'en': 'park', 'ta': 'பூங்கா'}), // meaning, no art
  ];

  group('pure helpers', () {
    test('conceptStem folds a trailing plural s', () {
      expect(conceptStem('apples'), 'apple');
      expect(conceptStem('bus'), 'bus'); // len<=3 untouched
      expect(conceptStem('park'), 'park');
    });
    test('conceptClean lowercases + strips non-letters', () {
      expect(conceptClean('Apple,'), 'apple');
      expect(conceptClean("don't"), 'dont');
      expect(conceptClean('123'), '');
    });
    test('buildEnTermIndex keys by raw + stem', () {
      final idx = buildEnTermIndex(entries);
      expect(idx['apple'], 'concept:apple');
      expect(idx['bread'], 'concept:bread');
      expect(idx['park'], 'concept:park');
    });
  });

  group('lookupConcept', () {
    final idx = buildEnTermIndex(entries);
    final byId = {for (final c in entries) c.id: c};

    test('plural tap resolves to the singular concept + art + meaning', () {
      final hit = lookupConcept('apples', idx, byId, meaningLang: 'ta');
      expect(hit, isNotNull);
      expect(hit!.id, 'concept:apple');
      expect(hit.artName, 'mk_apples');
      expect(hit.hasArt, isTrue);
      expect(hit.meaning, 'ஆப்பிள்');
      expect(hit.hasMeaning, isTrue);
    });
    test('case + punctuation are ignored', () {
      expect(lookupConcept('Apple!', idx, byId)?.id, 'concept:apple');
    });
    test('meaningLang en yields no self-gloss, picture still shows', () {
      final hit = lookupConcept('apple', idx, byId, meaningLang: 'en');
      expect(hit!.hasMeaning, isFalse);
      expect(hit.hasArt, isTrue);
    });
    test('art but no ta term -> picture only (graceful)', () {
      final hit = lookupConcept('bread', idx, byId, meaningLang: 'ta');
      expect(hit!.hasArt, isTrue);
      expect(hit.hasMeaning, isFalse);
    });
    test('meaning but no art -> meaning only (graceful)', () {
      final hit = lookupConcept('park', idx, byId, meaningLang: 'ta');
      expect(hit!.hasArt, isFalse);
      expect(hit.hasMeaning, isTrue);
      expect(hit.meaning, 'பூங்கா');
    });
    test('unknown / empty word -> null', () {
      expect(lookupConcept('zebra', idx, byId), isNull);
      expect(lookupConcept('', idx, byId), isNull);
    });
  });

  group('Concepts singleton', () {
    test('debugSet builds an index lookups can use, default meaningLang ta', () {
      Concepts.instance.debugSet(entries);
      final hit = Concepts.instance.lookup('apples');
      expect(hit?.id, 'concept:apple');
      expect(hit?.artName, 'mk_apples');
      expect(hit?.meaning, 'ஆப்பிள்');
      expect(Concepts.instance.lookup('park')?.meaning, 'பூங்கா');
    });
    test('empty index -> null (offline-first graceful)', () {
      Concepts.instance.debugSet(const []);
      expect(Concepts.instance.lookup('apple'), isNull);
    });
  });
}
