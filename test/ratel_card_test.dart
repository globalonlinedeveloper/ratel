import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ratel/theme.dart';
import 'package:ratel/widgets/ratel_card.dart';
import 'package:ratel/widgets/ratel_tone.dart';

void main() {
  Widget host(Widget child, {ThemeData? theme}) => MaterialApp(
    theme: theme ?? ratelTheme(),
    home: Scaffold(body: child),
  );

  testWidgets('renders its child', (tester) async {
    await tester.pumpWidget(host(const RatelCard(child: Text('Hi'))));
    expect(find.text('Hi'), findsOneWidget);
  });

  testWidgets('onTap fires', (tester) async {
    var taps = 0;
    await tester.pumpWidget(
      host(RatelCard(onTap: () => taps++, child: const Text('Tap'))),
    );
    await tester.tap(find.text('Tap'));
    expect(taps, 1);
  });

  testWidgets('tone resolves through tokens (success bg != surface bg)', (
    tester,
  ) async {
    late Color surfaceBg, successBg;
    await tester.pumpWidget(
      host(
        Builder(
          builder: (c) {
            surfaceBg = c.toneContainer(RatelTone.surface);
            successBg = c.toneContainer(RatelTone.success);
            return const SizedBox();
          },
        ),
      ),
    );
    expect(surfaceBg, isNot(successBg));
    expect(successBg, RatelColors.successBg);
  });

  testWidgets('renders in dark mode', (tester) async {
    await tester.pumpWidget(
      host(
        const RatelCard(tone: RatelTone.danger, child: Text('D')),
        theme: ratelDarkTheme(),
      ),
    );
    expect(find.text('D'), findsOneWidget);
  });

  testWidgets('no overflow at 320px with long content', (tester) async {
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      host(
        const RatelCard(
          child: Text(
            'A reasonably long line of card content that should wrap '
            'cleanly without any RenderFlex overflow at a narrow width.',
          ),
        ),
      ),
    );
    await tester.pump();
  });
}
