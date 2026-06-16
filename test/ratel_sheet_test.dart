import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ratel/theme.dart';
import 'package:ratel/widgets/ratel_sheet.dart';

void main() {
  Widget host(Widget child, {ThemeData? theme}) => MaterialApp(
    theme: theme ?? ratelTheme(),
    home: Scaffold(body: child),
  );

  testWidgets('show() presents title + child', (tester) async {
    await tester.pumpWidget(
      host(
        Builder(
          builder: (c) {
            return TextButton(
              onPressed: () => RatelSheet.show(
                c,
                title: 'Out of energy',
                child: const Text('Body'),
              ),
              child: const Text('open'),
            );
          },
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    expect(find.text('Out of energy'), findsOneWidget);
    expect(find.text('Body'), findsOneWidget);
  });

  testWidgets('renders directly with actions (dark)', (tester) async {
    await tester.pumpWidget(
      host(
        RatelSheet(
          title: 'Title',
          actions: const [Text('Action')],
          child: const Text('Content'),
        ),
        theme: ratelDarkTheme(),
      ),
    );
    expect(find.text('Title'), findsOneWidget);
    expect(find.text('Content'), findsOneWidget);
    expect(find.text('Action'), findsOneWidget);
  });
}
