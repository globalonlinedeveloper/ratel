import 'package:flutter_test/flutter_test.dart';
import 'package:ratel/models.dart';
import 'package:ratel/strings.dart';

void main() {
  tearDown(() => S.instance.locale = 'en');

  test('S.tr picks ta only in ta locale with a non-empty value', () {
    S.instance.locale = 'en';
    expect(S.instance.tr('Family', 'குடும்பம்'), 'Family');
    S.instance.locale = 'ta';
    expect(S.instance.tr('Family', 'குடும்பம்'), 'குடும்பம்');
    expect(S.instance.tr('Family', ''), 'Family'); // empty ta -> EN fallback
  });

  test('Lesson/Unit titles localize via getter; EN stays byte-identical', () {
    const l = Lesson(
        id: 'x', title: 'Family', titleTa: 'குடும்பம்', exercises: []);
    const u = Unit(
        title: 'Unit 1', subtitle: 'Everyday basics',
        titleTa: 'அலகு 1', subtitleTa: 'தினசரி அடிப்படைகள்', lessons: []);
    S.instance.locale = 'en';
    expect(l.title, 'Family');
    expect(u.title, 'Unit 1');
    expect(u.subtitle, 'Everyday basics');
    S.instance.locale = 'ta';
    expect(l.title, 'குடும்பம்');
    expect(u.title, 'அலகு 1');
    expect(u.subtitle, 'தினசரி அடிப்படைகள்');
    // EN-only content (no ta draft) stays EN even in ta locale.
    const l2 = Lesson(id: 'y', title: 'Greetings', exercises: []);
    expect(l2.title, 'Greetings');
  });
}
