import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ratel/screens/coach_screen.dart';
import 'package:ratel/strings.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Inc 150 -- EU AI Act Art.50(1): the Coach must disclose it is an AI at the
// first interaction. The notice sits in the always-visible header.
void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    S.instance.debugClear();
    S.instance.locale = 'en';
  });
  tearDown(() {
    S.instance.locale = 'en';
    S.instance.debugClear();
  });

  testWidgets('Coach shows the AI disclosure at entry (EN default)',
      (tester) async {
    await tester.pumpWidget(const MaterialApp(home: CoachScreen()));
    await tester.pump(const Duration(milliseconds: 200));
    expect(find.textContaining('AI-generated'), findsOneWidget);
  });

  testWidgets('AI disclosure localizes (ta override)', (tester) async {
    S.instance.debugSet('coach_ai_notice',
        ta: 'AI பயிற்சியாளர் — பதில்களை AI உருவாக்குகிறது.');
    S.instance.locale = 'ta';
    await tester.pumpWidget(const MaterialApp(home: CoachScreen()));
    await tester.pump(const Duration(milliseconds: 200));
    expect(find.textContaining('உருவாக்குகிறது'), findsOneWidget);
  });
}
