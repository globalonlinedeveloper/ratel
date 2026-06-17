import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ratel/core/theme/theme.dart';
import 'package:ratel/design_system/components/lesson_top_bar.dart';
import 'package:ratel/design_system/components/ratel_bottom_nav.dart';
import 'package:ratel/design_system/components/ratel_settings_row.dart';

/// P2-3 screen-reader pass: the design-system controls that icon-only surfaces
/// lean on must expose accessible labels + state to assistive tech.
void main() {
  testWidgets('RatelBottomNav: every tab is labelled, current tab is selected',
      (tester) async {
    final handle = tester.ensureSemantics();
    await tester.pumpWidget(
      MaterialApp(
        theme: ratelTheme(),
        home: const Scaffold(body: RatelBottomNav(currentIndex: 0)),
      ),
    );
    // Current tab: labelled (tooltip), a button, and announced as selected.
    expect(
      tester.getSemantics(find.byTooltip('Home')),
      isSemantics(tooltip: 'Home', isButton: true, isSelected: true),
    );
    // Other tabs: labelled buttons that are NOT selected.
    for (final String label in <String>['Practice', 'Leagues', 'Profile']) {
      expect(
        tester.getSemantics(find.byTooltip(label)),
        isSemantics(tooltip: label, isButton: true, isSelected: false),
      );
    }
    expect(tester.takeException(), isNull);
    handle.dispose();
  });

  testWidgets('Interactive RatelSettingsRow is a labelled button', (tester) async {
    final handle = tester.ensureSemantics();
    await tester.pumpWidget(
      MaterialApp(
        theme: ratelTheme(),
        home: Scaffold(
          body: RatelSettingsRow(
            icon: Icons.person_outline,
            iconColor: Colors.teal,
            label: 'Account',
            onTap: () {},
          ),
        ),
      ),
    );
    final node = tester.getSemantics(find.text('Account'));
    expect(node.label, contains('Account'));
    expect(node, isSemantics(isButton: true));
    expect(tester.takeException(), isNull);
    handle.dispose();
  });

  testWidgets('Non-interactive RatelSettingsRow is not a button', (tester) async {
    final handle = tester.ensureSemantics();
    await tester.pumpWidget(
      MaterialApp(
        theme: ratelTheme(),
        home: const Scaffold(
          body: RatelSettingsRow(
            icon: Icons.widgets_outlined,
            iconColor: Colors.grey,
            label: 'Widgets',
          ),
        ),
      ),
    );
    expect(
      tester.getSemantics(find.text('Widgets')),
      isSemantics(isButton: false),
    );
    expect(tester.takeException(), isNull);
    handle.dispose();
  });

  testWidgets('LessonTopBar labels close + energy for screen readers',
      (tester) async {
    final handle = tester.ensureSemantics();
    await tester.pumpWidget(
      MaterialApp(
        theme: ratelTheme(),
        home: const Scaffold(body: LessonTopBar(progress: 0.4, energy: 3)),
      ),
    );
    expect(
      tester.getSemantics(find.byIcon(Icons.close)),
      isSemantics(tooltip: 'Close', isButton: true),
    );
    expect(find.semantics.byLabel('Energy remaining: 3').evaluate(), hasLength(1));
    expect(tester.takeException(), isNull);
    handle.dispose();
  });
}
