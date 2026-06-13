import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ratel/app_state.dart';
import 'package:ratel/models.dart';
import 'package:ratel/screens/auth_screen.dart';
import 'package:ratel/screens/home_screen.dart';
import 'package:ratel/screens/lesson_screen.dart';
import 'package:ratel/screens/onboarding_screen.dart';
import 'package:ratel/screens/paywall_screen.dart';
import 'package:ratel/screens/placement_screen.dart';
import 'package:ratel/strings.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Inc 144 (Dataset P1) -- pseudo-locale overflow gate (Master Plan §9.4).
// Inflates EVERY rendered string ~40% with accents and pumps core surfaces at
// 360px. Unlike the Tamil gauntlet (enumerated keys) this covers ALL strings,
// so a too-long real language is caught at layout time before it ever ships.
const Exercise _c = Exercise.choice(
    prompt: 'Pick the greeting', options: ['Hello', 'Car', 'Run'],
    correctIndex: 0);

void _narrowPseudo(WidgetTester tester) {
  tester.view.physicalSize = const Size(360, 690);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);
  S.instance.locale = 'en';
  S.instance.pseudo = true; // every t() result inflated + accented
  addTearDown(() => S.instance.pseudo = false);
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    appState.reset();
    appState.hearts = 5;
  });
  tearDown(() {
    S.instance.pseudo = false;
    S.instance.locale = 'en';
    S.instance.debugClear();
  });

  testWidgets('auth screen: pseudo-locale at 360px, no overflow',
      (tester) async {
    _narrowPseudo(tester);
    await tester.pumpWidget(const MaterialApp(home: AuthScreen()));
    await tester.pump(const Duration(milliseconds: 600));
    expect(tester.takeException(), isNull);
    expect(find.byType(AuthScreen), findsOneWidget);
  });

  testWidgets('onboarding screen: pseudo-locale at 360px, no overflow',
      (tester) async {
    _narrowPseudo(tester);
    await tester.pumpWidget(const MaterialApp(home: OnboardingScreen()));
    await tester.pump(const Duration(milliseconds: 600));
    expect(tester.takeException(), isNull);
  });

  testWidgets('placement screen: pseudo-locale at 360px, no overflow',
      (tester) async {
    _narrowPseudo(tester);
    await tester.pumpWidget(const MaterialApp(home: PlacementScreen(goal: 20)));
    await tester.pump(const Duration(milliseconds: 600));
    expect(tester.takeException(), isNull);
  });

  testWidgets('paywall screen: pseudo-locale at 360px, no overflow',
      (tester) async {
    _narrowPseudo(tester);
    await tester.pumpWidget(const MaterialApp(home: PaywallScreen()));
    await tester.pump(const Duration(milliseconds: 600));
    expect(tester.takeException(), isNull);
  });

  testWidgets('lesson exercise: pseudo-locale at 360px, no overflow',
      (tester) async {
    _narrowPseudo(tester);
    const lesson = Lesson(id: 'pseudo', title: 'Pseudo', exercises: [_c]);
    await tester
        .pumpWidget(const MaterialApp(home: LessonScreen(lesson: lesson)));
    await tester.pump(const Duration(milliseconds: 400));
    expect(tester.takeException(), isNull);
  });

  testWidgets('home full tour: pseudo-locale at 360px, scroll + tabs',
      (tester) async {
    _narrowPseudo(tester);
    var step = 'boot';
    final overflows = <String>[];
    final old = FlutterError.onError;
    FlutterError.onError = (d) {
      final s = d.toString();
      if (s.contains('overflowed')) {
        overflows.add('step=$step\n${s.split('\n').take(12).join('\n')}');
      } else {
        old?.call(d);
      }
    };
    addTearDown(() => FlutterError.onError = old);
    await tester.pumpWidget(const MaterialApp(home: HomeScreen()));
    await tester.pump(const Duration(milliseconds: 800));
    final scrollable = find.byType(Scrollable).first;
    for (var i = 0; i < 6; i++) {
      step = 'path drag $i';
      await tester.drag(scrollable, const Offset(0, -1600));
      await tester.pump(const Duration(milliseconds: 250));
    }
    FlutterError.onError = old; // restore BEFORE expect (binding invariant)
    expect(overflows, isEmpty, reason: overflows.join('\n--------\n'));
  });
}
