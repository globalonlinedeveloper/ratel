import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ratel/app_state.dart';
import 'package:ratel/content.dart';
import 'package:ratel/guidebook.dart';
import 'package:ratel/screens/home_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    appState.reset();
  });

  test('guidebookFor derives a key phrase per lesson', () {
    final g = guidebookFor(builtInCourse.first);
    expect(g.length, builtInCourse.first.lessons.length);
    expect(g.first.$1, 'Greetings');
    expect(g.first.$2, 'How are you?'); // first sentence-filled choice
    for (final e in g) {
      expect(e.$2.isNotEmpty, isTrue, reason: e.$1);
    }
  });

  testWidgets('tapping a unit banner opens its guidebook', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: HomeScreen()));
    await tester.pump(const Duration(milliseconds: 600));
    // let the path's auto-scroll animation finish (the scrollable
    // ignores pointers while animating), then settle the target
    await tester.pump(const Duration(milliseconds: 700));
    await tester
        .ensureVisible(find.text(builtInCourse.first.subtitle).first);
    await tester.tap(find.text(builtInCourse.first.subtitle).first);
    await tester.pump(); // sheet route in
    await tester.pump(const Duration(milliseconds: 450)); // slide up
    expect(find.textContaining('Guidebook ·'), findsOneWidget);
    expect(find.text('How are you?'), findsOneWidget);
    await tester.pump(const Duration(seconds: 1));
  });

  testWidgets('unit banner is a labelled semantics button (Inc 138 — the '
      'browser/a11y route QA could not find)', (tester) async {
    final handle = tester.ensureSemantics();
    await tester.pumpWidget(const MaterialApp(home: HomeScreen()));
    await tester.pump(const Duration(milliseconds: 600));
    await tester.pump(const Duration(milliseconds: 700));
    expect(find.bySemanticsLabel(RegExp('Open guidebook')), findsWidgets);
    handle.dispose();
    await tester.pump(const Duration(seconds: 1));
  });
}
