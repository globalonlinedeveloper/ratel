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
}
