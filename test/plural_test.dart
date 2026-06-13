import 'package:flutter_test/flutter_test.dart';
import 'package:ratel/strings.dart';

// Inc 144 (Dataset P1) -- the plural engine: CLDR cardinal categories +
// ICU-style branch selection. Lands before UI language #3 so plural-correct
// copy is an INSERT, never a rebuild (Master Plan Invariant 10c).
void main() {
  group('CLDR plural categories', () {
    test('English: one only for n == 1', () {
      expect(S.pluralCategory('en', 0), 'other');
      expect(S.pluralCategory('en', 1), 'one');
      expect(S.pluralCategory('en', 2), 'other');
      expect(S.pluralCategory('en', 21), 'other');
    });
    test('Tamil: one for 0 and 1 (i = 0 or n = 1)', () {
      expect(S.pluralCategory('ta', 0), 'one');
      expect(S.pluralCategory('ta', 1), 'one');
      expect(S.pluralCategory('ta', 2), 'other');
      expect(S.pluralCategory('ta-Latn', 0), 'one'); // subtag honored
    });
    test('Hindi like Tamil; unknown language falls back to the English rule',
        () {
      expect(S.pluralCategory('hi', 0), 'one');
      expect(S.pluralCategory('hi', 5), 'other');
      expect(S.pluralCategory('zz', 0), 'other'); // unknown -> en rule
      expect(S.pluralCategory('zz', 1), 'one');
    });
  });

  group('ICU plural selection (brace-aware)', () {
    const icu = '{n, plural, =0 {no items} one {# item} other {# items}}';
    test('exact =N wins, then category, then other', () {
      expect(S.selectPlural(icu, 'other', 0), 'no items');
      expect(S.selectPlural(icu, 'one', 1), '# item');
      expect(S.selectPlural(icu, 'other', 5), '# items');
    });
    test('no plural block returns the input unchanged', () {
      expect(S.selectPlural('plain {n}', 'other', 3), 'plain {n}');
    });
    test('branch text may itself contain braces', () {
      const s = '{n, plural, one {one {x}} other {many {y}}}';
      expect(S.selectPlural(s, 'one', 1), 'one {x}');
      expect(S.selectPlural(s, 'other', 3), 'many {y}');
    });
    test('spacing variants are tolerated', () {
      const s = '{count,plural, one {a} other {b}}';
      expect(S.selectPlural(s, 'one', 1), 'a');
      expect(S.selectPlural(s, 'other', 9), 'b');
    });
  });

  group('S.plural end-to-end (locale-aware select + substitute)', () {
    setUp(() {
      S.instance.debugClear();
      S.instance.locale = 'en';
      S.instance.pseudo = false;
    });
    tearDown(() {
      S.instance.locale = 'en';
      S.instance.debugClear();
    });
    test('English selects branch then fills # and {n}', () {
      const def = '{n, plural, one {# day streak} other {# day streak}}';
      expect(S.instance.plural('streak', def, 1), '1 day streak');
      expect(S.instance.plural('streak', def, 7), '7 day streak');
    });
    test('Tamil row overrides and selects by the Tamil rule (0 -> one)', () {
      S.instance.debugSetLocale('lessons', 'ta',
          '{n, plural, one {{n} பாடம்} other {{n} பாடங்கள்}}');
      S.instance.locale = 'ta';
      expect(S.instance.plural('lessons', '{n} lessons', 0), '0 பாடம்');
      expect(S.instance.plural('lessons', '{n} lessons', 1), '1 பாடம்');
      expect(S.instance.plural('lessons', '{n} lessons', 3), '3 பாடங்கள்');
    });
    test('no row -> in-code default, still selected by active-locale rule', () {
      const def = '{n, plural, one {# item} other {# items}}';
      S.instance.locale = 'ta'; // Tamil: 0 -> one
      expect(S.instance.plural('none', def, 0), '0 item');
      expect(S.instance.plural('none', def, 2), '2 items');
    });
  });
}
