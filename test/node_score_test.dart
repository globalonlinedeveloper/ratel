import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ratel/app_state.dart';
import 'package:ratel/content_store.dart';
import 'package:ratel/milestones.dart';
import 'package:ratel/nodes.dart';
import 'package:ratel/score.dart';
import 'package:ratel/screens/home_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    appState.reset();
    Nodes.instance.debugSet({});
    ContentStore.instance.debugSetLessonNode({});
  });
  tearDown(() {
    appState.reset();
    Nodes.instance.debugSet({});
    ContentStore.instance.debugSetLessonNode({});
  });

  test('falls back to the legacy score when node data is absent', () {
    appState.streak = 4; // no nodes, no lessonNode, no attempts
    expect(appState.englishScoreNode(50), currentEnglishScore(0, 50, 4));
    expect(appState.englishScoreNode(50), 4);
  });

  test('uses node mastery when curriculum + attempts are present', () {
    Nodes.instance.debugSet({'n1': 'A1', 'n2': 'B1'});
    ContentStore.instance.debugSetLessonNode({'u1l1': 'n1'});
    appState.debugSetAttempts([
      (key: 'u1l1:0', correct: true),
      (key: 'u1l1:0', correct: true),
      (key: 'u1l1:0', correct: true),
    ]);
    // n1 mastered (A1, w=1); n2 untouched (B1, w=3) => 100*1/(1+3) = 25.
    expect(appState.englishScoreNode(50), 25);
    expect(cefrFor(appState.englishScoreNode(50)), 'A2');
  });

  test('weak skills surface from the user tally', () {
    Nodes.instance.debugSet({'node:gen.a1.past-simple': 'A1'});
    ContentStore.instance
        .debugSetLessonNode({'u9l1': 'node:gen.a1.past-simple'});
    appState.debugSetAttempts([
      (key: 'u9l1:0', correct: false),
      (key: 'u9l1:1', correct: false),
      (key: 'u9l1:2', correct: true),
      (key: 'u9l1:3', correct: false), // 1/4 = 25% -> weak
    ]);
    final weak = weakNodes(appState.nodeTally);
    expect(weak, contains('node:gen.a1.past-simple'));
    expect(nodeLabel(weak.first), 'Past simple');
  });

  testWidgets('the Profile score card renders the node score (band A2, not A1)',
      (tester) async {
    Nodes.instance.debugSet({'n1': 'A1', 'n2': 'B1'});
    ContentStore.instance.debugSetLessonNode({'u1l1': 'n1'});
    appState.debugSetAttempts([
      (key: 'u1l1:0', correct: true),
      (key: 'u1l1:0', correct: true),
      (key: 'u1l1:0', correct: true),
    ]);
    await tester.pumpWidget(const MaterialApp(home: HomeScreen()));
    await tester.pump(const Duration(milliseconds: 600));
    await tester.tap(find.text('Profile'));
    await tester.pump(const Duration(milliseconds: 600));
    await tester.pump(const Duration(seconds: 1)); // settle RollingNumber
    expect(find.text('English Score'), findsOneWidget);
    // Legacy score here would be 0 -> 'A1'; the node score is 25 -> 'A2'.
    expect(find.text('A2'), findsOneWidget);
    await tester.pump(const Duration(seconds: 1));
  });
}
