import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ratel/theme.dart';
import 'package:ratel/widgets/consent_toggles.dart';

void main() {
  Widget host(Widget child, {ThemeData? theme}) => MaterialApp(
    theme: theme ?? ratelTheme(),
    home: Scaffold(body: child),
  );

  testWidgets('renders items and reports a toggle', (tester) async {
    String? key;
    bool? val;
    await tester.pumpWidget(
      host(
        ConsentToggles(
          items: const [
            ConsentItem(
              key: 'analytics',
              title: 'Analytics',
              subtitle: 'Help improve',
            ),
            ConsentItem(key: 'marketing', title: 'Marketing emails'),
          ],
          values: const {'analytics': false, 'marketing': false},
          onChanged: (k, v) {
            key = k;
            val = v;
          },
        ),
      ),
    );
    expect(find.text('Analytics'), findsOneWidget);
    expect(find.text('Marketing emails'), findsOneWidget);
    await tester.tap(find.text('Analytics'));
    expect(key, 'analytics');
    expect(val, true);
  });

  testWidgets('reflects default-off values', (tester) async {
    await tester.pumpWidget(
      host(
        ConsentToggles(
          items: const [ConsentItem(key: 'a', title: 'A')],
          values: const {'a': false},
          onChanged: (_, _) {},
        ),
      ),
    );
    final sw = tester.widget<Switch>(find.byType(Switch));
    expect(sw.value, false);
  });
}
