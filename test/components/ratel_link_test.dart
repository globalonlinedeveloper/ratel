import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ratel/core/theme/theme.dart';
import 'package:ratel/design_system/components/ratel_link.dart';

void main() {
  testWidgets('renders the label and fires onTap', (tester) async {
    var taps = 0;
    await tester.pumpWidget(
      MaterialApp(
        theme: ratelTheme(),
        home: Scaffold(
          body: RatelLink(label: 'Tap me', onTap: () => taps++),
        ),
      ),
    );
    expect(find.text('Tap me'), findsOneWidget);
    await tester.tap(find.text('Tap me'));
    expect(taps, 1);
  });
}
