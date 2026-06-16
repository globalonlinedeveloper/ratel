import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ratel/core/theme/theme.dart';
import 'package:ratel/features/auth/screens/delete_account_screen.dart';

void main() {
  testWidgets('delete-account renders at 360px with no overflow',
      (tester) async {
    tester.view.physicalSize = const Size(360, 820);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      MaterialApp(theme: ratelTheme(), home: const DeleteAccountScreen()),
    );
    expect(find.text('Delete your account?'), findsOneWidget);
    expect(find.text('Delete account'), findsOneWidget);
    expect(find.text('Reason (optional)'), findsOneWidget);
    expect(find.byType(TextField), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
