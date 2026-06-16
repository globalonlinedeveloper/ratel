import 'package:flutter/material.dart';
import '../theme.dart';

enum _Variant { filled, outline, social }

/// The kit's single button primitive — filled (primary CTA), outline, and
/// social (provider glyph + label). Supersedes raw Elevated/Filled/Outlined
/// buttons and the hand-rolled social buttons in auth_screen.dart. Styling
/// (color, radius) comes from the theme; this adds variants, a loading state
/// and consistent full-width behaviour.
class RatelButton extends StatelessWidget {
  const RatelButton.filled({
    super.key,
    required this.label,
    this.icon,
    required this.onPressed,
    this.loading = false,
    this.expand = true,
  }) : _variant = _Variant.filled,
       provider = null;

  const RatelButton.outline({
    super.key,
    required this.label,
    this.icon,
    required this.onPressed,
    this.loading = false,
    this.expand = true,
  }) : _variant = _Variant.outline,
       provider = null;

  const RatelButton.social({
    super.key,
    required this.provider,
    required this.label,
    required this.onPressed,
    this.loading = false,
    this.expand = true,
  }) : _variant = _Variant.social,
       icon = null;

  final String label;
  final IconData? icon;
  final String? provider;
  final VoidCallback? onPressed;
  final bool loading;
  final bool expand;
  final _Variant _variant;

  @override
  Widget build(BuildContext context) {
    final onTap = (loading || onPressed == null) ? null : onPressed;
    final primary = Theme.of(context).colorScheme.primary;

    Widget content(Color spinnerColor) {
      if (loading) {
        return SizedBox(
          height: 18,
          width: 18,
          child: CircularProgressIndicator(strokeWidth: 2, color: spinnerColor),
        );
      }
      final ic = _variant == _Variant.social ? _providerIcon(provider) : icon;
      if (ic == null) return Text(label);
      return Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(ic, size: 18),
          const SizedBox(width: RatelSpacing.sm),
          Flexible(child: Text(label, overflow: TextOverflow.ellipsis)),
        ],
      );
    }

    final btn = switch (_variant) {
      _Variant.filled => FilledButton(
        onPressed: onTap,
        child: content(Colors.white),
      ),
      _Variant.outline || _Variant.social => OutlinedButton(
        onPressed: onTap,
        child: content(primary),
      ),
    };
    return expand ? SizedBox(width: double.infinity, child: btn) : btn;
  }

  static IconData _providerIcon(String? p) {
    switch (p) {
      case 'google':
        return Icons.g_mobiledata;
      case 'apple':
        return Icons.apple;
      case 'phone':
        return Icons.phone_outlined;
      case 'email':
        return Icons.email_outlined;
      case 'passkey':
        return Icons.vpn_key_outlined;
      default:
        return Icons.login;
    }
  }
}
