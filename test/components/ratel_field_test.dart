import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ratel/core/theme/theme.dart';
import 'package:ratel/design_system/components/ratel_field.dart';

Widget _wrap(Widget child) =>
    MaterialApp(theme: ratelTheme(), home: Scaffold(body: child));

void main() {
  testWidgets('shows the hint and accepts input', (tester) async {
    final c = TextEditingController();
    await tester.pumpWidget(_wrap(RatelField(controller: c, hint: 'Email')));
    expect(find.text('Email'), findsOneWidget);
    await tester.enterText(find.byType(TextField), 'a@b.com');
    expect(c.text, 'a@b.com');
  });

  testWidgets('password field toggles obscure via the eye', (tester) async {
    await tester.pumpWidget(_wrap(const RatelField(hint: 'Password', obscure: true)));
    TextField tf() => tester.widget<TextField>(find.byType(TextField));
    expect(tf().obscureText, isTrue);
    await tester.tap(find.byType(IconButton));
    await tester.pump();
    expect(tf().obscureText, isFalse);
  });

  testWidgets('renders errorText when provided', (tester) async {
    await tester.pumpWidget(_wrap(const RatelField(hint: 'Email', errorText: 'Enter a valid email')));
    expect(find.text('Enter a valid email'), findsOneWidget);
  });

  testWidgets('no errorText -> no error string', (tester) async {
    await tester.pumpWidget(_wrap(const RatelField(hint: 'Email')));
    expect(find.text('Enter a valid email'), findsNothing);
  });

  testWidgets('onChanged fires with the typed value', (tester) async {
    String seen = '';
    await tester.pumpWidget(_wrap(RatelField(hint: 'Email', onChanged: (String v) => seen = v)));
    await tester.enterText(find.byType(TextField), 'hi@x.io');
    expect(seen, 'hi@x.io');
  });
}
