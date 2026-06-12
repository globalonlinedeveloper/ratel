import 'package:flutter_test/flutter_test.dart';
import 'package:ratel/explain_store.dart';
import 'package:ratel/strings.dart';

void main() {
  test('lookup honors the locale with en fallback', () {
    ExplainStore.instance.debugSetEn({'k1': 'english', 'k2': 'only en'});
    ExplainStore.instance.debugSetTa({'k1': 'தமிழ்'});
    S.instance.locale = 'en';
    expect(ExplainStore.instance.lookup('k1'), 'english');
    S.instance.locale = 'ta';
    expect(ExplainStore.instance.lookup('k1'), 'தமிழ்');
    expect(ExplainStore.instance.lookup('k2'), 'only en'); // fallback
    expect(ExplainStore.instance.lookup('nope'), isNull);
    S.instance.locale = 'en';
  });

  test('explain_fallback template renders byte-identical EN + Tamil draft', () {
    S.instance.debugClear();
    S.instance.locale = 'en';
    String render(String answer) => S.instance
        .t('explain_fallback', 'The correct answer is "{answer}".')
        .replaceAll('{answer}', answer);
    // The historical literal, byte for byte.
    expect(render('have'), 'The correct answer is "have".');
    S.instance.debugSet('explain_fallback', ta: 'சரியான பதில் "{answer}".');
    S.instance.locale = 'ta';
    expect(render('have'), 'சரியான பதில் "have".');
    S.instance.locale = 'en';
    S.instance.debugClear();
  });
}
