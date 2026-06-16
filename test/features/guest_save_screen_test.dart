import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ratel/core/theme/theme.dart';
import 'package:ratel/features/auth/screens/guest_save_screen.dart';

void main() {
  testWidgets('guest-save renders rewards at 360px with no overflow',
      (tester) async {
    tester.view.physicalSize = const Size(360, 820);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      MaterialApp(theme: ratelTheme(), home: const GuestSaveScreen()),
    );
    expect(find.text('Nice — first lesson done!'), findsOneWidget);
    expect(find.text('+10'), findsOneWidget);
    expect(find.text('Save with email'), findsOneWidget);
    expect(find.text('Maybe later'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
