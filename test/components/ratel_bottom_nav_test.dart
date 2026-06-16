import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ratel/core/theme/theme.dart';
import 'package:ratel/design_system/components/ratel_bottom_nav.dart';

void main() {
  testWidgets('bottom nav renders 4 tabs and reports taps', (tester) async {
    int? tapped;
    await tester.pumpWidget(
      MaterialApp(
        theme: ratelTheme(),
        home: Scaffold(
          body: RatelBottomNav(currentIndex: 0, onTap: (int i) => tapped = i),
        ),
      ),
    );
    expect(find.byType(IconButton), findsNWidgets(4));
    await tester.tap(find.byTooltip('Practice'));
    expect(tapped, 1);
  });
}
