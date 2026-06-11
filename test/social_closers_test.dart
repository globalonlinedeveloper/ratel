import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ratel/app_state.dart';
import 'package:ratel/milestones.dart';
import 'package:ratel/widgets/friends_feed.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    appState.reset();
  });

  test('friendCodeFromUri parses, trims, uppercases, rejects empty', () {
    expect(friendCodeFromUri(Uri.parse('https://x/?friend=ab12cd')),
        'AB12CD');
    expect(friendCodeFromUri(Uri.parse('https://x/?friend=')), isNull);
    expect(friendCodeFromUri(Uri.parse('https://x/')), isNull);
  });

  test('redeemPendingFriendCode clears the pref and no-ops offline',
      () async {
    SharedPreferences.setMockInitialValues(
        {'pending_friend_code': 'ABC123'});
    expect(await appState.redeemPendingFriendCode(), isNull); // no client
    final p = await SharedPreferences.getInstance();
    expect(p.getString('pending_friend_code'), isNull); // never loops
  });

  testWidgets('cheer rows render and activity rows offer a clap',
      (tester) async {
    final items = [
      FeedItem(
          friendId: 'uid-1',
          name: 'Padhu',
          amount: 50,
          reason: 'lesson',
          at: DateTime.now().subtract(const Duration(hours: 1))),
      FeedItem(
          name: 'Raj',
          amount: 0,
          reason: 'cheer',
          at: DateTime.now().subtract(const Duration(minutes: 5))),
    ];
    await tester.pumpWidget(MaterialApp(
        home: Scaffold(
            body: SingleChildScrollView(
                child: FriendsFeed(items: items)))));
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.textContaining('Raj cheered you on!'), findsOneWidget);
    expect(find.byIcon(Icons.celebration_outlined), findsOneWidget);
    await tester.tap(find.byIcon(Icons.celebration_outlined));
    await tester.pump(const Duration(milliseconds: 200));
    expect(find.byIcon(Icons.celebration), findsOneWidget); // filled
  });
}
