import 'package:flutter/material.dart';
import '../../core/theme/tokens.dart';

/// Design-system text field: bordered, radius md, hairline border, hint text.
/// `obscure` adds a show/hide eye toggle (password fields).
class RatelField extends StatefulWidget {
  const RatelField({
    super.key,
    this.controller,
    required this.hint,
    this.obscure = false,
    this.keyboardType,
    this.textInputAction,
    this.onSubmitted,
  });

  final TextEditingController? controller;
  final String hint;
  final bool obscure;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onSubmitted;

  @override
  State<RatelField> createState() => _RatelFieldState();
}

class _RatelFieldState extends State<RatelField> {
  late bool _obscured = widget.obscure;

  @override
  Widget build(BuildContext context) {
    final tk = context.tokens;
    return TextField(
      controller: widget.controller,
      obscureText: _obscured,
      keyboardType: widget.keyboardType,
      textInputAction: widget.textInputAction,
      onSubmitted: widget.onSubmitted,
      style: TextStyle(color: tk.text, fontSize: 14),
      decoration: InputDecoration(
        hintText: widget.hint,
        hintStyle: TextStyle(color: tk.textMuted, fontSize: 14),
        filled: true,
        fillColor: tk.surface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: RatelSpacing.md,
          vertical: RatelSpacing.md,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(tk.radiusMd),
          borderSide: BorderSide(color: tk.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(tk.radiusMd),
          borderSide: BorderSide(color: tk.primary, width: 1.4),
        ),
        suffixIcon: widget.obscure
            ? IconButton(
                icon: Icon(
                  _obscured
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                  size: 20,
                  color: tk.textMuted,
                ),
                onPressed: () => setState(() => _obscured = !_obscured),
                tooltip: _obscured ? 'Show password' : 'Hide password',
              )
            : null,
      ),
    );
  }
}
