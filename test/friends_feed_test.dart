import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ratel/milestones.dart';
import 'package:ratel/widgets/friends_feed.dart';

void main() {
  test('timeAgo buckets sensibly', () {
    expect(timeAgo(const Duration(seconds: 20)), 'just now');
    expect(timeAgo(const Duration(minutes: 5)), '5m ago');
    expect(timeAgo(const Duration(hours: 3)), '3h ago');
    expect(timeAgo(const Duration(days: 2)), '2d ago');
  });

  testWidgets('feed renders injected rows and hides when empty',
      (tester) async {
    final items = [
      FeedItem(
          name: 'Padhu',
          amount: 50,
          reason: 'lesson',
          at: DateTime.now().subtract(const Duration(hours: 2))),
      FeedItem(
          name: 'Raj',
          amount: 20,
          reason: 'chest',
          at: DateTime.now().subtract(const Duration(minutes: 3))),
    ];
    await tester.pumpWidget(MaterialApp(
        home: Scaffold(
            body: SingleChildScrollView(
                child: FriendsFeed(items: items)))));
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('Friend activity'), findsOneWidget);
    expect(find.textContaining('Padhu earned 50 XP'), findsOneWidget);
    expect(find.textContaining('Raj opened a chest (+20 XP)'),
        findsOneWidget);
    expect(find.text('2h ago'), findsOneWidget);
    // empty -> invisible
    await tester.pumpWidget(const MaterialApp(
        home: Scaffold(body: FriendsFeed(items: []))));
    await tester.pump(const Duration(milliseconds: 200));
    expect(find.text('Friend activity'), findsNothing);
  });
}
