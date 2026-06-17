import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ratel/core/theme/theme.dart';
import 'package:ratel/features/profile/screens/privacy_data_screen.dart';

void main() {
  testWidgets('privacy & data renders consent toggles with no overflow',
      (tester) async {
    tester.view.physicalSize = const Size(360, 820);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      MaterialApp(theme: ratelTheme(), home: const PrivacyDataScreen()),
    );
    expect(find.text('Privacy & data'), findsOneWidget);
    expect(find.text('Analytics'), findsOneWidget);
    expect(find.text('Export my data'), findsOneWidget);
    expect(find.text('Delete my data'), findsOneWidget);
    expect(find.byType(Switch), findsNWidgets(3));
    expect(tester.takeException(), isNull);
  });
}
