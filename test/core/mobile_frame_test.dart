import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ratel/core/theme/theme.dart';
import 'package:ratel/core/widgets/mobile_frame.dart';

void main() {
  Future<void> pumpAt(WidgetTester tester, Size size) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(MaterialApp(
      theme: ratelTheme(),
      home: const MobileFrame(child: Text('hello')),
    ));
  }

  testWidgets('narrow viewport passes through (no frame caption)',
      (tester) async {
    await pumpAt(tester, const Size(360, 800));
    expect(find.text('hello'), findsOneWidget);
    expect(find.textContaining('Mobile preview'), findsNothing);
  });

  testWidgets('wide viewport renders the phone frame + caption',
      (tester) async {
    await pumpAt(tester, const Size(1200, 900));
    expect(find.text('hello'), findsOneWidget);
    expect(find.textContaining('Mobile preview'), findsOneWidget);
  });
}
