import 'package:flutter_test/flutter_test.dart';
import 'package:ratel/models.dart';
import 'package:ratel/strings.dart';

// Inc 198 -- content titles are per-locale via app_strings (keys
// unit:<id>:title / unit:<id>:subtitle / lesson:<id>:title), replacing the
// Inc-158 title_ta columns. The S resolver + fallback chain localize them; an
// unglossed locale falls back to the EN source.
void main() {
  setUp(() => S.instance
    ..debugClear()
    ..locale = 'en');
  tearDown(() => S.instance
    ..debugClear()
    ..locale = 'en');

  test('lesson + unit titles resolve per locale via app_strings', () {
    final l = Lesson(id: 'u1l1', title: 'Greetings', exercises: const []);
    final u = Unit(
        id: 'u1', title: 'Unit 1', subtitle: 'Everyday basics', lessons: const []);
    S.instance
      ..debugSetLocale('lesson:u1l1:title', 'ta', 'வணக்கம்')
      ..debugSetLocale('unit:u1:title', 'ta', 'அலகு 1')
      ..debugSetLocale('unit:u1:subtitle', 'ta', 'தினசரி அடிப்படைகள்');

    S.instance.locale = 'en';
    expect(l.title, 'Greetings');
    expect(u.title, 'Unit 1');
    expect(u.subtitle, 'Everyday basics');

    S.instance.locale = 'ta';
    expect(l.title, 'வணக்கம்');
    expect(u.title, 'அலகு 1');
    expect(u.subtitle, 'தினசரி அடிப்படைகள்');

    // a locale with no title row falls back to the EN source
    S.instance.locale = 'de';
    expect(l.title, 'Greetings');
    expect(u.title, 'Unit 1');
  });
}
