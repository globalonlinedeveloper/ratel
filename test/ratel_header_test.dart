import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ratel/theme.dart';
import 'package:ratel/widgets/ratel_header.dart';

void main() {
  Widget host(Widget child, {ThemeData? theme}) => MaterialApp(
    theme: theme ?? ratelTheme(),
    home: Scaffold(body: child),
  );

  testWidgets('renders streak, gems, energy', (tester) async {
    await tester.pumpWidget(
      host(const RatelHeader(streak: 12, gems: 250, energy: 5)),
    );
    expect(find.text('12'), findsOneWidget);
    expect(find.text('250'), findsOneWidget);
    expect(find.text('5'), findsOneWidget);
    expect(find.byIcon(Icons.bolt), findsOneWidget);
  });

  testWidgets('optional hearts pill appears', (tester) async {
    await tester.pumpWidget(
      host(const RatelHeader(streak: 1, gems: 1, energy: 1, hearts: 4)),
    );
    expect(find.byIcon(Icons.favorite), findsOneWidget);
    expect(find.text('4'), findsOneWidget);
  });

  testWidgets('no overflow at 320px with large values (dark)', (tester) async {
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      host(
        const RatelHeader(streak: 365, gems: 99999, energy: 25, hearts: 5),
        theme: ratelDarkTheme(),
      ),
    );
    await tester.pump();
  });
}
