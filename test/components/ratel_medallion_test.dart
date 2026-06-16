import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ratel/core/theme/theme.dart';
import 'package:ratel/design_system/components/ratel_medallion.dart';

void main() {
  testWidgets('RatelMedallion renders its icon (circle default)',
      (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: ratelTheme(),
        home: const Scaffold(
          body: Center(
            child: RatelMedallion(
              icon: Icons.star,
              background: Colors.amber,
              foreground: Colors.white,
            ),
          ),
        ),
      ),
    );
    expect(find.byIcon(Icons.star), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('RatelMedallion supports a rounded-square via cornerRadius',
      (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: ratelTheme(),
        home: const Scaffold(
          body: Center(
            child: RatelMedallion(
              icon: Icons.rocket_launch,
              background: Colors.green,
              foreground: Colors.white,
              size: 80,
              iconSize: 40,
              cornerRadius: 20,
            ),
          ),
        ),
      ),
    );
    expect(find.byIcon(Icons.rocket_launch), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
