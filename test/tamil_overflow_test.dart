import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ratel/app_state.dart';
import 'package:ratel/models.dart';
import 'package:ratel/screens/auth_screen.dart';
import 'package:ratel/screens/home_screen.dart';
import 'package:ratel/screens/lesson_screen.dart';
import 'package:ratel/screens/onboarding_screen.dart';
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
  'chat_hint': 'உங்கள் பதிலை எழுதுங்கள்',
  'btn_quit': 'வெளியேறு',
  'btn_keep': 'தொடர்ந்து கற்கிறேன்',
  'btn_skip': 'தவிர்',
  'btn_check': 'சரிபார்',
  'correct_banner': 'சரிதான்!',
  'answer_prefix': 'பதில்:',
  'btn_finish': 'முடி',
  'btn_continue': 'தொடர்',
  'nav_learn': 'கற்றல்',
  'nav_practice': 'பயிற்சி',
  'nav_coach': 'கோச்',
  'nav_leagues': 'லீக்',
  'nav_profile': 'சுயவிவரம்',
  'start_pill': 'தொடங்கு',
  'stat_streak': 'தொடர் நாட்கள்',
  'stat_xp': 'மொத்த XP',
  'stat_lessons': 'முடித்த பாடங்கள்',
  'set_language': 'ஆப் மொழி',
  'set_listening': 'கேட்டல் பயிற்சிகள்',
  'ob_title': 'Ratel-க்கு வரவேற்கிறோம்!',
  'ob_sub': 'ஆங்கிலத்தில் பயம் வேண்டாம். இரண்டே கேள்விகள்.',
  'ob_why': 'எதற்காகக் கற்கிறீர்கள்?',
  'ob_goal': 'தினசரி இலக்கை அமைக்கவும்',
  'ob_setting_up': 'தயாராகிறது…',
  'ob_start': 'கற்கத் தொடங்கு',
  'ob_know': 'எனக்கு கொஞ்சம் ஆங்கிலம் தெரியும்',
  'ob_m_career': 'வேலை',
  'ob_m_travel': 'பயணம்',
  'ob_m_school': 'பள்ளி',
  'ob_m_family': 'குடும்பம்',
  'ob_m_brain_training': 'மூளைப் பயிற்சி',
  'ob_m_just_for_fun': 'பொழுதுபோக்கு',
  'ob_g_casual': 'இலகு',
  'ob_g_regular': 'வழக்கம்',
  'ob_g_serious': 'தீவிரம்',
  'ob_g_intense': 'அதிதீவிரம்',
  'xp_day': 'XP / நாள்',
  'auth_tagline': 'பயமின்றி ஆங்கிலம் கற்போம்.',
  'fld_name': 'பெயர்',
  'fld_email': 'மின்னஞ்சல்',
  'fld_password': 'கடவுச்சொல்',
  'btn_create': 'கணக்கு உருவாக்கு',
  'btn_login': 'உள்நுழை',
  'auth_have': 'கணக்கு உள்ளதா? உள்நுழையுங்கள்',
  'auth_new': 'புதியவரா? கணக்கு உருவாக்குங்கள்',
  'set_sound': 'ஒலி விளைவுகள்',
  'set_haptics': 'அதிர்வுகள்',
  'set_music': 'பின்னணி இசை',
  'set_music_sub': 'கற்கும்போது அமைதியான இசை',
  'btn_logout': 'வெளியேறு',
  'btn_delete': 'கணக்கை நீக்கு',
  'q_earn': '{n} XP சம்பாதி',
  'q_finish_one': '{n} பாடம் முடி',
  'q_finish_many': '{n} பாடங்கள் முடி',
  'dq_title': 'தினசரி பணிகள்',
  'dg_title': 'தினசரி இலக்கு',
  'review_due_one': '{n} பயிற்சி மறுபயிற்சிக்கு உள்ளது',
  'review_due_many': '{n} பயிற்சிகள் மறுபயிற்சிக்கு உள்ளன',
  'review_lockin': 'கற்றதை உறுதி செய்யுங்கள்.',
  'review_cta': 'மறுபயிற்சி',
  'mr_title': 'தவறுகளின் மறுபயிற்சி',
  'mr_cta': 'இவற்றைப் பயிற்சி செய்',
  'you_said': 'நீங்கள் சொன்னது:',
  'correct_lbl': 'சரியானது:',
  'coach_title': 'கோச்',
  'coach_typing': 'Ratel தட்டச்சு செய்கிறது…',
  'coach_roleplay': 'பாத்திரப் பயிற்சி',
  'lg_signin': 'லீக்கில் சேர உள்நுழையுங்கள்.',
  'lg_league': 'லீக்',
  'lg_week': 'இந்த வாரம் · முதல் 5 முன்னேறுவர்',
  'lg_promo': 'முன்னேற்ற மண்டலம் — இடத்தைத் தக்கவையுங்கள்!',
  'tc_title': 'நேர சவால்',
  'tc_best': 'சிறந்தது:',
  'tc_boost': '+15s உடன் தொடங்கு ·',
  'tc_gems': 'ரத்தினங்கள்',
  'tc_armed': '+15s பூஸ்ட் தயார்!',
  'tc_score': 'மதிப்பெண்',
  'sh_days': '-நாள் streak',
  'sh_line': 'XP · பயமின்றி ஆங்கிலம்',
  'sh_copied': 'அழைப்பு நகலெடுக்கப்பட்டது!',
  'sh_copy': 'அழைப்பை நகலெடு',
  'sv_title': 'முன்னேற்றத்தைச் சேமியுங்கள்',
  'sv_cta': 'என் முன்னேற்றத்தைச் சேமி',
  'sv_done': 'சேமிக்கப்பட்டது — வரவேற்கிறோம்!',
  'hs_practice': 'தவறுகளைப் பயிற்சி செய் — இதயம் பெறு',
  'hs_refill': 'இப்போதே நிரப்பு',
  'hs_pro': 'Ratel Pro — வரம்பற்ற இதயங்கள்',
  'ach_first_steps': 'முதல் அடி',
  'ach_warming_up': 'சூடுபிடிக்கிறது',
  'ach_scholar': 'அறிஞர்',
  'ach_completionist': 'முழுமையாளர்',
  'ach_on_a_roll': 'வேகத்தில்',
  'ach_unstoppable': 'தடுக்கமுடியாதவர்',
  'ach_centurion': 'சதவீரர்',
  'ach_xp_hunter': 'XP வேட்டைக்காரர்',
  'explain_fallback': 'சரியான பதில் "{answer}".',
  'new_achievement': 'புதிய சாதனை!',
  'mistakes_cleared': 'தவறுகள் சரியாகிவிட்டன!',
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
    await tester.tap(find.text('சரிபார்')); // Check, in Tamil
    await tester.pump(const Duration(milliseconds: 400));
    await tester.tap(find.text('முடி')); // Finish, in Tamil
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
    await tester.tap(find.text('சரிபார்')); // Check, in Tamil
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

  testWidgets('auth and onboarding read Tamil at 360px, no overflow',
      (tester) async {
    _narrowTamil(tester);
    await tester.pumpWidget(const MaterialApp(home: AuthScreen()));
    await tester.pump(const Duration(milliseconds: 600));
    expect(find.text('பயமின்றி ஆங்கிலம் கற்போம்.'), findsOneWidget);
    await tester.pumpWidget(
        const MaterialApp(home: OnboardingScreen()));
    await tester.pump(const Duration(milliseconds: 600));
    expect(find.text('எதற்காகக் கற்கிறீர்கள்?'), findsOneWidget);
    expect(find.text('மூளைப் பயிற்சி'), findsOneWidget);
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
    for (final tab in ['பயிற்சி', 'கோச்', 'சுயவிவரம்']) {
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
    FlutterError.onError = old; // restore BEFORE expect (binding rule)
    expect(overflows, isEmpty,
        reason: overflows.join('\n────────\n'));
  });
}
