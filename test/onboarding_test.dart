import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ratel/screens/onboarding_screen.dart';

void main() {
  testWidgets('onboarding lays out at 360px (headerless root, tokenized)',
      (tester) async {
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(const MaterialApp(home: OnboardingScreen()));
    // RatelMascot loops -> pumpAndSettle would hang; advance a fixed slice.
    await tester.pump(const Duration(milliseconds: 300));
    // Body is a lazy ListView: below-the-fold children (the Start CTA) are not
    // built at 360x800, so assert top-of-fold content + the no-overflow check.
    expect(find.text('Welcome to Ratel!'), findsOneWidget);
    expect(find.byType(SegmentedButton<String>), findsOneWidget); // lang picker
    expect(tester.takeException(), isNull); // RenderFlex overflow -> failure
  });
}
