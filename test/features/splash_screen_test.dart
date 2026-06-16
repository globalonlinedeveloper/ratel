import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:ratel/core/theme/theme.dart';
import 'package:ratel/features/auth/screens/splash_screen.dart';

GoRouter _router() => GoRouter(
      initialLocation: '/splash',
      routes: <RouteBase>[
        GoRoute(path: '/splash', builder: (_, _) => const SplashScreen()),
        GoRoute(
          path: '/welcome',
          builder: (_, _) =>
              const Scaffold(body: Center(child: Text('WELCOME_STUB'))),
        ),
      ],
    );

void main() {
  testWidgets('splash renders wordmark + tagline at 360px with no overflow',
      (tester) async {
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      MaterialApp.router(theme: ratelTheme(), routerConfig: _router()),
    );
    expect(find.text('Ratel'), findsOneWidget);
    expect(find.text('Be fearless in any language'), findsOneWidget);
    expect(tester.takeException(), isNull);
    // Let the auto-advance timer fire (clears the pending timer + checks nav).
    await tester.pump(const Duration(milliseconds: 1600));
    await tester.pumpAndSettle();
    expect(find.text('WELCOME_STUB'), findsOneWidget);
  });
}
