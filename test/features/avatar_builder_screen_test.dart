import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ratel/core/theme/theme.dart';
import 'package:ratel/features/profile/screens/avatar_builder_screen.dart';

void main() {
  testWidgets('avatar builder renders with no overflow', (tester) async {
    tester.view.physicalSize = const Size(360, 820);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      MaterialApp(theme: ratelTheme(), home: const AvatarBuilderScreen()),
    );
    expect(find.text('Edit avatar'), findsOneWidget);
    expect(find.text('Username · raj_learns'), findsOneWidget);
    expect(find.text('Save'), findsOneWidget);
    expect(find.byType(TextField), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
