import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ratel/theme.dart';
import 'package:ratel/widgets/energy_meter.dart';

void main() {
  Widget host(Widget child, {ThemeData? theme}) => MaterialApp(
    theme: theme ?? ratelTheme(),
    home: Scaffold(body: child),
  );

  testWidgets('renders the current/max label and a bolt', (tester) async {
    await tester.pumpWidget(host(const EnergyMeter(current: 3, max: 5)));
    expect(find.text('3/5'), findsOneWidget);
    expect(find.byIcon(Icons.bolt), findsOneWidget);
  });

  testWidgets('clamps current to max', (tester) async {
    await tester.pumpWidget(host(const EnergyMeter(current: 9, max: 5)));
    expect(find.text('5/5'), findsOneWidget);
  });

  testWidgets('shows a refill hint and renders dark at 320px', (tester) async {
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      host(
        EnergyMeter(
          current: 1,
          max: 5,
          refillAt: DateTime.now().add(const Duration(minutes: 4, seconds: 5)),
        ),
        theme: ratelDarkTheme(),
      ),
    );
    await tester.pump();
    expect(find.textContaining('Full in'), findsOneWidget);
  });
}
