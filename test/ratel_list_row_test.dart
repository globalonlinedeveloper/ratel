import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ratel/theme.dart';
import 'package:ratel/widgets/ratel_list_row.dart';

void main() {
  Widget host(Widget child, {ThemeData? theme}) => MaterialApp(
    theme: theme ?? ratelTheme(),
    home: Scaffold(body: child),
  );

  testWidgets('renders title + subtitle', (tester) async {
    await tester.pumpWidget(
      host(const RatelListRow(title: 'Account', subtitle: 'Manage')),
    );
    expect(find.text('Account'), findsOneWidget);
    expect(find.text('Manage'), findsOneWidget);
  });

  testWidgets('onTap fires and a chevron is shown by default', (tester) async {
    var n = 0;
    await tester.pumpWidget(host(RatelListRow(title: 'Go', onTap: () => n++)));
    expect(find.byIcon(Icons.chevron_right), findsOneWidget);
    await tester.tap(find.text('Go'));
    expect(n, 1);
  });

  testWidgets('custom trailing replaces the chevron', (tester) async {
    await tester.pumpWidget(
      host(
        RatelListRow(
          title: 'X',
          trailing: const Icon(Icons.star),
          onTap: () {},
        ),
      ),
    );
    expect(find.byIcon(Icons.star), findsOneWidget);
    expect(find.byIcon(Icons.chevron_right), findsNothing);
  });

  testWidgets('no overflow at 320px with a long title (dark)', (tester) async {
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      host(
        const RatelListRow(
          leading: Icon(Icons.person),
          title: 'A long row title that should wrap cleanly without overflow',
          subtitle: 'And a secondary line of supporting copy as well',
          trailing: Icon(Icons.chevron_right),
        ),
        theme: ratelDarkTheme(),
      ),
    );
    await tester.pump();
  });
}
