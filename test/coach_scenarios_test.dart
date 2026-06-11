import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ratel/screens/coach_screen.dart';

void main() {
  testWidgets('scenario cards show when empty and send their prompt',
      (tester) async {
    final sent = <String>[];
    await tester.pumpWidget(MaterialApp(
      home: CoachScreen(sender: (h) async {
        sent.add(h.last.text);
        return 'Of course! Welcome in.';
      }),
    ));
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('Order at a café'), findsOneWidget);
    await tester.tap(find.text('Order at a café'));
    await tester.pump(const Duration(milliseconds: 350));
    await tester.pump(const Duration(milliseconds: 800));
    expect(sent.single, contains('roleplay'));
    // cards hide once the conversation starts
    expect(find.text('Job interview'), findsNothing);
    await tester.pump(const Duration(seconds: 1));
  });
}
