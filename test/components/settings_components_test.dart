import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ratel/core/theme/theme.dart';
import 'package:ratel/design_system/components/ratel_settings_row.dart';
import 'package:ratel/design_system/components/ratel_toggle_row.dart';

void main() {
  testWidgets('RatelSettingsRow renders + fires onTap', (tester) async {
    var taps = 0;
    await tester.pumpWidget(MaterialApp(
      theme: ratelTheme(),
      home: Scaffold(
        body: RatelSettingsRow(
          icon: Icons.volume_up,
          iconColor: Colors.green,
          label: 'Audio',
          onTap: () => taps++,
        ),
      ),
    ));
    expect(find.text('Audio'), findsOneWidget);
    await tester.tap(find.text('Audio'));
    expect(taps, 1);
  });

  testWidgets('RatelToggleRow renders + flips', (tester) async {
    bool value = false;
    await tester.pumpWidget(MaterialApp(
      theme: ratelTheme(),
      home: Scaffold(
        body: StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) => RatelToggleRow(
            label: 'Captions',
            value: value,
            onChanged: (bool v) => setState(() => value = v),
          ),
        ),
      ),
    ));
    expect(find.text('Captions'), findsOneWidget);
    await tester.tap(find.byType(Switch));
    await tester.pump();
    expect(value, isTrue);
  });
}
