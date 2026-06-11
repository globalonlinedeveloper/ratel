import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ratel/milestones.dart';
import 'package:ratel/widgets/badge_gallery.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('monthlyBadges thresholds', () {
    final none = monthlyBadges(quests: 0, weeks: 0, best: 0);
    expect(none.where((b) => b.earned), isEmpty);
    final some = monthlyBadges(quests: 3, weeks: 1, best: 150);
    final earned = [for (final b in some) if (b.earned) b.label];
    expect(earned, [
      'Monthly Quester', 'Quest Devotee', 'Perfect Week', 'Quick Thinker'
    ]);
    final all = monthlyBadges(quests: 5, weeks: 6, best: 250);
    expect(all.every((b) => b.earned), isTrue);
  });

  testWidgets('the gallery renders earned vs locked chips',
      (tester) async {
    await tester.pumpWidget(MaterialApp(
        home: Scaffold(
            body: BadgeGallery(
                badgesOverride:
                    monthlyBadges(quests: 1, weeks: 0, best: 0)))));
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('Monthly badges'), findsOneWidget);
    expect(find.text('Monthly Quester'), findsOneWidget);
    expect(find.text('Lightning Badger'), findsOneWidget); // locked shown
  });

  testWidgets('prefs counts feed the gallery', (tester) async {
    SharedPreferences.setMockInitialValues(
        {'mquest_count': 3, 'timed_best': 220});
    await tester.pumpWidget(const MaterialApp(
        home: Scaffold(body: BadgeGallery())));
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('Quest Devotee'), findsOneWidget);
    expect(find.text('Lightning Badger'), findsOneWidget);
  });
}
