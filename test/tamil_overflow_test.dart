import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ratel/app_state.dart';
import 'package:ratel/models.dart';
import 'package:ratel/screens/home_screen.dart';
import 'package:ratel/screens/lesson_screen.dart';
import 'package:ratel/strings.dart';
import 'package:ratel/widgets/daily_chest.dart';
import 'package:ratel/widgets/monthly_quest.dart';
import 'package:ratel/widgets/motd_card.dart';
import 'package:shared_preferences/shared_preferences.dart';

// The LIVE app_strings.ta values (owner style pass, 2026-06-12). Tamil
// runs longer than English — every S()-consuming surface must survive a
// narrow phone. RenderFlex overflow fails these tests automatically.
const Map<String, String> _ta = {
  'lesson_complete': 'பாடம் முடிந்தது!',
  'review_complete': 'மறுபயிற்சி முடிந்தது!',
  'unit_complete': 'யூனிட் முடிந்தது!',
  'fix_phase_toast': 'தவறுகளைச் சரி செய்வோம் — இதயங்கள் பறிபோகாது!',
  'quit_title': 'இருங்கள், போகாதீர்கள்!',
  'quit_body': 'இப்போது வெளியேறினால் இந்தப் பாடத்தின் முன்னேற்றம் போய்விடும்.',
  'report_thanks': 'நன்றி! தேன் கரடி பார்த்துக்கொள்ளும்.',
  'daily_chest_cta': 'தினசரி பெட்டி — திறக்க தட்டவும்!',
  'monthly_quest_title': '{month} சவால்: {goal} XP சம்பாதியுங்கள்',
  'perfect_week_title': 'முழுமையான வாரம்! 7 நாட்களும் இலக்கை அடைந்தீர்கள்.',
  'hearts_full': 'இதயங்கள் நிரம்பின — போய் வெல்லுங்கள்!',
  'hearts_next': 'அடுத்த இதயம் இன்னும் {t}',
  'gems_short': 'இன்னும் போதிய ரத்தினங்கள் இல்லை — கற்றுக்கொண்டே இருங்கள்!',
  'freeze_drip': 'இலவச streak freeze கிடைத்துள்ளது — பயமின்றி தொடருங்கள்!',
  'guest_cta': 'முதலில் முயற்சித்துப் பார்க்கிறேன்',
  'smart_practice_title': 'ஸ்மார்ட் பயிற்சி',
  'motd_fallback': 'வணக்கம்! இன்று ஒரு பாடம் முடிப்போமா?',
};

const Exercise _c = Exercise.choice(
    prompt: 'Pick the greeting', options: ['Hello', 'Car', 'Run'],
    correctIndex: 0);

void _narrowTamil(WidgetTester tester) {
  tester.view.physicalSize = const Size(360, 690);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);
  for (final e in _ta.entries) {
    S.instance.debugSet(e.key, ta: e.value);
  }
  S.instance.locale = 'ta';
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    appState.reset();
    appState.hearts = 5;
  });
  tearDown(() {
    S.instance.locale = 'en';
    S.instance.debugClear();
  });

  testWidgets('lesson completion reads Tamil at 360px, no overflow',
      (tester) async {
    _narrowTamil(tester);
    const lesson = Lesson(id: 'tta', title: 'Tamil', exercises: [_c]);
    await tester.pumpWidget(
        const MaterialApp(home: LessonScreen(lesson: lesson)));
    await tester.pump(const Duration(milliseconds: 400));
    await tester.tap(find.text('Hello'));
    await tester.pump(const Duration(milliseconds: 150));
    await tester.tap(find.text('Check'));
    await tester.pump(const Duration(milliseconds: 400));
    await tester.tap(find.text('Finish'));
    await tester.pump(const Duration(milliseconds: 700));
    expect(find.text('பாடம் முடிந்தது!'), findsOneWidget);
  });

  testWidgets('quit dialog reads Tamil at 360px, no overflow',
      (tester) async {
    _narrowTamil(tester);
    const lesson = Lesson(id: 'ttq', title: 'Tamil', exercises: [_c]);
    await tester.pumpWidget(
        const MaterialApp(home: LessonScreen(lesson: lesson)));
    await tester.pump(const Duration(milliseconds: 400));
    await tester.tap(find.text('Hello'));
    await tester.pump(const Duration(milliseconds: 150));
    await tester.tap(find.text('Check'));
    await tester.pump(const Duration(milliseconds: 400));
    await tester.tap(find.byIcon(Icons.close));
    await tester.pump(const Duration(milliseconds: 350));
    expect(find.text('இருங்கள், போகாதீர்கள்!'), findsOneWidget);
    expect(
        find.textContaining('இந்தப் பாடத்தின்'), findsOneWidget);
  });

  testWidgets('home cards read Tamil at 360px, no overflow',
      (tester) async {
    _narrowTamil(tester);
    await tester.pumpWidget(MaterialApp(
        home: Scaffold(
            body: ListView(children: [
      const MotdCard(),
      const DailyChestCard(),
      MonthlyQuestCard(),
    ]))));
    await tester.pump(const Duration(milliseconds: 600));
    // motd needs an admin flag; the chest CTA is the live ta probe
    expect(find.text('தினசரி பெட்டி — திறக்க தட்டவும்!'),
        findsOneWidget);
  });

  testWidgets('full home tour in Tamil at 360px: scroll + every tab',
      (tester) async {
    _narrowTamil(tester);
    // capture overflow details AT THROW TIME (creator file:line),
    // tagged with the tour step — defunct-tree dumps name nothing
    var step = 'boot';
    final List<String> overflows = [];
    final old = FlutterError.onError;
    FlutterError.onError = (d) {
      final s = d.toString();
      if (s.contains('overflowed')) {
        overflows.add(
            'step=$step\n${s.split('\n').take(16).join('\n')}');
      } else {
        old?.call(d);
      }
    };
    addTearDown(() => FlutterError.onError = old);
    await tester.pumpWidget(const MaterialApp(home: HomeScreen()));
    await tester.pump(const Duration(milliseconds: 800));
    // full path scroll, top to bottom
    final scrollable = find.byType(Scrollable).first;
    for (var i = 0; i < 6; i++) {
      step = 'path drag \$i';
      await tester.drag(scrollable, const Offset(0, -1600));
      await tester.pump(const Duration(milliseconds: 250));
    }
    // every bottom tab renders
    for (final tab in ['Practice', 'Coach', 'Profile']) {
      step = 'tab \$tab';
      await tester.tap(find.text(tab).last);
      await tester.pump(const Duration(milliseconds: 700));
    }
    // profile is scrollable too (badges, score card, settings)
    final pScroll = find.byType(Scrollable);
    if (pScroll.evaluate().isNotEmpty) {
      for (var i = 0; i < 4; i++) {
        step = 'profile drag \$i';
        await tester.drag(pScroll.first, const Offset(0, -1400));
        await tester.pump(const Duration(milliseconds: 250));
      }
    }
    expect(overflows, isEmpty,
        reason: overflows.join('\n────────\n'));
  });
}
