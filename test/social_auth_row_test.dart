import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ratel/theme.dart';
import 'package:ratel/widgets/passkey_button.dart';
import 'package:ratel/widgets/social_auth_row.dart';

void main() {
  Widget host(Widget child, {ThemeData? theme}) => MaterialApp(
    theme: theme ?? ratelTheme(),
    home: Scaffold(body: child),
  );

  testWidgets('renders one button per provider, passkey first', (tester) async {
    await tester.pumpWidget(
      host(
        SocialAuthRow(
          providers: const ['passkey', 'google', 'apple', 'email'],
          onSelect: (_) {},
        ),
      ),
    );
    expect(find.byType(PasskeyButton), findsOneWidget);
    expect(find.text('Continue with a passkey'), findsOneWidget);
    expect(find.text('Continue with Google'), findsOneWidget);
    expect(find.text('Continue with Apple'), findsOneWidget);
    expect(find.text('Continue with email'), findsOneWidget);
  });

  testWidgets('tapping a provider reports it', (tester) async {
    String? picked;
    await tester.pumpWidget(
      host(
        SocialAuthRow(
          providers: const ['passkey', 'google'],
          onSelect: (p) => picked = p,
        ),
      ),
    );
    await tester.tap(find.text('Continue with Google'));
    expect(picked, 'google');
    await tester.tap(find.text('Continue with a passkey'));
    expect(picked, 'passkey');
  });

  testWidgets('passkey button standalone fires', (tester) async {
    var n = 0;
    await tester.pumpWidget(host(PasskeyButton(onPressed: () => n++)));
    await tester.tap(find.text('Continue with a passkey'));
    expect(n, 1);
  });
}
