import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ratel/app_state.dart';
import 'package:ratel/models.dart';
import 'package:ratel/screens/auth_screen.dart';
import 'package:ratel/screens/home_screen.dart';
import 'package:ratel/screens/lesson_screen.dart';
import 'package:ratel/screens/onboarding_screen.dart';
import 'package:ratel/screens/section_test_screen.dart';
import 'package:ratel/screens/friends_screen.dart';
import 'package:ratel/screens/placement_screen.dart';
import 'package:ratel/screens/paywall_screen.dart';
import 'package:ratel/milestones.dart';
import 'package:ratel/widgets/friends_feed.dart';
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
  'explain_btn': 'விளக்கு',
  // Inc 130 mop-up batch drafts (owner spot-check pending, live-editable)
  'bub_correct': 'அருமை — பயமில்லை!',
  'bub_wrong': 'பயம் வேண்டாம் — இப்படித்தான் கற்கிறோம்.',
  'gb_title': 'வழிகாட்டி · {sub}',
  'gb_sub': 'இந்த யூனிட்டின் முக்கியச் சொற்றொடர்கள்',
  'node_done_body':
      'இதை அருமையாக முடித்தீர்கள். ஒரு சிறு பயிற்சி நினைவில் வைத்திருக்க உதவும்!',
  'node_locked_body': 'திறக்க, மேலே உள்ள பாதையை முடியுங்கள்!',
  'btn_close': 'மூடு',
  'node_practice': 'மீண்டும் பயிற்சி',
  'chest_title': 'ஒரு பரிசுப் பெட்டி!',
  'chest_locked': 'திறக்க, மேலே உள்ள மூன்று பாடங்களை முடியுங்கள்.',
  'btn_ok': 'சரி',
  'chest_found_title': '20 XP மற்றும் 5 ரத்தினங்கள் கிடைத்தன!',
  'chest_found_body': 'தேன் கரடி பாராட்டுகிறது. தொடருங்கள்!',
  'btn_claim': 'பெற்றுக்கொள்',
  'streak_days_title': '{n} நாள் தொடர்',
  'freezes_count': 'Freezes: {n}/2',
  'freeze_get': 'ஒன்று வாங்க · {n} ரத்தினங்கள்',
  'freeze_added': 'Streak freeze சேர்க்கப்பட்டது!',
  'streak_tip': 'தொடர் முறியாமல் இருக்க, தினமும் பயிற்சி செய்யுங்கள்!',
  'feed_title': 'நண்பர்களின் செயல்பாடு',
  'feed_cheer': 'உங்களை உற்சாகப்படுத்தினார்!',
  'feed_chest': 'ஒரு பெட்டியைத் திறந்தார் (+{n} XP)',
  'feed_xp': '{n} XP சம்பாதித்தார்',
  'cheer_tip': 'உற்சாகப்படுத்து',
  'feed_badger': 'தேன் கரடி',
  'feed_friend': 'ஒரு நண்பர்',
  'st_title': 'தேர்வு · {t}',
  'st_progress': '{b}-இல் {a}',
  'btn_next': 'அடுத்து',
  'st_see_result': 'முடிவைப் பார்',
  'st_pass': 'முன்னே தாவிவிட்டீர்கள்!',
  'st_fail': 'இன்னும் இல்லை — தொடருங்கள்!',
  'st_pass_body':
      '{t} திறக்கப்பட்டது. முந்தைய பாடங்கள் பயிற்சிக்காகத் திறந்தே இருக்கும்.',
  'st_fail_body':
      '{b}-இல் {a} சரி. இன்னும் கொஞ்சம் பயிற்சியில் இந்தப் பகுதி உங்களுடையதே.',
  'test_out': 'தேர்வு எழுது',
  'friend_added': 'உங்கள் அழைப்பு இணைப்பால் நண்பர் சேர்க்கப்பட்டார் ({code})!',
  'delete_failed': 'இப்போது நீக்க முடியவில்லை — மீண்டும் முயற்சிக்கவும்.',
  'repair_failed': 'இப்போது சரிசெய்ய முடியவில்லை',
  'restore_soon': 'ஸ்டோர் பதிப்புடன் மீட்டமைப்பு வரும்.',
  // Inc 132 batch-4 drafts (final long tail; owner spot-check, live-editable)
  'coming_soon': 'விரைவில் வருகிறது',
  'tc_card_title': 'நேர சவால்',
  'tc_card_sub': 'நேரத்தை வெல்லுங்கள் — இதயங்கள் பறிபோகாது',
  'btn_go': 'செல்',
  'rv_title': 'பாடங்களை மீண்டும் பார்',
  'rv_sub': 'எந்தப் பாடத்தையும் மீண்டும் பயின்று கூர்மையாகுங்கள்.',
  'n_lessons': '{a}/{b} பாடங்கள்',
  'n_exercises': '{n} பயிற்சிகள்',
  'guest_banner': 'விருந்தினர் — முன்னேற்றத்தைச் சேமியுங்கள்',
  'n_freezes': ' {n} freezes',
  'best_streak': ' சிறந்தது {n}-நாள் streak',
  'set_lang_sub': 'சர்வர் வாசகம் உங்கள் தேர்வைப் பின்பற்றும்',
  'set_listen_sub': 'கேட்டு எழுதும் கேள்விகள்',
  'set_motion': 'அசைவுகளைக் குறை',
  'set_motion_sub': 'அனிமேஷன்களைக் குறைக்கும்',
  'set_battle': 'சண்டை முறை',
  'set_battle_sub': 'பதிலளிக்கும்போது எதிரியுடன் மோதுங்கள்',
  'set_auto': 'ஆட்டோ',
  'set_light': 'வெளிச்சம்',
  'set_dark': 'இருட்டு',
  // Inc 136+137 keys (QA #2 ta-leak batch)
  'streak_title': 'Streak',
  'coach_sub': 'Ratel-உடன் உண்மையான உரையாடல் பயிற்சி',
  'coach_left': 'இன்று இன்னும் {n} மெசேஜ்கள்',
  'coach_hint': 'English-இல் தட்டச்சு செய்யவும்...',
  'chip_day': 'என் இன்றைய நாள்',
  'chip_food': 'எனக்குப் பிடித்த உணவு',
  'chip_family': 'என் குடும்பம்',
  'chip_place': 'எனக்குப் பிடித்த இடம்',
  'scn_cafe': 'கஃபேயில் ஆர்டர் செய்யுங்கள்',
  'scn_interview': 'வேலை நேர்காணல்',
  'scn_friend': 'புதிய நண்பரைச் சந்தியுங்கள்',
  'scn_doctor': 'மருத்துவரிடம்',
  'nudge_risk': 'இன்று ஒரு பாடம் முடித்து உங்கள் {n}-நாள் streak-ஐக் காப்பாற்றுங்கள்.',
  'nudge_goal': 'இன்றைய இலக்கை அடைய இன்னும் {n} XP.',
  'resets_dh': 'ரீசெட்: {d}நா {h}ம',
  'resets_hm': 'ரீசெட்: {h}ம {m}நி',
  'resets_m': 'ரீசெட்: {m}நி',
  'goal_reached': 'இலக்கு எட்டியது — அருமை!',
  'earn_more': 'இன்று இன்னும் {n} XP சம்பாதியுங்கள்',
  'month_practice': '{m} பயிற்சி',
  'cefr_a1': 'உங்களை அறிமுகம் செய்யவும் அன்றாட சொற்றொடர்களைக் கையாளவும் முடியும்.',
  'cefr_a2': 'அன்றாட வேலைகளையும் எளிய உரையாடல்களையும் சமாளிக்க முடியும்.',
  'cefr_b1': 'பழகிய தலைப்புகளில் பேசவும் பயண English-ஐக் கையாளவும் முடியும்.',
  'cefr_b2': 'தன்னம்பிக்கையுடன் இயல்பான உரையாடல் நடத்த முடியும்.',
  'unit_n': 'யூனிட் {n}',
  'badge_monthly_quester': 'மாதச் சாதனையாளர்',
  'badge_quest_devotee': 'சவால் ஆர்வலர்',
  'badge_perfect_week': 'முழுமையான வாரம்',
  'badge_week_after_week': 'வாரந்தோறும் வெற்றி',
  'badge_quick_thinker': 'விரைவு சிந்தனையாளர்',
  'badge_lightning_badger': 'மின்னல் தேன் கரடி',
  'set_remind': 'நினைவூட்டும் நேரம்',
  'set_remind_sub': 'தினசரி streak நினைவூட்டல், உங்கள் உள்ளூர் நேரம்',
  'set_push': 'தினசரி streak நினைவூட்டல்கள்',
  'push_off_hint': 'அணைந்துள்ளது — சிஸ்டம் அமைப்புகளில் இயக்கவும்',
  'btn_enable': 'இயக்கு',
  'fr_title': 'நண்பர்கள்',
  'share_invite': 'பகிர் / நண்பர்களை அழை',
  'set_privacy': 'தனியுரிமைக் கொள்கை',
  'set_terms': 'விதிமுறைகள்',
  'del_title': 'கணக்கை நீக்கவா?',
  'del_body':
      'இது உங்கள் கணக்கையும் எல்லா முன்னேற்றத்தையும் (XP, streak, நண்பர்கள், வரலாறு) நிரந்தரமாக நீக்கும். இதை மீட்க முடியாது.',
  'del_keep': 'கணக்கை வைத்திரு',
  'del_confirm': 'நிரந்தரமாக நீக்கு',
  'hearts_title': 'இதயங்கள்',
  'refill_label': 'இதயங்களை நிரப்பு · {n} ரத்தினங்கள்',
  'hp_practice': 'பயிற்சி செய் — இதயம் பெறு',
  'es_title': 'ஆங்கில மதிப்பெண்',
  'es_gap': '{band}-க்கு இன்னும் {n}',
  'es_sub': 'பாடங்கள் முடித்து streak காத்தால் வளரும்.',
  'unit_label': 'யூனிட் {n} · {sub}',
  'section_label': 'பிரிவு {n}',
  'n_units': '{a}/{b} யூனிட்கள்',
  'fix_chip': 'தவறுகளைச் சரிசெய்கிறோம்',
  'explain_wait': 'Ratel யோசிக்கிறது…',
  'btn_play': 'கேள்',
  'btn_slower': 'மெதுவாக',
  'pick_reply': 'சிறந்த பதிலைத் தேர்ந்தெடுங்கள்',
  'report_btn': 'இந்தப் பயிற்சியைப் புகாரளி',
  'save_banner': 'முன்னேற்றத்தைச் சேமியுங்கள் — இலவசக் கணக்கு',
  'n_correct': '{b}-இல் {a} சரி',
  'xp_and_correct': '+{x} XP   ·   {b}-இல் {a} சரி',
  'bonus_xp': '🎁 அதிரடி போனஸ் +{n} XP!',
  'repair_done': 'Streak மீட்கப்பட்டது — பயமில்லை.',
  'btn_keep_going': 'தொடருங்கள்',
  'repair_offer': 'மீண்டும் வரவேற்கிறோம்! {n}-நாள் streak-ஐ சரிசெய்யவா?',
  'repair_uses': 'ஒரு streak freeze செலவாகும்.',
  'rate_ask': 'Ratel பிடித்திருக்கிறதா?',
  'rate_no': 'இன்னும் இல்லை',
  'rate_yes': 'மிகவும் பிடிக்கிறது!',
  'ms_days': '{n}-நாள் streak!',
  'ms_body': 'பயமில்லை. தீயைத் தொடர விடுங்கள்.',
  'wa_title': 'உங்கள் துல்லியம்',
  'wa_over': '{n} பதில்களில்',
  'wa_work': 'இவற்றில் கவனம்:',
  'wa_missed': '{a}% · {n} தவறு',
  'pl_title': 'நிலை சோதனை',
  'pl_sub': 'முடிந்ததைச் செய்யுங்கள் — அழுத்தம் இல்லை.',
  'pw_trial': 'உங்கள் Pro டிரையல் இயங்குகிறது. Ratel-ஐ ஆதரித்ததற்கு நன்றி!',
  'pw_starting': 'தொடங்குகிறது…',
  'pw_start': '7-நாள் இலவச டிரையலைத் தொடங்கு',
  'pw_test_note':
      'சோதனை முறை — இப்போது பணம் எடுக்கப்படாது. உண்மையான கட்டணம் ஸ்டோர் பதிப்புடன் வரும்.',
  'pw_restore': 'வாங்கியவற்றை மீட்டெடு',
  'pw_best': 'சிறந்தது',
  'fr_code': 'உங்கள் நண்பர் குறியீடு',
  'fr_list': 'உங்கள் நண்பர்கள்',
  'sp_sub': 'உங்களுக்காக {n} தேர்வு — மறுபயிற்சி, தவறுகள், பலவீனங்கள்',
  'btn_start': 'தொடங்கு',
  'sh_code': 'ratel · நண்பர் குறியீடு {code}',
  'bg_title': 'மாத பேட்ஜ்கள்',
  'ach_title': 'சாதனைகள் ({a}/{b})',
  'ob_speak': 'எனக்கு ஆங்கிலம் பேசத் தெரியும்',
  // Inc 133 gems popover drafts
  'gems_title': 'ரத்தினங்கள்',
  'gems_earn_hint':
      'காம்போக்கள், தவறில்லாத பாடங்கள், பெட்டிகள் — இவற்றால் ரத்தினங்கள் கிடைக்கும்.',
  'gem_buy_freeze': 'Streak freeze · {n} ரத்தினங்கள்',
  'hearts_pro': 'Ratel Pro-வுடன் வரம்பற்ற இதயங்கள்',
  // Inc 134 comeback boost
  'comeback_granted':
      'மீண்டும் வரவேற்கிறோம்! அடுத்த {n} நிமிடங்களுக்கு {m}x XP!',
  'code_copied': 'குறியீடு நகலெடுக்கப்பட்டது',
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

  testWidgets('theme segment stays single-line Tamil at 360px (no mid-word wrap)',
      (tester) async {
    _narrowTamil(tester);
    await tester.pumpWidget(const MaterialApp(home: HomeScreen()));
    await tester.pump(const Duration(milliseconds: 800));
    await tester.tap(find.byIcon(Icons.person_outline));
    await tester.pump(const Duration(milliseconds: 700));
    // settings sit deep in the profile scroll (lazy build — scroll first)
    await tester.scrollUntilVisible(find.text('வெளிச்சம்'), 400,
        scrollable: find.byType(Scrollable).first);
    await tester.pump(const Duration(milliseconds: 300));
    for (final label in ['ஆட்டோ', 'வெளிச்சம்', 'இருட்டு']) {
      final p = tester.renderObject<RenderParagraph>(find.text(label));
      expect(p.size.height, lessThan(26),
          reason: '$label wrapped to >1 line in the theme segment');
    }
  });

  testWidgets('friends feed rows read Tamil at 360px, no overflow',
      (tester) async {
    _narrowTamil(tester);
    final now = DateTime.now();
    final items = [
      FeedItem(
          name: 'வெற்றிவேல்',
          amount: 120,
          reason: 'xp',
          at: now,
          friendId: 'f1'),
      FeedItem(
          name: 'அன்புச்செல்வி',
          amount: 20,
          reason: 'chest',
          at: now.subtract(const Duration(hours: 3)),
          friendId: 'f2'),
      FeedItem(
          name: 'தோழி',
          amount: 0,
          reason: 'cheer',
          at: now.subtract(const Duration(hours: 5))),
    ];
    await tester.pumpWidget(MaterialApp(
        home: Scaffold(
            body: ListView(children: [FriendsFeed(items: items)]))));
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.text('நண்பர்களின் செயல்பாடு'), findsOneWidget);
    expect(find.textContaining('சம்பாதித்தார்'), findsOneWidget);
    expect(find.textContaining('உற்சாகப்படுத்தினார்'), findsOneWidget);
  });

  testWidgets('section test reads Tamil at 360px, no overflow',
      (tester) async {
    _narrowTamil(tester);
    await tester.pumpWidget(
        MaterialApp(home: SectionTestScreen(section: kSections[1])));
    await tester.pump(const Duration(milliseconds: 400));
    // appbar title renders through st_title (Tamil), progress through
    // st_progress; any overflow at 360px fails the test automatically
    expect(find.textContaining('தேர்வு'), findsWidgets);
  });

  testWidgets('friends screen reads Tamil at 360px, no overflow',
      (tester) async {
    _narrowTamil(tester);
    await tester.pumpWidget(const MaterialApp(home: FriendsScreen()));
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.text('உங்கள் நண்பர் குறியீடு'), findsOneWidget);
    expect(find.text('உங்கள் நண்பர்கள்'), findsOneWidget);
  });

  testWidgets('placement screen reads Tamil at 360px, no overflow',
      (tester) async {
    _narrowTamil(tester);
    await tester.pumpWidget(
        const MaterialApp(home: PlacementScreen(goal: 20)));
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.text('நிலை சோதனை'), findsOneWidget);
    expect(find.text('சரிபார்'), findsOneWidget); // btn_check reused here
  });

  testWidgets('paywall reads Tamil at 360px, no overflow',
      (tester) async {
    _narrowTamil(tester);
    await tester.pumpWidget(const MaterialApp(home: PaywallScreen()));
    await tester.pump(const Duration(milliseconds: 500));
    // the body is a lazy ListView — build the lower items before asserting
    for (var i = 0; i < 3; i++) {
      await tester.drag(find.byType(Scrollable).first, const Offset(0, -900));
      await tester.pump(const Duration(milliseconds: 200));
    }
    expect(
        find.text('7-நாள் இலவச டிரையலைத் தொடங்கு'), findsOneWidget);
    expect(find.textContaining('சோதனை முறை'), findsOneWidget);
  });

  testWidgets('gems popover opens from the header and reads Tamil at 360px',
      (tester) async {
    _narrowTamil(tester);
    appState.streakFreezes = 0; // reset() leaves 2 -> shortcut hidden
    appState.hearts = 2; // < 5 -> refill shortcut shows too
    await tester.pumpWidget(const MaterialApp(home: HomeScreen()));
    await tester.pump(const Duration(milliseconds: 800));
    await tester.tap(find.byKey(const Key('gems_stat')));
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.text('ரத்தினங்கள்'), findsOneWidget); // gems_title
    // both spend shortcuts present in the spendable state
    expect(find.textContaining('Streak freeze ·'), findsOneWidget);
    expect(find.textContaining('நிரப்பு'), findsOneWidget); // refill_label
    expect(find.textContaining('கிடைக்கும்'), findsOneWidget); // earn hint
  });
}
