import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/auth/screens/welcome_screen.dart';

/// App routing (charter: go_router). Routes grow as screens land Login→Logout.
final GoRouter appRouter = GoRouter(
  initialLocation: '/welcome',
  routes: <RouteBase>[
    GoRoute(path: '/welcome', builder: (_, _) => const WelcomeScreen()),
    GoRoute(path: '/login', builder: (_, _) => const LoginScreen()),
    GoRoute(
      path: '/auth',
      builder: (_, _) => const PlaceholderScreen(title: 'Sign in'),
    ),
    GoRoute(
      path: '/signup',
      builder: (_, _) => const PlaceholderScreen(title: 'Sign up'),
    ),
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
