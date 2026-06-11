import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ratel/flags.dart';
import 'package:ratel/screens/paywall_screen.dart';

void main() {
  testWidgets('paywall shows the comparison table and flag-driven prices',
      (tester) async {
    Flags.instance.debugSet({'price_year': '₹1,499/yr'});
    await tester.pumpWidget(const MaterialApp(home: PaywallScreen()));
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('Unlimited'), findsOneWidget);
    expect(find.text('20/day'), findsOneWidget);
    // plan cards render lazily below the fold — scroll to them
    await tester.scrollUntilVisible(find.text('₹1,499/yr'), 220,
        scrollable: find.byType(Scrollable).first);
    expect(find.text('₹1,499/yr'), findsOneWidget);
    await tester.scrollUntilVisible(find.text('Restore purchases'), 220,
        scrollable: find.byType(Scrollable).first);
    expect(find.text('Restore purchases'), findsOneWidget);
    Flags.instance.debugSet({});
    await tester.pump(const Duration(seconds: 1));
  });
}
