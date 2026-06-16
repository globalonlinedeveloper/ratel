import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ratel/theme.dart';
import 'package:ratel/widgets/ratel_stat_tile.dart';
import 'package:ratel/widgets/ratel_tone.dart';

void main() {
  Widget host(Widget child, {ThemeData? theme}) => MaterialApp(
    theme: theme ?? ratelTheme(),
    home: Scaffold(body: child),
  );

  testWidgets('renders icon, value and label', (tester) async {
    await tester.pumpWidget(
      host(
        const RatelStatTile(
          icon: Icons.local_fire_department,
          value: '12',
          label: 'Day streak',
        ),
      ),
    );
    expect(find.text('12'), findsOneWidget);
    expect(find.text('Day streak'), findsOneWidget);
    expect(find.byIcon(Icons.local_fire_department), findsOneWidget);
  });

  testWidgets('tone tints the container (win != surface)', (tester) async {
    late Color winBg, surfBg;
    await tester.pumpWidget(
      host(
        Builder(
          builder: (c) {
            winBg = c.toneContainer(RatelTone.win);
            surfBg = c.toneContainer(RatelTone.surface);
            return const SizedBox();
          },
        ),
      ),
    );
    expect(winBg, isNot(surfBg));
  });

  testWidgets('row of tiles: no overflow at 320px (dark)', (tester) async {
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      host(
        const Row(
          children: [
            Expanded(
              child: RatelStatTile(
                icon: Icons.bolt,
                value: '320',
                label: 'XP',
                tone: RatelTone.energy,
              ),
            ),
            SizedBox(width: 8),
            Expanded(
              child: RatelStatTile(
                icon: Icons.star,
                value: '98%',
                label: 'Accuracy',
                tone: RatelTone.success,
              ),
            ),
          ],
        ),
        theme: ratelDarkTheme(),
      ),
    );
    await tester.pump();
  });
}
