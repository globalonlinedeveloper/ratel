import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ratel/widgets/leagues_board.dart';
import 'package:ratel/widgets/streak_calendar.dart';

void main() {
  test('league reset countdown counts to next Monday 00:00 UTC', () {
    // Wed 2026-06-10 12:00 UTC -> Monday 15th = 4d 12h
    expect(resetCountdownLabel(DateTime.utc(2026, 6, 10, 12)),
        'Resets in 4d 12h');
    // Sunday 23:30 -> 30m
    expect(resetCountdownLabel(DateTime.utc(2026, 6, 14, 23, 30)),
        'Resets in 30m');
    // Monday 00:00 exactly -> a full week
    expect(resetCountdownLabel(DateTime.utc(2026, 6, 15)),
        'Resets in 7d 0h');
  });

  testWidgets('streak calendar paints active days', (tester) async {
    await tester.pumpWidget(const MaterialApp(
        home: Scaffold(
            body: SingleChildScrollView(
                child: StreakCalendar(activeDays: {1, 2, 3})))));
    await tester.pump(const Duration(milliseconds: 200));
    expect(find.textContaining('practice'), findsOneWidget);
    expect(find.text('1'), findsWidgets);
    expect(find.text('28'), findsOneWidget);
  });
}
