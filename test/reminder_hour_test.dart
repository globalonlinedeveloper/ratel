import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ratel/app_state.dart';
import 'package:ratel/milestones.dart';
import 'package:ratel/screens/settings_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    appState.reset();
  });

  test('utc/local hour conversion round-trips across the date line', () {
    const ist = Duration(hours: 5, minutes: 30);
    expect(utcHourFromLocal(19, ist), 14); // 19:30 IST -> 14:30 UTC
    expect(localHourFromUtc(14, ist), 19);
    const nyWinter = Duration(hours: -5);
    expect(utcHourFromLocal(3, nyWinter), 8);
    expect(utcHourFromLocal(22, nyWinter), 3); // wraps past midnight
    expect(localHourFromUtc(3, nyWinter), 22);
    for (int h = 0; h < 24; h++) {
      expect(localHourFromUtc(utcHourFromLocal(h, ist), ist), h);
    }
  });

  testWidgets('the Profile hour picker writes the converted UTC hour',
      (tester) async {
    // Inc 175: the reminder picker moved to the dedicated Settings page.
    await tester.pumpWidget(const MaterialApp(home: SettingsScreen()));
    await tester.pump(const Duration(milliseconds: 400));
    await tester.scrollUntilVisible(find.text('Remind me at'), 240,
        scrollable: find.byType(Scrollable).first);
    await tester.tap(find.byType(DropdownButton<int>));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    // the dropdown menu is a LAZY list centered on the current
    // value - pick an adjacent hour that is certainly built
    await tester.tap(find.text('14:30').last);
    await tester.pump(const Duration(milliseconds: 400));
    expect(
        appState.reminderHourUtc,
        utcHourFromLocal(14, DateTime.now().timeZoneOffset));
    await tester.pump(const Duration(seconds: 1));
  });
}
