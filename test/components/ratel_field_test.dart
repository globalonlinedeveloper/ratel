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
}
