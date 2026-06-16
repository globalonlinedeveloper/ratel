import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ratel/theme.dart';
import 'package:ratel/widgets/language_picker.dart';

void main() {
  Widget host(Widget child, {ThemeData? theme}) => MaterialApp(
    theme: theme ?? ratelTheme(),
    home: Scaffold(body: child),
  );

  testWidgets('renders both labels and current selections', (tester) async {
    await tester.pumpWidget(
      host(
        LanguagePicker(
          options: const {'en': 'English', 'ta': 'Tamil', 'hi': 'Hindi'},
          spoken: 'en',
          target: 'ta',
          onSpokenChanged: (_) {},
          onTargetChanged: (_) {},
        ),
      ),
    );
    expect(find.text('I speak'), findsOneWidget);
    expect(find.text('I want to learn'), findsOneWidget);
    expect(find.text('English'), findsOneWidget);
    expect(find.text('Tamil'), findsOneWidget);
  });

  testWidgets('changing the spoken language reports the new code', (
    tester,
  ) async {
    String? picked;
    await tester.pumpWidget(
      host(
        LanguagePicker(
          options: const {'en': 'English', 'ta': 'Tamil', 'hi': 'Hindi'},
          spoken: 'en',
          target: 'ta',
          onSpokenChanged: (v) => picked = v,
          onTargetChanged: (_) {},
        ),
      ),
    );
    await tester.tap(find.text('English').first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Hindi').last);
    await tester.pumpAndSettle();
    expect(picked, 'hi');
  });
}
