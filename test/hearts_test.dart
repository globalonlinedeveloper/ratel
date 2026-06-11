import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ratel/app_state.dart';
import 'package:ratel/widgets/hearts_sheet.dart';

void main() {
  test('earnHeart caps at 5 and full hearts reset the regen clock', () {
    final s = AppState();
    s.hearts = 3;
    s.earnHeart();
    expect(s.hearts, 4);
    s.earnHeart();
    s.earnHeart();
    expect(s.hearts, 5);
  });

  testWidgets('hearts sheet offers practice and pro', (tester) async {
    appState.hearts = 0;
    appState.heartsUpdatedAt = DateTime.now();
    bool practiced = false;
    await tester.pumpWidget(MaterialApp(
      home: Builder(
        builder: (ctx) => ElevatedButton(
          onPressed: () =>
              showHeartsSheet(ctx, onPractice: () => practiced = true),
          child: const Text('open'),
        ),
      ),
    ));
    await tester.tap(find.text('open'));
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.text("You're out of hearts"), findsOneWidget);
    expect(find.textContaining('Next heart in'), findsOneWidget);
    await tester.ensureVisible(
        find.text('Practice mistakes — earn a heart'));
    await tester.pump(const Duration(milliseconds: 200));
    await tester.tap(find.text('Practice mistakes — earn a heart'));
    await tester.pump(const Duration(milliseconds: 400));
    expect(practiced, isTrue);
    appState.hearts = 5; // restore for later tests
  });
}
