import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ratel/app_state.dart';
import 'package:ratel/widgets/achievements_view.dart';
import 'package:ratel/widgets/share_card.dart';

void main() {
  testWidgets('locked achievements show their icon with a progress ring',
      (tester) async {
    appState.xp = 0;
    await tester.pumpWidget(const MaterialApp(
        home: Scaffold(
            body: SingleChildScrollView(child: AchievementsView()))));
    await tester.pump(const Duration(milliseconds: 200));
    expect(find.byIcon(Icons.lock_outline), findsNothing);
    expect(find.byType(CircularProgressIndicator), findsWidgets);
  });

  testWidgets('share card shows the streak and copies the invite',
      (tester) async {
    appState.friendCode = 'ABC123';
    await tester.pumpWidget(MaterialApp(
      home: Builder(
        builder: (ctx) => Scaffold(
          body: ElevatedButton(
              onPressed: () => showShareCard(ctx),
              child: const Text('share')),
        ),
      ),
    ));
    await tester.tap(find.text('share'));
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.textContaining('day streak'), findsOneWidget);
    expect(find.text('Copy invite text'), findsOneWidget);
  });
}
