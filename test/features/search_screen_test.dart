import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ratel/core/theme/theme.dart';
import 'package:ratel/features/learn/screens/search_screen.dart';

void main() {
  Future<void> pump(WidgetTester tester) async {
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      MaterialApp(theme: ratelTheme(), home: const SearchScreen()),
    );
  }

  testWidgets('search renders field + recent/suggested chips at 360px',
      (tester) async {
    await pump(tester);
    expect(find.text('Search'), findsOneWidget);
    expect(find.byType(TextField), findsOneWidget);
    expect(find.text('Recent'), findsOneWidget);
    expect(find.text('Suggested'), findsOneWidget);
    expect(find.text('Travel'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('typing filters the stub corpus', (tester) async {
    await pump(tester);
    await tester.enterText(find.byType(TextField), 'coffee');
    await tester.pump();
    expect(find.text('Coffee shop chatter'), findsOneWidget);
    expect(find.text('Suggested'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('a miss shows the no-results state', (tester) async {
    await pump(tester);
    await tester.enterText(find.byType(TextField), 'zxqv');
    await tester.pump();
    expect(find.text('No matches'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
