import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ratel/theme.dart';
import 'package:ratel/widgets/ratel_mascot.dart';
import 'package:ratel/widgets/ratel_puppet.dart';

void main() {
  testWidgets('puppet renders its parts when assets are bundled',
      (tester) async {
    reduceMotionNotifier.value = false;
    await tester.pumpWidget(const MaterialApp(home: RatelPuppet()));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.byType(Image), findsWidgets);
    expect(find.byType(RatelMascot), findsNothing);
  });

  testWidgets('puppet falls back to the static mascot under reduce-motion',
      (tester) async {
    reduceMotionNotifier.value = true;
    await tester.pumpWidget(const MaterialApp(home: RatelPuppet()));
    await tester.pump();
    expect(find.byType(RatelMascot), findsOneWidget);
    reduceMotionNotifier.value = false;
  });
}
