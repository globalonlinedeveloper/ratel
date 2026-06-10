import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ratel/theme.dart';
import 'package:ratel/widgets/pulse.dart';
import 'package:ratel/widgets/skeleton.dart';
import 'package:ratel/widgets/empty_state.dart';
import 'package:ratel/widgets/stagger.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Pulse renders its child', (tester) async {
    await tester.pumpWidget(
        const MaterialApp(home: Pulse(child: Text('star'))));
    await tester.pump(const Duration(milliseconds: 200));
    expect(find.text('star'), findsOneWidget);
  });

  testWidgets('SkeletonList shows the requested rows', (tester) async {
    await tester.pumpWidget(const MaterialApp(
        home: Scaffold(body: SkeletonList(rows: 3, height: 40))));
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.byType(SkeletonBox), findsNWidgets(3));
  });

  testWidgets('RatelEmptyState shows title and subtitle', (tester) async {
    await tester.pumpWidget(const MaterialApp(
        home: Scaffold(
            body: RatelEmptyState(
                title: 'Nothing here', subtitle: 'Do a thing'))));
    expect(find.text('Nothing here'), findsOneWidget);
    expect(find.text('Do a thing'), findsOneWidget);
  });

  testWidgets('StaggeredIn reveals the child (and is hit-testable)',
      (tester) async {
    int taps = 0;
    await tester.pumpWidget(MaterialApp(
        home: Scaffold(
            body: StaggeredIn(
                index: 3,
                child: TextButton(
                    onPressed: () => taps++, child: const Text('row'))))));
    await tester.pump(const Duration(milliseconds: 50));
    await tester.tap(find.text('row')); // mid-animation tap must land
    await tester.pump(const Duration(milliseconds: 600));
    expect(find.text('row'), findsOneWidget);
    expect(taps, 1);
  });

  test('reduce-motion preference persists', () async {
    SharedPreferences.setMockInitialValues({});
    await setReduceMotion(true);
    expect(reduceMotionNotifier.value, isTrue);
    reduceMotionNotifier.value = false;
    await loadReduceMotion();
    expect(reduceMotionNotifier.value, isTrue);
    await setReduceMotion(false);
  });

  testWidgets('StaggeredIn is instant under reduce-motion', (tester) async {
    reduceMotionNotifier.value = true;
    await tester.pumpWidget(const MaterialApp(
        home: Scaffold(body: StaggeredIn(index: 5, child: Text('now')))));
    expect(tester.widget<StaggeredIn>(find.byType(StaggeredIn)).child,
        isA<Text>());
    expect(find.text('now'), findsOneWidget);
    reduceMotionNotifier.value = false;
  });
}
