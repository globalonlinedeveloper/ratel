import 'package:flutter/material.dart';
import '../../core/theme/tokens.dart';

enum _Variant { filled, outline, neutral }

/// Primary action button. `.filled` = teal CTA (white label); `.outline` =
/// bordered teal; `.neutral` = hairline-bordered neutral (social / secondary
/// options, neutral label). 48px tall (a11y tap target). Composes tokens only.
class RatelButton extends StatelessWidget {
  const RatelButton.filled({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
    this.loading = false,
  }) : _variant = _Variant.filled;

  const RatelButton.outline({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
    this.loading = false,
  }) : _variant = _Variant.outline;

  const RatelButton.neutral({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
    this.loading = false,
  }) : _variant = _Variant.neutral;

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool loading;
  final _Variant _variant;

  @override
  Widget build(BuildContext context) {
    final tk = context.tokens;
    final bool filled = _variant == _Variant.filled;
    final Color fg = switch (_variant) {
      _Variant.filled => Colors.white,
      _Variant.outline => tk.primary,
      _Variant.neutral => tk.text,
    };
    final BorderSide side = switch (_variant) {
      _Variant.filled => BorderSide.none,
      _Variant.outline => BorderSide(color: tk.primary, width: 1.5),
      _Variant.neutral => BorderSide(color: tk.border, width: 1),
    };
    final bool disabled = onPressed == null || loading;

    final Widget child = loading
        ? SizedBox(
            height: 20,
            width: 20,
            child: CircularProgressIndicator(strokeWidth: 2.2, color: fg),
          )
        : Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              if (icon != null) ...<Widget>[
                Icon(icon, size: 18, color: fg),
                const SizedBox(width: RatelSpacing.sm),
              ],
              Flexible(
                child: Text(
                  label,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: fg,
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
              ),
            ],
          );

    return Semantics(
      button: true,
      enabled: !disabled,
      label: label,
      child: Material(
        color: filled ? tk.primary : Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(tk.radiusMd),
          side: side,
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: disabled ? null : onPressed,
          child: Container(
            height: 48,
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(horizontal: RatelSpacing.lg),
            child: child,
          ),
        ),
      ),
    );
  }
}
