import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ratel/theme.dart';
import 'package:ratel/widgets/ratel_chip.dart';
import 'package:ratel/widgets/ratel_tone.dart';

void main() {
  Widget host(Widget child, {ThemeData? theme}) => MaterialApp(
    theme: theme ?? ratelTheme(),
    home: Scaffold(body: child),
  );

  testWidgets('renders label and fires onTap', (tester) async {
    var n = 0;
    await tester.pumpWidget(host(RatelChip(label: 'Daily', onTap: () => n++)));
    expect(find.text('Daily'), findsOneWidget);
    await tester.tap(find.text('Daily'));
    expect(n, 1);
  });

  testWidgets('selected vs unselected change the label color', (tester) async {
    await tester.pumpWidget(
      host(
        Column(
          children: const [
            RatelChip(label: 'On', selected: true),
            RatelChip(label: 'Off', selected: false),
          ],
        ),
      ),
    );
    final on = tester.widget<Text>(find.text('On')).style!.color;
    final off = tester.widget<Text>(find.text('Off')).style!.color;
    expect(on, isNot(off));
  });

  testWidgets('icon + dark mode render', (tester) async {
    await tester.pumpWidget(
      host(
        const RatelChip(
          label: 'Gems',
          icon: Icons.diamond,
          tone: RatelTone.info,
        ),
        theme: ratelDarkTheme(),
      ),
    );
    expect(find.text('Gems'), findsOneWidget);
    expect(find.byIcon(Icons.diamond), findsOneWidget);
  });

  testWidgets('no overflow at 320px with a long label', (tester) async {
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      host(
        const Align(
          alignment: Alignment.centerLeft,
          child: SizedBox(
            width: 180,
            child: RatelChip(
              label: 'A very long selectable chip label that must ellipsize',
            ),
          ),
        ),
      ),
    );
    await tester.pump();
  });
}
