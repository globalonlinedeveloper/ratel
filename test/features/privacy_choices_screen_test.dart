import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ratel/core/theme/theme.dart';
import 'package:ratel/features/auth/screens/privacy_choices_screen.dart';

void main() {
  testWidgets('privacy choices render 3 toggles at 360px with no overflow',
      (tester) async {
    tester.view.physicalSize = const Size(360, 820);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      MaterialApp(theme: ratelTheme(), home: const PrivacyChoicesScreen()),
    );
    expect(find.text('Your privacy choices'), findsOneWidget);
    expect(find.text('Personalized ads'), findsOneWidget);
    expect(find.byType(Switch), findsNWidgets(3));
    expect(tester.takeException(), isNull);
  });

  testWidgets('personalized-ads toggle flips on tap', (tester) async {
    await tester.pumpWidget(
      MaterialApp(theme: ratelTheme(), home: const PrivacyChoicesScreen()),
    );
    Switch ads() =>
        tester.widget<Switch>(find.byKey(const ValueKey<String>('priv_ads')));
    expect(ads().value, isFalse);
    await tester.tap(find.byKey(const ValueKey<String>('priv_ads')));
    await tester.pump();
    expect(ads().value, isTrue);
  });
}
