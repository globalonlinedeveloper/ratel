import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ratel/app_state.dart';
import 'package:ratel/milestones.dart';
import 'package:ratel/screens/home_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    appState.reset();
  });

  test('sectionForUnit maps every unit and absorbs overflow', () {
    expect(sectionForUnit(0).cefr, 'A1');
    expect(sectionForUnit(2).cefr, 'A1');
    expect(sectionForUnit(3).cefr, 'A2');
    expect(sectionForUnit(6).cefr, 'B1');
    expect(sectionForUnit(9).cefr, 'B1');
    expect(sectionForUnit(25).cefr, 'B1'); // overflow -> last section
  });

  test('startsSection marks exactly the three section heads', () {
    final heads = [for (int u = 0; u < 10; u++) if (startsSection(u)) u];
    expect(heads, [0, 3, 6]);
  });

  testWidgets('the path shows the first section banner', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: HomeScreen()));
    await tester.pump(const Duration(milliseconds: 600));
    expect(find.text('First steps'), findsOneWidget);
    expect(find.text('A1'), findsOneWidget);
    // only A1 is unlocked on a fresh account; locked sections
    // (A2/B1) show a 'Test out' button instead of the units chip
    expect(find.textContaining('/3 units'), findsOneWidget);
    await tester.pump(const Duration(seconds: 1));
  });
}
