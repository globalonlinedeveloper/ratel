import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ratel/core/theme/theme.dart';
import 'package:ratel/features/auth/screens/parental_consent_screen.dart';

void main() {
  testWidgets('parental consent renders at 360px with no overflow',
      (tester) async {
    tester.view.physicalSize = const Size(360, 820);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      MaterialApp(theme: ratelTheme(), home: const ParentalConsentScreen()),
    );
    expect(find.text('Ask a parent to continue'), findsOneWidget);
    expect(find.text('Verify via DigiLocker'), findsOneWidget);
    expect(find.text('Send request'), findsOneWidget);
    expect(find.byType(TextField), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
