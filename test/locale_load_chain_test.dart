import 'package:flutter_test/flutter_test.dart';
import 'package:ratel/locales.dart';
import 'package:ratel/strings.dart';

// Inc 199 -- S.load fetches only the active locale + its fallback chain (+ en),
// so app_strings staying under PostgREST's 1000-row cap no matter how many
// locales exist. localesToLoad is the pure chain it uses.
void main() {
  tearDown(() => Locales.instance.debugSetFallback(const {}));

  test('walks the fallback chain and always includes en', () {
    Locales.instance.debugSetFallback({'es-US': 'es', 'es': 'en'});
    final got = S.localesToLoad('es-US');
    expect(got.contains('es-US'), isTrue);
    expect(got.contains('es'), isTrue); // base inherited
    expect(got.contains('en'), isTrue); // pivot always present
  });

  test('a base locale loads itself + en only', () {
    Locales.instance.debugSetFallback(const {});
    final got = S.localesToLoad('id');
    expect(got.toSet(), {'id', 'en'});
  });
}
