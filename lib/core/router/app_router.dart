import 'package:go_router/go_router.dart';
import '../../features/dev/screens/screen_index_screen.dart';
import '../../features/auth/screens/age_check_screen.dart';
import '../../features/auth/screens/auth_hub_screen.dart';
import '../../features/auth/screens/delete_account_screen.dart';
import '../../features/auth/screens/email_verify_screen.dart';
import '../../features/auth/screens/forgot_password_screen.dart';
import '../../features/auth/screens/guest_save_screen.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/auth/screens/logout_screen.dart';
import '../../features/auth/screens/otp_screen.dart';
import '../../features/auth/screens/parental_consent_screen.dart';
import '../../features/auth/screens/phone_verify_screen.dart';
import '../../features/auth/screens/privacy_choices_screen.dart';
import '../../features/auth/screens/reset_sent_screen.dart';
import '../../features/auth/screens/returning_unlock_screen.dart';
import '../../features/auth/screens/set_new_password_screen.dart';
import '../../features/auth/screens/signup_screen.dart';
import '../../features/auth/screens/social_consent_screen.dart';
import '../../features/auth/screens/splash_screen.dart';
import '../../features/auth/screens/welcome_screen.dart';
import '../../features/onboarding/screens/daily_goal_screen.dart';
import '../../features/onboarding/screens/first_win_screen.dart';
import '../../features/onboarding/screens/level_result_screen.dart';
import '../../features/onboarding/screens/language_picker_screen.dart';
import '../../features/onboarding/screens/motivation_screen.dart';
import '../../features/onboarding/screens/placement_test_screen.dart';
import '../../features/onboarding/screens/notification_optin_screen.dart';
import '../../features/onboarding/screens/referral_source_screen.dart';
import '../../features/onboarding/screens/start_point_screen.dart';
import '../../features/learn/screens/lesson_choice_screen.dart';
import '../../features/learn/screens/lesson_listen_screen.dart';
import '../../features/learn/screens/lesson_speaking_screen.dart';
import '../../features/learn/screens/home_screen.dart';
import '../../features/shell/screens/main_shell.dart';
import '../../features/learn/screens/why_card_screen.dart';
import '../../features/learn/screens/wrong_feedback_screen.dart';
import '../../features/learn/screens/ai_roleplay_screen.dart';
import '../../features/learn/screens/lesson_complete_screen.dart';
import '../../features/learn/screens/out_of_energy_screen.dart';
import '../../features/learn/screens/course_switcher_screen.dart';
import '../../features/learn/screens/stories_screen.dart';
import '../../features/learn/screens/streak_hub_screen.dart';
import '../../features/practice/screens/practice_hub_screen.dart';
import '../../features/practice/screens/smart_practice_screen.dart';
import '../../features/practice/screens/timed_challenge_screen.dart';
import '../../features/practice/screens/coach_chat_screen.dart';
import '../../features/practice/screens/speaking_practice_screen.dart';
import '../../features/practice/screens/voice_call_screen.dart';
import '../../features/practice/screens/adventures_roleplay_screen.dart';
import '../../features/practice/screens/market_story_screen.dart';
import '../../features/practice/screens/pronunciation_results_screen.dart';
import '../../features/practice/screens/ai_credits_screen.dart';
import '../../features/practice/screens/dictation_screen.dart';
import '../../features/practice/screens/video_lesson_screen.dart';
import '../../features/practice/screens/writing_feedback_screen.dart';
import '../../features/social/screens/daily_quests_screen.dart';
import '../../features/social/screens/streak_screen.dart';
import '../../features/social/screens/streak_society_screen.dart';
import '../../features/social/screens/achievement_detail_screen.dart';
import '../../features/social/screens/achievements_screen.dart';
import '../../features/social/screens/gem_shop_screen.dart';
import '../../features/social/screens/diamond_tournament_screen.dart';
import '../../features/social/screens/goal_ring_screen.dart';
import '../../features/social/screens/leagues_screen.dart';
import '../../features/social/screens/classroom_screen.dart';
import '../../features/social/screens/family_plan_screen.dart';
import '../../features/social/screens/friend_profile_screen.dart';
import '../../features/social/screens/friends_feed_screen.dart';
import '../../features/profile/screens/avatar_builder_screen.dart';
import '../../features/profile/screens/english_score_screen.dart';
import '../../features/profile/screens/profile_screen.dart';
import '../../features/profile/screens/accessibility_screen.dart';
import '../../features/profile/screens/appearance_screen.dart';
import '../../features/profile/screens/settings_hub_screen.dart';
import '../../features/profile/screens/help_legal_screen.dart';
import '../../features/profile/screens/notifications_screen.dart';
import '../../features/profile/screens/privacy_data_screen.dart';
import '../../features/profile/screens/checkout_success_screen.dart';
import '../../features/profile/screens/manage_subscription_screen.dart';
import '../../features/profile/screens/paywall_screen.dart';
import '../../features/profile/screens/cancel_winback_screen.dart';
import '../../features/profile/screens/promo_redeem_screen.dart';
import '../../features/profile/screens/referral_hub_screen.dart';

/// App routing (charter: go_router). Routes grow as screens land Login→Logout.
/// The route table — exposed as a top-level list so flow/navigation tests
/// can mount `GoRouter(initialLocation: <start>, routes: appRoutes)` directly.
final List<RouteBase> appRoutes = <RouteBase>[
  GoRoute(path: '/index', builder: (_, _) => const ScreenIndexScreen()),
  GoRoute(path: '/splash', builder: (_, _) => const SplashScreen()),
  GoRoute(path: '/welcome', builder: (_, _) => const WelcomeScreen()),
  GoRoute(path: '/login', builder: (_, _) => const LoginScreen()),
  GoRoute(path: '/auth', builder: (_, _) => const AuthHubScreen()),
  GoRoute(path: '/signup', builder: (_, _) => const SignupScreen()),
  GoRoute(path: '/unlock', builder: (_, _) => const ReturningUnlockScreen()),
  GoRoute(
    path: '/social-consent',
    builder: (_, _) => const SocialConsentScreen(),
  ),
  GoRoute(path: '/privacy', builder: (_, _) => const PrivacyChoicesScreen()),
  GoRoute(path: '/age', builder: (_, _) => const AgeCheckScreen()),
  GoRoute(
    path: '/parental',
    builder: (_, _) => const ParentalConsentScreen(),
  ),
  GoRoute(path: '/phone', builder: (_, _) => const PhoneVerifyScreen()),
  GoRoute(path: '/otp', builder: (_, _) => const OtpScreen()),
  GoRoute(path: '/forgot', builder: (_, _) => const ForgotPasswordScreen()),
  GoRoute(path: '/reset-sent', builder: (_, _) => const ResetSentScreen()),
  GoRoute(
    path: '/set-password',
    builder: (_, _) => const SetNewPasswordScreen(),
  ),
  GoRoute(
    path: '/email-verify',
    builder: (_, _) => const EmailVerifyScreen(),
  ),
  GoRoute(path: '/guest-save', builder: (_, _) => const GuestSaveScreen()),
  GoRoute(path: '/logout', builder: (_, _) => const LogoutScreen()),
  GoRoute(path: '/delete', builder: (_, _) => const DeleteAccountScreen()),
  GoRoute(
    path: '/onboarding/language',
    builder: (_, _) => const LanguagePickerScreen(),
  ),
  GoRoute(
    path: '/onboarding/motivation',
    builder: (_, _) => const MotivationScreen(),
  ),
  GoRoute(
    path: '/onboarding/goal',
    builder: (_, _) => const DailyGoalScreen(),
  ),
  GoRoute(
    path: '/onboarding/referral',
    builder: (_, _) => const ReferralSourceScreen(),
  ),
  GoRoute(
    path: '/onboarding/notify',
    builder: (_, _) => const NotificationOptinScreen(),
  ),
  GoRoute(
    path: '/onboarding/start',
    builder: (_, _) => const StartPointScreen(),
  ),
  GoRoute(
    path: '/onboarding/placement',
    builder: (_, _) => const PlacementTestScreen(),
  ),
  GoRoute(
    path: '/onboarding/level',
    builder: (_, _) => const LevelResultScreen(),
  ),
  GoRoute(
    path: '/onboarding/first-win',
    builder: (_, _) => const FirstWinScreen(),
  ),
  GoRoute(
    path: '/lesson/choice',
    builder: (_, _) => const LessonChoiceScreen(),
  ),
  GoRoute(
    path: '/lesson/speaking',
    builder: (_, _) => const LessonSpeakingScreen(),
  ),
  GoRoute(
    path: '/lesson/listen',
    builder: (_, _) => const LessonListenScreen(),
  ),
  GoRoute(path: '/home', builder: (_, _) => const HomeScreen()),
  GoRoute(path: '/app', builder: (_, _) => const MainShell()),
  GoRoute(path: '/why', builder: (_, _) => const WhyCardScreen()),
  GoRoute(path: '/wrong', builder: (_, _) => const WrongFeedbackScreen()),
  GoRoute(path: '/roleplay', builder: (_, _) => const AiRoleplayScreen()),
  GoRoute(path: '/complete', builder: (_, _) => const LessonCompleteScreen()),
  GoRoute(path: '/energy', builder: (_, _) => const OutOfEnergyScreen()),
  GoRoute(path: '/stories', builder: (_, _) => const StoriesScreen()),
  GoRoute(path: '/streak', builder: (_, _) => const StreakHubScreen()),
  GoRoute(path: '/courses', builder: (_, _) => const CourseSwitcherScreen()),
  GoRoute(path: '/practice', builder: (_, _) => const PracticeHubScreen()),
  GoRoute(
    path: '/practice/smart',
    builder: (_, _) => const SmartPracticeScreen(),
  ),
  GoRoute(
    path: '/practice/timed',
    builder: (_, _) => const TimedChallengeScreen(),
  ),
  GoRoute(path: '/coach', builder: (_, _) => const CoachChatScreen()),
  GoRoute(path: '/call', builder: (_, _) => const VoiceCallScreen()),
  GoRoute(
    path: '/practice/speaking',
    builder: (_, _) => const SpeakingPracticeScreen(),
  ),
  GoRoute(
    path: '/pronunciation',
    builder: (_, _) => const PronunciationResultsScreen(),
  ),
  GoRoute(
    path: '/practice/story',
    builder: (_, _) => const MarketStoryScreen(),
  ),
  GoRoute(
    path: '/adventures',
    builder: (_, _) => const AdventuresRoleplayScreen(),
  ),
  GoRoute(path: '/video', builder: (_, _) => const VideoLessonScreen()),
  GoRoute(path: '/dictation', builder: (_, _) => const DictationScreen()),
  GoRoute(path: '/writing', builder: (_, _) => const WritingFeedbackScreen()),
  GoRoute(path: '/credits', builder: (_, _) => const AiCreditsScreen()),
  GoRoute(path: '/streak-detail', builder: (_, _) => const StreakScreen()),
  GoRoute(path: '/society', builder: (_, _) => const StreakSocietyScreen()),
  GoRoute(path: '/quests', builder: (_, _) => const DailyQuestsScreen()),
  GoRoute(
    path: '/achievements',
    builder: (_, _) => const AchievementsScreen(),
  ),
  GoRoute(
    path: '/achievement',
    builder: (_, _) => const AchievementDetailScreen(),
  ),
  GoRoute(path: '/shop', builder: (_, _) => const GemShopScreen()),
  GoRoute(path: '/goal-ring', builder: (_, _) => const GoalRingScreen()),
  GoRoute(path: '/leagues', builder: (_, _) => const LeaguesScreen()),
  GoRoute(
    path: '/tournament',
    builder: (_, _) => const DiamondTournamentScreen(),
  ),
  GoRoute(path: '/friends', builder: (_, _) => const FriendsFeedScreen()),
  GoRoute(path: '/friend', builder: (_, _) => const FriendProfileScreen()),
  GoRoute(path: '/family', builder: (_, _) => const FamilyPlanScreen()),
  GoRoute(path: '/classroom', builder: (_, _) => const ClassroomScreen()),
  GoRoute(path: '/profile', builder: (_, _) => const ProfileScreen()),
  GoRoute(
    path: '/english-score',
    builder: (_, _) => const EnglishScoreScreen(),
  ),
  GoRoute(path: '/avatar', builder: (_, _) => const AvatarBuilderScreen()),
  GoRoute(path: '/settings', builder: (_, _) => const SettingsHubScreen()),
  GoRoute(path: '/appearance', builder: (_, _) => const AppearanceScreen()),
  GoRoute(
    path: '/accessibility',
    builder: (_, _) => const AccessibilityScreen(),
  ),
  GoRoute(
    path: '/privacy-data',
    builder: (_, _) => const PrivacyDataScreen(),
  ),
  GoRoute(
    path: '/notifications',
    builder: (_, _) => const NotificationsScreen(),
  ),
  GoRoute(path: '/help', builder: (_, _) => const HelpLegalScreen()),
  GoRoute(path: '/paywall', builder: (_, _) => const PaywallScreen()),
  GoRoute(
    path: '/checkout',
    builder: (_, _) => const CheckoutSuccessScreen(),
  ),
  GoRoute(
    path: '/subscription',
    builder: (_, _) => const ManageSubscriptionScreen(),
  ),
  GoRoute(path: '/cancel', builder: (_, _) => const CancelWinbackScreen()),
  GoRoute(path: '/promo', builder: (_, _) => const PromoRedeemScreen()),
  GoRoute(path: '/referral', builder: (_, _) => const ReferralHubScreen()),
];

/// App routing (charter: go_router). Routes grow as screens land Login→Logout.
final GoRouter appRouter = GoRouter(
  initialLocation: '/index',
  routes: appRoutes,
);
