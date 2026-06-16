import 'package:go_router/go_router.dart';
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

/// App routing (charter: go_router). Routes grow as screens land Login→Logout.
final GoRouter appRouter = GoRouter(
  initialLocation: '/splash',
  routes: <RouteBase>[
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
    GoRoute(path: '/parental', builder: (_, _) => const ParentalConsentScreen()),
    GoRoute(path: '/phone', builder: (_, _) => const PhoneVerifyScreen()),
    GoRoute(path: '/otp', builder: (_, _) => const OtpScreen()),
    GoRoute(path: '/forgot', builder: (_, _) => const ForgotPasswordScreen()),
    GoRoute(path: '/reset-sent', builder: (_, _) => const ResetSentScreen()),
    GoRoute(
      path: '/set-password',
      builder: (_, _) => const SetNewPasswordScreen(),
    ),
    GoRoute(path: '/email-verify', builder: (_, _) => const EmailVerifyScreen()),
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
    GoRoute(path: '/lesson/choice', builder: (_, _) => const LessonChoiceScreen()),
    GoRoute(
      path: '/lesson/speaking',
      builder: (_, _) => const LessonSpeakingScreen(),
    ),
    GoRoute(
      path: '/lesson/listen',
      builder: (_, _) => const LessonListenScreen(),
    ),
  ],
);

