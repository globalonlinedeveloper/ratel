import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ratel/screens/admin_screen.dart';
import 'package:ratel/theme.dart';
import 'package:ratel/widgets/empty_state.dart';
import 'package:ratel/widgets/error_state.dart';
import 'package:ratel/widgets/ratel_scaffold.dart';
import 'package:ratel/widgets/skeleton.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Phase 1 (Standardization Master Plan, Pillar A): admin screens migrated to
/// RatelScaffold, and the data-backed AdminLessonScreen wired to the full
/// state-trio (loading skeleton / empty / error+retry).
/// NOTE: SkeletonBox + RatelMascot animate forever, so use pump(Duration),
/// never pumpAndSettle (which would hang) on the state-trio screens.
void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  Widget host(Widget child) => MaterialApp(theme: ratelTheme(), home: child);
  Widget lesson(Future<List<Map<String, dynamic>>> f) => host(
      AdminLessonScreen(lessonId: 'u1l1', title: 'Lesson 1', futureOverride: f));

  testWidgets('AdminScreen: RatelScaffold header + lists lessons (360px)',
      (tester) async {
    tester.view.physicalSize = const Size(360, 760);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(host(const AdminScreen()));
    await tester.pump();
    expect(find.byType(RatelScaffold), findsOneWidget);
    expect(find.widgetWithText(AppBar, 'Content admin'), findsOneWidget);
    expect(find.byType(ListTile), findsWidgets); // lessons from the course
  });

  testWidgets('AdminLessonScreen: loading shows the skeleton', (tester) async {
    final c = Completer<List<Map<String, dynamic>>>();
    await tester.pumpWidget(lesson(c.future));
    await tester.pump();
    expect(find.byType(SkeletonList), findsOneWidget);
    c.complete(const []); // resolve so nothing is left pending
    await tester.pump(const Duration(milliseconds: 300));
  });

  testWidgets('AdminLessonScreen: data renders rows in RatelScaffold',
      (tester) async {
    await tester.pumpWidget(lesson(Future.value([
      {'id': 'e1', 'sort_order': 1, 'type': 'choice', 'prompt': 'Pick a greeting'},
    ])));
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.byType(RatelScaffold), findsOneWidget);
    expect(find.widgetWithText(AppBar, 'Lesson 1'), findsOneWidget);
    expect(find.text('Pick a greeting'), findsOneWidget);
  });

  testWidgets('AdminLessonScreen: empty shows RatelEmptyState', (tester) async {
    await tester.pumpWidget(lesson(Future.value(const [])));
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.byType(RatelEmptyState), findsOneWidget);
    expect(find.textContaining('No exercises'), findsOneWidget);
  });

  testWidgets('AdminLessonScreen: error shows ErrorState + retry affordance',
      (tester) async {
    final c = Completer<List<Map<String, dynamic>>>();
    await tester.pumpWidget(lesson(c.future));
    await tester.pump();
    c.completeError('boom'); // error AFTER FutureBuilder subscribes (no unhandled-zone error)
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.byType(ErrorState), findsOneWidget);
    expect(find.text('Try again'), findsOneWidget); // retry wired (callback unit-tested in Phase 0.2)
  });

  testWidgets('AdminExerciseEdit: RatelScaffold + editable fields',
      (tester) async {
    await tester.pumpWidget(host(const AdminExerciseEdit(row: {
      'id': 'e1',
      'type': 'choice',
      'prompt': 'P',
      'sentence': '',
      'options': ['a', 'b'],
      'correct_index': 0,
      'correct_order': [],
    })));
    await tester.pump();
    expect(find.byType(RatelScaffold), findsOneWidget);
    expect(find.widgetWithText(AppBar, 'Edit exercise'), findsOneWidget);
    expect(find.byType(TextField), findsWidgets);
  });
}
