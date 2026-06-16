import 'package:flutter/material.dart';
import '../../core/theme/tokens.dart';

/// Selectable pill chip. Selected = teal border + success tint; unselected =
/// hairline border. Composes tokens only. (Motivation, topic pickers, …)
class RatelChoiceChip extends StatelessWidget {
  const RatelChoiceChip({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final tk = context.tokens;
    return Material(
      color: selected ? tk.successBg : Colors.transparent,
      shape: StadiumBorder(
        side: BorderSide(
          color: selected ? tk.primary : tk.border,
          width: selected ? 1.5 : tk.hairline,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: RatelSpacing.md,
            vertical: RatelSpacing.sm + 1,
          ),
          child: Text(
            label,
            style: TextStyle(
              color: selected ? tk.success : tk.text,
              fontSize: 12,
              fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
        ),
      ),
    );
  }
}
