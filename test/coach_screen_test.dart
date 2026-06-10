import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ratel/screens/coach_screen.dart';

void main() {
  testWidgets('Coach: greeting shows; send renders user msg and tutor reply',
      (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: CoachScreen(
          // Delay so the in-flight "typing" state renders at least one frame.
          sender: (history) async {
            await Future<void>.delayed(const Duration(milliseconds: 200));
            return 'Better: "I went home." Nice! What happened next?';
          },
        ),
      ),
    ));
    expect(find.textContaining("I'm Ratel"), findsOneWidget);
    await tester.enterText(find.byType(TextField), 'I goed home');
    await tester.tap(find.byIcon(Icons.send));
    await tester.pump();
    expect(find.text('Ratel is typing...'), findsOneWidget);
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pump();
    expect(find.textContaining('I goed home'), findsOneWidget);
    expect(find.textContaining('What happened next'), findsOneWidget);
    expect(find.text('Ratel is typing...'), findsNothing);
  });

  testWidgets('Coach: starter chips send a topic then disappear',
      (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(body: CoachScreen(sender: (h) async => 'Great topic!')),
    ));
    expect(find.byType(ActionChip), findsWidgets);
    await tester.tap(find.byType(ActionChip).first);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.byType(ActionChip), findsNothing);
    expect(find.textContaining('Great topic!'), findsOneWidget);
  });

  testWidgets('Coach: history passed to sender includes the user message',
      (tester) async {
    List<ChatMsg>? captured;
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: CoachScreen(sender: (h) async {
          captured = h;
          return 'ok';
        }),
      ),
    ));
    await tester.enterText(find.byType(TextField), 'Hello coach');
    await tester.tap(find.byIcon(Icons.send));
    await tester.pump(const Duration(milliseconds: 400));
    expect(captured, isNotNull);
    expect(captured!.last.role, 'user');
    expect(captured!.last.text, 'Hello coach');
  });
}
