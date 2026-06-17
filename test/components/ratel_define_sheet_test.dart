import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ratel/core/theme/theme.dart';
import 'package:ratel/design_system/components/ratel_button.dart';
import 'package:ratel/design_system/components/ratel_define_sheet.dart';

void main() {
  testWidgets('define sheet shows word, definition, flashcard action',
      (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: ratelTheme(),
        home: Scaffold(
          body: Builder(
            builder: (ctx) => RatelButton.filled(
              label: 'open',
              onPressed: () => RatelDefineSheet.show(
                ctx,
                word: 'into',
                partOfSpeech: 'preposition',
                definition: 'expressing movement to the inside.',
                example: 'She walked into the café.',
              ),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    expect(find.text('into'), findsOneWidget);
    expect(find.text('expressing movement to the inside.'), findsOneWidget);
    expect(find.text('Add to flashcards'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('no-data path shows the coming-soon fallback', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: ratelTheme(),
        home: Scaffold(
          body: Builder(
            builder: (ctx) => RatelButton.filled(
              label: 'open',
              onPressed: () => RatelDefineSheet.show(ctx, word: 'xyz'),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    expect(find.text('Definition coming soon.'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
