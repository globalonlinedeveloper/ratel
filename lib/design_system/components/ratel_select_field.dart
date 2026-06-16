import 'package:flutter/material.dart';
import '../../core/theme/tokens.dart';

/// Presentational select row (bordered, trailing chevron, optional leading
/// icon). `active` outlines it in the primary colour. Design-only trigger —
/// wires to a real picker later. Composes tokens only.
class RatelSelectField extends StatelessWidget {
  const RatelSelectField({
    super.key,
    required this.label,
    required this.onTap,
    this.leadingIcon,
    this.active = false,
  });

  final String label;
  final VoidCallback onTap;
  final IconData? leadingIcon;
  final bool active;

  @override
  Widget build(BuildContext context) {
    final tk = context.tokens;
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(tk.radiusMd),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(tk.radiusMd),
        child: Container(
          height: 46,
          padding: const EdgeInsets.symmetric(horizontal: RatelSpacing.md),
          decoration: BoxDecoration(
            border: Border.all(
              color: active ? tk.primary : tk.border,
              width: active ? 1.5 : tk.hairline,
            ),
            borderRadius: BorderRadius.circular(tk.radiusMd),
          ),
          child: Row(
            children: <Widget>[
              if (leadingIcon != null) ...<Widget>[
                Icon(leadingIcon, size: 16, color: tk.textMuted),
                const SizedBox(width: RatelSpacing.sm),
              ],
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(color: tk.text, fontSize: 13),
                ),
              ),
              Icon(Icons.expand_more, size: 18, color: tk.textMuted),
            ],
          ),
        ),
      ),
    );
  }
}
