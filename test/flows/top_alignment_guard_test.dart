import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ratel/core/theme/theme.dart';
import 'package:ratel/features/learn/screens/home_screen.dart';
import 'package:ratel/features/practice/screens/practice_hub_screen.dart';
import 'package:ratel/features/profile/screens/profile_screen.dart';
import 'package:ratel/features/profile/screens/settings_hub_screen.dart';
import 'package:ratel/features/social/screens/leagues_screen.dart';

/// Layout regression guard: on a TALL viewport, the main app screens must keep
/// their first content near the TOP. A vertically-centering `Center` body wrapper
/// (the old bug) pushes content to ~mid-screen; this fails loudly if that returns.
Future<void> _pump(WidgetTester tester, Widget screen) async {
  tester.view.physicalSize = const Size(390, 1400);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  await tester.pumpWidget(MaterialApp(theme: ratelTheme(), home: screen));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('Home content is top-aligned', (tester) async {
    await _pump(tester, const HomeScreen());
    expect(
      tester.getTopLeft(find.byIcon(Icons.local_fire_department)).dy,
      lessThan(250),
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('Practice content is top-aligned', (tester) async {
    await _pump(tester, const PracticeHubScreen());
    expect(tester.getTopLeft(find.text('Practice')).dy, lessThan(250));
    expect(tester.takeException(), isNull);
  });

  testWidgets('Leagues content is top-aligned', (tester) async {
    await _pump(tester, const LeaguesScreen());
    expect(tester.getTopLeft(find.text('Gold League')).dy, lessThan(250));
    expect(tester.takeException(), isNull);
  });

  testWidgets('Profile content is top-aligned', (tester) async {
    await _pump(tester, const ProfileScreen());
    expect(tester.getTopLeft(find.text('raj_learns')).dy, lessThan(250));
    expect(tester.takeException(), isNull);
  });

  testWidgets('Settings content is top-aligned', (tester) async {
    await _pump(tester, const SettingsHubScreen());
    expect(tester.getTopLeft(find.text('Settings')).dy, lessThan(250));
    expect(tester.takeException(), isNull);
  });
}
