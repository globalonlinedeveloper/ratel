import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ratel/theme.dart';

/// Phase 0.3 (Standardization Master Plan, Pillar A): the token scale +
/// the token-lint gate. RatelSpacing/RatelTypeScale are the toolkit screens
/// adopt in Phase 1; the lint locks MIGRATED screens against hardcoded hex
/// colors and grows its allowlist as each screen is detokenized.

/// Screens that have been brought onto the design system + verified to use
/// theme color tokens only (no raw hex). Grows one entry per Phase-1 screen.
const _migratedScreens = <String>[
  'lib/screens/report_queue_screen.dart',
  'lib/screens/friends_screen.dart',
  'lib/screens/paywall_screen.dart',
  'lib/screens/admin_screen.dart',
  'lib/screens/timed_challenge_screen.dart',
  'lib/screens/section_test_screen.dart',
  'lib/screens/placement_screen.dart',
  'lib/screens/onboarding_screen.dart',
  'lib/screens/auth_screen.dart',
  'lib/screens/home/practice_tab.dart',
  'lib/screens/home/profile_tab.dart',
  'lib/screens/home/learn_tab.dart',
];
final _hexColor = RegExp(r'Color\(0x');

void main() {
  test('RatelSpacing is the 4/8/12/16/24 scale', () {
    expect(RatelSpacing.xs, 4);
    expect(RatelSpacing.sm, 8);
    expect(RatelSpacing.md, 12);
    expect(RatelSpacing.lg, 16);
    expect(RatelSpacing.xl, 24);
  });

  testWidgets('RatelTypeScale exposes display/title/body/caption styles',
      (tester) async {
    late BuildContext ctx;
    await tester.pumpWidget(MaterialApp(
      theme: ratelTheme(),
      home: Builder(builder: (c) {
        ctx = c;
        return const SizedBox();
      }),
    ));
    expect(ctx.displayStyle, isNotNull);
    expect(ctx.titleStyle, isNotNull);
    expect(ctx.bodyStyle, isNotNull);
    expect(ctx.captionStyle, isNotNull);
  });

  test('migrated screens use color tokens (no hardcoded hex Color(0x...))',
      () {
    final offenders = <String>[];
    for (final path in _migratedScreens) {
      final f = File(path);
      expect(f.existsSync(), isTrue, reason: 'missing $path (run from repo root)');
      final lines = f.readAsLinesSync();
      for (var i = 0; i < lines.length; i++) {
        if (_hexColor.hasMatch(lines[i])) {
          offenders.add('$path:${i + 1}  ${lines[i].trim()}');
        }
      }
    }
    expect(offenders, isEmpty,
        reason: 'use RatelColors / context color getters, not raw hex:\n'
            '${offenders.join('\n')}');
  });
}
