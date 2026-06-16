import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/screens/age_check_screen.dart';
import '../../features/auth/screens/auth_hub_screen.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/auth/screens/privacy_choices_screen.dart';
import '../../features/auth/screens/returning_unlock_screen.dart';
import '../../features/auth/screens/signup_screen.dart';
import '../../features/auth/screens/social_consent_screen.dart';
import '../../features/auth/screens/splash_screen.dart';
import '../../features/auth/screens/welcome_screen.dart';

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
    GoRoute(
      path: '/forgot',
      builder: (_, _) => const PlaceholderScreen(title: 'Forgot password'),
    ),
  ],
);

/// Temporary destination for routes not yet built. Replaced as screens land.
class PlaceholderScreen extends StatelessWidget {
  const PlaceholderScreen({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: const Center(child: Text('Coming soon')),
    );
  }
}
