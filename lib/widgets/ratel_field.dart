import 'package:flutter/material.dart';
import '../theme.dart';

/// Standard labelled text field. Supersedes raw TextField/TextFormField.
/// Token radius + 0.5 hairline; filled surface2; primary focus ring; danger
/// error state — all from tokens.
class RatelField extends StatelessWidget {
  const RatelField({
    super.key,
    this.controller,
    required this.label,
    this.hint,
    this.error,
    this.obscure = false,
    this.keyboardType,
    this.onChanged,
    this.prefixIcon,
    this.suffix,
  });

  final TextEditingController? controller;
  final String label;
  final String? hint;
  final String? error;
  final bool obscure;
  final TextInputType? keyboardType;
  final ValueChanged<String>? onChanged;
  final IconData? prefixIcon;
  final Widget? suffix;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final radius = BorderRadius.circular(t.radiusMd);
    OutlineInputBorder border(Color c, double w) => OutlineInputBorder(
      borderRadius: radius,
      borderSide: BorderSide(color: c, width: w),
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 6, left: 2),
          child: Text(
            label,
            style: TextStyle(
              fontFamily: kBodyFont,
              fontWeight: FontWeight.w600,
              fontSize: 13,
              color: context.mutedC,
            ),
          ),
        ),
        TextField(
          controller: controller,
          obscureText: obscure,
          keyboardType: keyboardType,
          onChanged: onChanged,
          decoration: InputDecoration(
            hintText: hint,
            errorText: error,
            filled: true,
            fillColor: context.isDark
                ? RatelColorsDark.surface2
                : RatelColors.surface2,
            prefixIcon: prefixIcon == null ? null : Icon(prefixIcon, size: 20),
            suffixIcon: suffix,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: RatelSpacing.md,
              vertical: RatelSpacing.md,
            ),
            enabledBorder: border(context.borderC, t.hairline),
            focusedBorder: border(Theme.of(context).colorScheme.primary, 1.2),
            errorBorder: border(t.danger, t.hairline),
            focusedErrorBorder: border(t.danger, 1.2),
          ),
        ),
      ],
    );
  }
}
