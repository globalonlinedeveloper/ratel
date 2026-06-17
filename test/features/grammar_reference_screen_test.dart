import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ratel/core/theme/theme.dart';
import 'package:ratel/features/learn/screens/grammar_reference_screen.dart';

void main() {
  testWidgets('grammar reference renders sections, topics and notebook at 360px',
      (tester) async {
    tester.view.physicalSize = const Size(360, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      MaterialApp(theme: ratelTheme(), home: const GrammarReferenceScreen()),
    );
    expect(find.text('Grammar'), findsOneWidget);
    expect(find.text('Tenses'), findsOneWidget);
    expect(find.text('Articles'), findsOneWidget);
    expect(find.text('Prepositions'), findsOneWidget);
    expect(find.text('Present simple'), findsOneWidget);
    expect(find.text('Saved notes'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
