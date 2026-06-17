import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ratel/core/theme/theme.dart';
import 'package:ratel/features/social/screens/classroom_screen.dart';

void main() {
  testWidgets('classroom renders join code + roster with no overflow',
      (tester) async {
    tester.view.physicalSize = const Size(360, 820);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      MaterialApp(theme: ratelTheme(), home: const ClassroomScreen()),
    );
    expect(find.text('Classroom'), findsOneWidget);
    expect(find.text('RTL-294'), findsOneWidget);
    expect(find.text('Priya'), findsOneWidget);
    expect(find.text('Manage class'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
