import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/i18n/strings.dart';
import '../../../core/theme/tokens.dart';
import '../../../design_system/components/ratel_medallion.dart';

/// Splash — mock Page-1 · screen 1. Brand entry; auto-advances to /welcome
/// after a short beat. Design-only (no backend until phase 3).
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer(const Duration(milliseconds: 1500), () {
      if (mounted) context.go('/welcome');
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tk = context.tokens;
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(RatelSpacing.xl),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                RatelMedallion(
                  icon: Icons.sentiment_satisfied_alt,
                  background: tk.warningBg,
                  foreground: tk.brand,
                  size: 92,
                  iconSize: 54,
                ),
                const SizedBox(height: RatelSpacing.lg),
                Text(
                  S.t('splash_wordmark', 'Ratel'),
                  style: TextStyle(
                    color: tk.brand,
                    fontSize: 32,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: RatelSpacing.sm),
                Text(
                  S.t('splash_tagline', 'Be fearless in any language'),
                  style: TextStyle(color: tk.textMuted, fontSize: 14),
                ),
                const SizedBox(height: RatelSpacing.lg),
                const _SplashDots(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Carousel position dots (first active) — decorative.
class _SplashDots extends StatelessWidget {
  const _SplashDots();

  @override
  Widget build(BuildContext context) {
    final tk = context.tokens;
    Widget dot(bool active) => Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: active ? tk.primary : tk.border,
            shape: BoxShape.circle,
          ),
        );
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        dot(true),
        const SizedBox(width: 7),
        dot(false),
        const SizedBox(width: 7),
        dot(false),
      ],
    );
  }
}
