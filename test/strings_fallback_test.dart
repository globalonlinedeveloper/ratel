import 'package:flutter_test/flutter_test.dart';
import 'package:ratel/locales.dart';
import 'package:ratel/strings.dart';

/// Part A (W1): the `S` resolver inherits base strings via `locales.fallback`.
/// A variant stores only its DELTAS and inherits everything else from its base
/// — the SAME mechanism for every multi-locale language (en-GB->en, ta-Latn->ta,
/// es-MX->es). No English special-casing.
void main() {
  setUp(() {
    S.instance.debugClear();
    S.instance.locale = 'en';
    Locales.instance.debugSetFallback(const {
      'en': 'en',
      'ta': 'en',
      'ta-Latn': 'ta',
      'en-GB': 'en',
      'en-IN': 'en-GB',
    });
  });
  tearDown(() {
    Locales.instance.debugSetFallback(const {});
    S.instance.debugClear();
    S.instance.locale = 'en';
  });

  test('a variant inherits its BASE string, not English (ta-Latn -> ta)', () {
    S.instance.debugSetLocale('greet', 'ta', 'வணக்கம்'); // only ta defines it
    S.instance.locale = 'ta-Latn';
    // Without the fallback chain this would skip ta and hit the en default.
    expect(S.instance.t('greet', 'Hello'), 'வணக்கம்');
  });

  test('an accent stores only deltas; everything else falls back to en', () {
    S.instance.debugSetLocale('btn_color', 'en-GB', 'Colour');
    S.instance.locale = 'en-GB';
    expect(S.instance.t('btn_color', 'Color'), 'Colour'); // the delta
    expect(S.instance.t('btn_save', 'Save'), 'Save'); // no delta -> en default
  });

  test('multi-hop chain resolves through an intermediate base (en-IN -> en-GB -> en)',
      () {
    S.instance.debugSetLocale('btn_color', 'en-GB', 'Colour');
    S.instance.locale = 'en-IN';
    // en-IN defines nothing -> inherits the en-GB delta one hop up.
    expect(S.instance.t('btn_color', 'Color'), 'Colour');
    // and falls all the way to the English default when no ancestor defines it.
    expect(S.instance.t('btn_save', 'Save'), 'Save');
  });

  test('en + empty fallback stays byte-identical (no regression)', () {
    Locales.instance.debugSetFallback(const {});
    S.instance.locale = 'en';
    expect(S.instance.t('missing', 'Default'), 'Default');
    S.instance.debugSetLocale('k', 'en', 'EN value');
    expect(S.instance.t('k', 'x'), 'EN value');
  });
}
