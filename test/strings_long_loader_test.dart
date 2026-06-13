import 'package:flutter_test/flutter_test.dart';
import 'package:ratel/strings.dart';

// Inc 144 (Dataset P1) -- the S() loader now ingests long-format
// (key, locale, val) rows from app_strings. ingestRows is the pure,
// network-free core so the mapping is unit-tested directly.
void main() {
  setUp(() {
    S.instance.debugClear();
    S.instance.locale = 'en';
    S.instance.pseudo = false;
  });
  tearDown(() {
    S.instance.locale = 'en';
    S.instance.debugClear();
  });

  test('ingestRows builds key->locale->val; t() resolves; bad rows skipped',
      () {
    S.instance.ingestRows(<Map<String, dynamic>>[
      {'key': 'greet', 'locale': 'ta', 'val': 'வணக்கம்'},
      {'key': 'greet', 'locale': 'en', 'val': 'Hi'},
      {'key': 'only_ta', 'locale': 'ta', 'val': 'மட்டும்'},
      {'key': '', 'locale': 'en', 'val': 'skip-empty-key'},
      {'key': 'x', 'locale': '', 'val': 'skip-empty-locale'},
    ]);
    expect(S.instance.t('greet', 'def'), 'Hi'); // en value present
    S.instance.locale = 'ta';
    expect(S.instance.t('greet', 'def'), 'வணக்கம்');
    expect(S.instance.t('only_ta', 'def'), 'மட்டும்');
    S.instance.locale = 'en';
    // only_ta has no en row -> en empty -> falls to the in-code default
    expect(S.instance.t('only_ta', 'def-en'), 'def-en');
    // rows with empty key/locale were never registered
    expect(S.instance.t('x', 'fallback'), 'fallback');
  });

  test('repeated ingest merges; last value wins per (key, locale)', () {
    S.instance
        .ingestRows(<Map<String, dynamic>>[{'key': 'k', 'locale': 'ta', 'val': 'first'}]);
    S.instance
        .ingestRows(<Map<String, dynamic>>[{'key': 'k', 'locale': 'ta', 'val': 'second'}]);
    S.instance.locale = 'ta';
    expect(S.instance.t('k', 'd'), 'second');
  });

  test('EN remains the pivot: in-code default byte-identical when no override',
      () {
    expect(S.instance.t('untouched', 'Exactly This'), 'Exactly This');
  });
}
