import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ratel/theme.dart';
import 'package:ratel/widgets/ratel_field.dart';

void main() {
  Widget host(Widget child, {ThemeData? theme}) => MaterialApp(
    theme: theme ?? ratelTheme(),
    home: Scaffold(body: child),
  );

  testWidgets('renders label and reports changes', (tester) async {
    String? got;
    await tester.pumpWidget(
      host(
        RatelField(
          label: 'Email',
          hint: 'you@x.com',
          onChanged: (v) => got = v,
        ),
      ),
    );
    expect(find.text('Email'), findsOneWidget);
    await tester.enterText(find.byType(TextField), 'a@b.com');
    expect(got, 'a@b.com');
  });

  testWidgets('shows an error and obscures when asked', (tester) async {
    await tester.pumpWidget(
      host(
        const RatelField(label: 'Password', obscure: true, error: 'Too short'),
      ),
    );
    expect(find.text('Too short'), findsOneWidget);
    final tf = tester.widget<TextField>(find.byType(TextField));
    expect(tf.obscureText, true);
  });

  testWidgets('renders in dark mode at 320px', (tester) async {
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      host(
        const RatelField(label: 'Search', prefixIcon: Icons.search),
        theme: ratelDarkTheme(),
      ),
    );
    await tester.pump();
    expect(find.byIcon(Icons.search), findsOneWidget);
  });
}
