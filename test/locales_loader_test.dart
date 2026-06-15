import 'package:flutter_test/flutter_test.dart';
import 'package:ratel/locales.dart';

// Inc 149 -- the Locales registry loader (gap A). ingest is the pure,
// network-free core; in-code defaults keep the picker non-empty offline.
void main() {
  test('defaults: en + ta present when nothing loaded', () {
    final fresh = Locales.instance;
    expect(fresh.enabled.any((e) => e.code == 'en'), isTrue);
    expect(fresh.enabled.any((e) => e.code == 'ta'), isTrue);
  });

  test('ingest builds enabled list from rows (native names)', () {
    Locales.instance.ingest(<Map<String, dynamic>>[
      {'code': 'en', 'native_name': 'English', 'enabled': true},
      {'code': 'ta', 'native_name': 'தமிழ்', 'enabled': true},
      {'code': 'hi', 'native_name': 'हिन्दी', 'enabled': true},
    ]);
    final codes = Locales.instance.enabled.map((e) => e.code).toList();
    // Inc 196 — sorted: en (English family) first, then A-Z by native name
    // (Devanagari हिन्दी sorts before Tamil தமிழ் by Unicode).
    expect(codes, ['en', 'hi', 'ta']);
    expect(Locales.instance.enabled[2].nativeName, 'தமிழ்');
  });

  test('empty/blank rows are skipped; empty fetch keeps prior list', () {
    Locales.instance.ingest(<Map<String, dynamic>>[
      {'code': 'fr', 'native_name': 'Français', 'enabled': true},
    ]);
    Locales.instance.ingest(<Map<String, dynamic>>[]); // no rows -> keep
    expect(Locales.instance.enabled.any((e) => e.code == 'fr'), isTrue);
    Locales.instance.ingest(<Map<String, dynamic>>[
      {'code': '', 'native_name': 'x', 'enabled': true},
    ]);
    expect(Locales.instance.enabled.any((e) => e.code == ''), isFalse);
    // restore defaults for other suites
    Locales.instance.debugSet(const [LocaleEntry('en', 'English'), LocaleEntry('ta', 'தமிழ்')]);
  });

  test('englishNameFor: known codes, variants, graceful unknown', () {
    expect(Locales.englishNameFor('ta'), 'Tamil');
    expect(Locales.englishNameFor('hi'), 'Hindi');
    expect(Locales.englishNameFor('en'), 'English (US)');
    expect(Locales.englishNameFor('ta-Latn'), 'Tamil (Latin)');
    expect(Locales.englishNameFor('zz'), '');
  });
}
