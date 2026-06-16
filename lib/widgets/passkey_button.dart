import 'package:flutter/material.dart';
import 'ratel_button.dart';

/// Passkey / WebAuthn CTA — a thin, named wrapper over RatelButton.social so
/// the passkey-first auth flow reads clearly at call sites.
class PasskeyButton extends StatelessWidget {
  const PasskeyButton({
    super.key,
    required this.onPressed,
    this.loading = false,
    this.label = 'Continue with a passkey',
  });

  final VoidCallback? onPressed;
  final bool loading;
  final String label;

  @override
  Widget build(BuildContext context) => RatelButton.social(
    provider: 'passkey',
    label: label,
    onPressed: onPressed,
    loading: loading,
  );
}
