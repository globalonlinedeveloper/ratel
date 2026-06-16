import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ratel/core/theme/theme.dart';
import 'package:ratel/design_system/components/ratel_choice_chip.dart';
import 'package:ratel/design_system/components/ratel_option_tile.dart';
import 'package:ratel/design_system/components/ratel_select_field.dart';

Widget _wrap(Widget child) =>
    MaterialApp(theme: ratelTheme(), home: Scaffold(body: Center(child: child)));

void main() {
  testWidgets('RatelChoiceChip renders and fires onTap', (tester) async {
    var taps = 0;
    await tester.pumpWidget(_wrap(RatelChoiceChip(
        label: 'Career', selected: true, onTap: () => taps++)));
    expect(find.text('Career'), findsOneWidget);
    await tester.tap(find.text('Career'));
    expect(taps, 1);
  });

  testWidgets('RatelOptionTile shows title, subtitle and trailing',
      (tester) async {
    await tester.pumpWidget(_wrap(RatelOptionTile(
      title: 'Regular',
      subtitle: 'Recommended',
      trailing: '20 XP / day',
      selected: true,
      onTap: () {},
    )));
    expect(find.text('Regular'), findsOneWidget);
    expect(find.text('Recommended'), findsOneWidget);
    expect(find.text('20 XP / day'), findsOneWidget);
  });

  testWidgets('RatelSelectField shows label + chevron', (tester) async {
    await tester.pumpWidget(_wrap(RatelSelectField(
        label: 'English', leadingIcon: Icons.flag, active: true, onTap: () {})));
    expect(find.text('English'), findsOneWidget);
    expect(find.byIcon(Icons.expand_more), findsOneWidget);
  });
}
