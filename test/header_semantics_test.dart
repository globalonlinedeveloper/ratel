import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ratel/app_state.dart';
import 'package:ratel/content.dart';
import 'package:ratel/screens/home_screen.dart';
import 'package:ratel/screens/lesson_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Inc 136 (QA #2 P3 pair):
/// (a) The header streak stat opens its popover — QA's coordinate clicks
///     (x>=296) missed the narrow stat (~x 239-269 for a fresh user) because
///     nothing in the header was addressable by semantics label. The stats
///     now carry Semantics(button + label) merged with the InkWell tap.
/// (b) The lesson quit X exposed no "Close" semantics — screen readers and
///     the Inc-129d tour pattern couldn't reach the quit dialog.
void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    appState.reset();
    appState.loaded = true;
  });

  Future<void> pumpHome(WidgetTester t) async {
    await t.pumpWidget(const MaterialApp(home: HomeScreen()));
    await t.pump(const Duration(milliseconds: 800));
  }

  testWidgets('streak popover opens from the header at streak=0',
      (tester) async {
    await pumpHome(tester);
    await tester.tap(find.byKey(const Key('streak_stat')));
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.text('0-day streak'), findsOneWidget);
    expect(find.textContaining('Freezes:'), findsOneWidget);
  });

  testWidgets('streak popover opens from the header at streak>=1',
      (tester) async {
    appState.streak = 7;
    await pumpHome(tester);
    await tester.tap(find.byKey(const Key('streak_stat')));
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.text('7-day streak'), findsOneWidget);
  });

  testWidgets('header stats carry semantics labels (streak/gems/hearts)',
      (tester) async {
    final handle = tester.ensureSemantics();
    await pumpHome(tester);
    expect(find.bySemanticsLabel(RegExp('Streak')), findsOneWidget);
    expect(find.bySemanticsLabel(RegExp('Gems')), findsOneWidget);
    expect(find.bySemanticsLabel(RegExp('Hearts')), findsOneWidget);
    handle.dispose();
  });

  testWidgets('quit X exposes Close semantics and still drives the dialog',
      (tester) async {
    appState.hearts = 5;
    await tester.pumpWidget(MaterialApp(
      home: Builder(
        builder: (c) => Scaffold(
          body: Center(
            child: FilledButton(
              onPressed: () => Navigator.of(c).push(MaterialPageRoute(
                  builder: (_) => LessonScreen(
                      lesson: builtInCourse.first.lessons.first))),
              child: const Text('open'),
            ),
          ),
        ),
      ),
    ));
    await tester.tap(find.text('open'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));

    // the a11y contract QA probed for: an element labelled "Close"
    expect(find.byTooltip('Close'), findsOneWidget);

    // make progress so quitting is "at stake", then operate ENTIRELY via
    // the labelled element (the semantics route).
    await tester.tap(find.text('Hello').first);
    await tester.pump(const Duration(milliseconds: 150));
    await tester.tap(find.text('Check'));
    await tester.pump(const Duration(milliseconds: 400));
    await tester.tap(find.byTooltip('Close'));
    await tester.pump(const Duration(milliseconds: 350));
    expect(find.text("Wait, don't go!"), findsOneWidget);
    await tester.tap(find.text('Quit'));
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.text('open'), findsOneWidget); // back on the launcher
    appState.hearts = 5;
  });
}
