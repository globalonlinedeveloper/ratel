import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ratel/theme.dart';
import 'package:ratel/widgets/ratel_progress_bar.dart';
import 'package:ratel/widgets/ratel_tone.dart';

void main() {
  Widget host(Widget child, {ThemeData? theme}) => MaterialApp(
    theme: theme ?? ratelTheme(),
    home: Scaffold(
      body: Center(child: SizedBox(width: 200, child: child)),
    ),
  );

  testWidgets('renders a fractional fill', (tester) async {
    await tester.pumpWidget(host(const RatelProgressBar(value: 0.5)));
    expect(find.byType(FractionallySizedBox), findsOneWidget);
    final f = tester.widget<FractionallySizedBox>(
      find.byType(FractionallySizedBox),
    );
    expect(f.widthFactor, 0.5);
  });

  testWidgets('clamps out-of-range values', (tester) async {
    await tester.pumpWidget(host(const RatelProgressBar(value: 1.8)));
    final f = tester.widget<FractionallySizedBox>(
      find.byType(FractionallySizedBox),
    );
    expect(f.widthFactor, 1.0);
    await tester.pumpWidget(host(const RatelProgressBar(value: -0.4)));
    final g = tester.widget<FractionallySizedBox>(
      find.byType(FractionallySizedBox),
    );
    expect(g.widthFactor, 0.0);
  });

  testWidgets('renders with a tone in dark mode', (tester) async {
    await tester.pumpWidget(
      host(
        const RatelProgressBar(value: 0.3, tone: RatelTone.success),
        theme: ratelDarkTheme(),
      ),
    );
    expect(find.byType(RatelProgressBar), findsOneWidget);
  });
}
