import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ratel/theme.dart';
import 'package:ratel/widgets/ratel_button.dart';

void main() {
  Widget host(Widget child, {ThemeData? theme}) => MaterialApp(
    theme: theme ?? ratelTheme(),
    home: Scaffold(body: child),
  );

  testWidgets('filled renders label and fires onPressed', (tester) async {
    var n = 0;
    await tester.pumpWidget(
      host(RatelButton.filled(label: 'Go', onPressed: () => n++)),
    );
    expect(find.text('Go'), findsOneWidget);
    await tester.tap(find.text('Go'));
    expect(n, 1);
  });

  testWidgets('loading shows a spinner and blocks taps', (tester) async {
    var n = 0;
    await tester.pumpWidget(
      host(
        RatelButton.filled(label: 'Go', loading: true, onPressed: () => n++),
      ),
    );
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    await tester.tap(find.byType(FilledButton));
    expect(n, 0);
  });

  testWidgets('outline and social render', (tester) async {
    await tester.pumpWidget(
      host(
        Column(
          children: [
            RatelButton.outline(label: 'More', onPressed: () {}),
            RatelButton.social(
              provider: 'google',
              label: 'Continue with Google',
              onPressed: () {},
            ),
          ],
        ),
      ),
    );
    expect(find.text('More'), findsOneWidget);
    expect(find.text('Continue with Google'), findsOneWidget);
    expect(find.byType(OutlinedButton), findsNWidgets(2));
  });

  testWidgets('null onPressed disables the button', (tester) async {
    await tester.pumpWidget(
      host(const RatelButton.filled(label: 'Off', onPressed: null)),
    );
    final b = tester.widget<FilledButton>(find.byType(FilledButton));
    expect(b.onPressed, isNull);
  });

  testWidgets('no overflow at 320px with a long social label', (tester) async {
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      host(
        RatelButton.social(
          provider: 'apple',
          label: 'Continue with a very long provider label that must ellipsize',
          onPressed: () {},
        ),
      ),
    );
    await tester.pump();
  });
}
