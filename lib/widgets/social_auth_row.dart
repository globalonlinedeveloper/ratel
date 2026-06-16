import 'package:flutter/material.dart';
import '../theme.dart';
import 'ratel_button.dart';
import 'passkey_button.dart';

/// Vertical stack of auth-provider buttons (passkey-first, then social / email
/// / phone). Supersedes the hand-built provider buttons in auth_screen.dart.
class SocialAuthRow extends StatelessWidget {
  const SocialAuthRow({
    super.key,
    required this.providers,
    required this.onSelect,
    this.loadingProvider,
  });

  final List<String> providers;
  final ValueChanged<String> onSelect;
  final String? loadingProvider;

  @override
  Widget build(BuildContext context) {
    final children = <Widget>[];
    for (final p in providers) {
      if (children.isNotEmpty) {
        children.add(const SizedBox(height: RatelSpacing.sm));
      }
      final loading = loadingProvider == p;
      children.add(
        p == 'passkey'
            ? PasskeyButton(onPressed: () => onSelect(p), loading: loading)
            : RatelButton.social(
                provider: p,
                label: _label(p),
                onPressed: () => onSelect(p),
                loading: loading,
              ),
      );
    }
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: children,
    );
  }

  static String _label(String p) {
    switch (p) {
      case 'google':
        return 'Continue with Google';
      case 'apple':
        return 'Continue with Apple';
      case 'email':
        return 'Continue with email';
      case 'phone':
        return 'Continue with phone';
      default:
        return 'Continue';
    }
  }
}
