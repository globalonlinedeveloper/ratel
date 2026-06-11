import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ratel/flags.dart';
import 'package:ratel/guest.dart';
import 'package:ratel/screens/auth_screen.dart';
import 'package:ratel/widgets/save_account_sheet.dart';

void main() {
  test('isGuest is safely false without Supabase', () {
    expect(isGuest, isFalse);
  });

  testWidgets('auth screen shows the guest button only when flagged',
      (tester) async {
    Flags.instance.debugSet({});
    await tester.pumpWidget(const MaterialApp(home: AuthScreen()));
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('Just let me try it'), findsNothing);

    Flags.instance.debugSet({'guest_mode': 'true'});
    await tester.pumpWidget(const SizedBox());
    await tester.pumpWidget(const MaterialApp(home: AuthScreen()));
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('Just let me try it'), findsOneWidget);
    Flags.instance.debugSet({});
    await tester.pump(const Duration(seconds: 1));
  });

  testWidgets('save-account sheet validates input', (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: Builder(
        builder: (ctx) => ElevatedButton(
            onPressed: () => showSaveAccountSheet(ctx),
            child: const Text('open')),
      ),
    ));
    await tester.tap(find.text('open'));
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.text('Save your progress'), findsOneWidget);
    await tester.ensureVisible(find.text('Save my progress'));
    await tester.tap(find.text('Save my progress'));
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.textContaining('valid email'), findsOneWidget);
    await tester.pump(const Duration(seconds: 1));
  });
}
