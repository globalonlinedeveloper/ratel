import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ratel/screens/auth_screen.dart';

void main() {
  testWidgets('auth lays out at 360px (headerless root, tokenized)',
      (tester) async {
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(const MaterialApp(home: AuthScreen()));
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('Ratel'), findsOneWidget);
    expect(find.text('Log in'), findsOneWidget); // default mode = sign-in
    expect(tester.takeException(), isNull); // RenderFlex overflow -> failure
  });
}
