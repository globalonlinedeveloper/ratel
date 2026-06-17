import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ratel/core/theme/theme.dart';
import 'package:ratel/design_system/components/ratel_button.dart';
import 'package:ratel/features/auth/screens/set_new_password_screen.dart';

void main() {
  testWidgets('set-new-password renders at 360px with no overflow',
      (tester) async {
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      MaterialApp(theme: ratelTheme(), home: const SetNewPasswordScreen()),
    );
    expect(find.text('Set a new password'), findsOneWidget);
    expect(find.text('Save password'), findsOneWidget);
    expect(find.byType(TextField), findsNWidgets(2));
    expect(tester.takeException(), isNull);
  });

  testWidgets('Save disabled until password valid and confirm matches',
      (tester) async {
    await tester.pumpWidget(
      MaterialApp(theme: ratelTheme(), home: const SetNewPasswordScreen()),
    );
    RatelButton cta() => tester.widget<RatelButton>(
        find.widgetWithText(RatelButton, 'Save password'));
    expect(cta().onPressed, isNull);
    await tester.enterText(find.byType(TextField).at(0), 'abc');
    await tester.enterText(find.byType(TextField).at(1), 'abc');
    await tester.pump();
    expect(cta().onPressed, isNull); // too short
    await tester.enterText(find.byType(TextField).at(0), 'abcd1234');
    await tester.enterText(find.byType(TextField).at(1), 'abcd9999');
    await tester.pump();
    expect(cta().onPressed, isNull); // mismatch
    expect(find.text("Passwords don't match"), findsOneWidget);
    await tester.enterText(find.byType(TextField).at(1), 'abcd1234');
    await tester.pump();
    expect(cta().onPressed, isNotNull);
  });
}
