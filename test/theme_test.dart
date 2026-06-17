import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ratel/core/theme/theme.dart';
import 'package:ratel/core/theme/tokens.dart';

void main() {
  testWidgets('light theme exposes Ratel tokens with teal primary',
      (tester) async {
    late BuildContext ctx;
    await tester.pumpWidget(MaterialApp(
      theme: ratelTheme(),
      home: Builder(builder: (c) {
        ctx = c;
        return const SizedBox();
      }),
    ));
    expect(ctx.tokens.primary, RatelColors.teal);
    expect(ctx.tokens.brand, RatelColors.honey);
    expect(ctx.isDark, isFalse);
    expect(Theme.of(ctx).colorScheme.primary, RatelColors.teal);
  });

  testWidgets('dark theme swaps to the dark token set', (tester) async {
    late BuildContext ctx;
    await tester.pumpWidget(MaterialApp(
      theme: ratelTheme(),
      darkTheme: ratelDarkTheme(),
      themeMode: ThemeMode.dark,
      home: Builder(builder: (c) {
        ctx = c;
        return const SizedBox();
      }),
    ));
    expect(ctx.isDark, isTrue);
    expect(ctx.tokens.primary, RatelColorsDark.teal);
  });

  testWidgets('accentIndex 2 overrides primary to society purple',
      (tester) async {
    late BuildContext ctx;
    await tester.pumpWidget(MaterialApp(
      theme: ratelTheme(accentIndex: 2),
      home: Builder(builder: (c) {
        ctx = c;
        return const SizedBox();
      }),
    ));
    expect(ctx.tokens.primary, RatelSociety.purple);
    expect(Theme.of(ctx).colorScheme.primary, RatelSociety.purple);
  });

  testWidgets('default ratelTheme still yields teal (byte-stable)',
      (tester) async {
    late BuildContext ctx;
    await tester.pumpWidget(MaterialApp(
      theme: ratelTheme(),
      home: Builder(builder: (c) {
        ctx = c;
        return const SizedBox();
      }),
    ));
    expect(ctx.tokens.primary, RatelColors.teal);
    expect(ratelAccents(false)[2], RatelSociety.purple);
  });

  testWidgets('highContrast tightens border + muted to the text colour',
      (tester) async {
    late BuildContext ctx;
    await tester.pumpWidget(MaterialApp(
      theme: ratelTheme(highContrast: true),
      home: Builder(builder: (c) {
        ctx = c;
        return const SizedBox();
      }),
    ));
    expect(ctx.tokens.border, ctx.tokens.text);
    expect(ctx.tokens.textMuted, ctx.tokens.text);
  });

  test('dyslexiaFont swaps the theme body font family (with fallback)', () {
    expect(
      ratelTheme(dyslexiaFont: true).textTheme.bodyMedium?.fontFamily,
      kDyslexiaFont,
    );
    expect(
      ratelTheme().textTheme.bodyMedium?.fontFamily,
      kBodyFont,
    );
  });
}
