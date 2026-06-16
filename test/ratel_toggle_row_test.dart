import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ratel/theme.dart';
import 'package:ratel/widgets/ratel_toggle_row.dart';

void main() {
  Widget host(Widget child, {ThemeData? theme}) => MaterialApp(
    theme: theme ?? ratelTheme(),
    home: Scaffold(body: child),
  );

  testWidgets('reflects value and toggles via the row', (tester) async {
    bool? got;
    await tester.pumpWidget(
      host(
        RatelToggleRow(
          title: 'Reduce motion',
          value: false,
          onChanged: (v) => got = v,
        ),
      ),
    );
    expect(find.text('Reduce motion'), findsOneWidget);
    final sw = tester.widget<Switch>(find.byType(Switch));
    expect(sw.value, false);
    await tester.tap(find.text('Reduce motion'));
    expect(got, true);
  });

  testWidgets('toggles via the switch too', (tester) async {
    bool? got;
    await tester.pumpWidget(
      host(
        RatelToggleRow(title: 'Sound', value: true, onChanged: (v) => got = v),
      ),
    );
    await tester.tap(find.byType(Switch));
    expect(got, false);
  });

  testWidgets('renders in dark mode with a subtitle', (tester) async {
    await tester.pumpWidget(
      host(
        RatelToggleRow(
          title: 'Notifications',
          subtitle: 'Streak + goal reminders',
          value: true,
          onChanged: (_) {},
        ),
        theme: ratelDarkTheme(),
      ),
    );
    expect(find.text('Notifications'), findsOneWidget);
  });
}
