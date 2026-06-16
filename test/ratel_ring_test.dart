import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ratel/theme.dart';
import 'package:ratel/widgets/ratel_ring.dart';
import 'package:ratel/widgets/ratel_tone.dart';

void main() {
  Widget host(Widget child, {ThemeData? theme}) => MaterialApp(
    theme: theme ?? ratelTheme(),
    home: Scaffold(body: child),
  );

  testWidgets('renders a center label and two ring layers', (tester) async {
    await tester.pumpWidget(host(const RatelRing(value: 0.5, label: 'B1')));
    expect(find.text('B1'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsNWidgets(2));
  });

  testWidgets('clamps the foreground value', (tester) async {
    await tester.pumpWidget(host(const RatelRing(value: 2.0)));
    final inds = tester
        .widgetList<CircularProgressIndicator>(
          find.byType(CircularProgressIndicator),
        )
        .toList();
    expect(inds.any((c) => c.value == 1.0), true);
  });

  testWidgets('renders with a tone in dark mode', (tester) async {
    await tester.pumpWidget(
      host(
        const RatelRing(value: 0.7, label: '7', tone: RatelTone.win, size: 80),
        theme: ratelDarkTheme(),
      ),
    );
    expect(find.text('7'), findsOneWidget);
  });
}
