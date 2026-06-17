import 'package:flutter/material.dart';
import '../../core/theme/tokens.dart';

/// A settings/list row: leading icon + label + trailing affordance, with an
/// optional hairline divider. When [onTap] is null the row is non-interactive —
/// it renders WITHOUT the trailing chevron and without an InkWell ripple, so a
/// placeholder row never masquerades as working navigation. Composes tokens only.
class RatelSettingsRow extends StatelessWidget {
  const RatelSettingsRow({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.label,
    this.onTap,
    this.trailing = Icons.chevron_right,
    this.divider = true,
  });

  final IconData icon;
  final Color iconColor;
  final String label;
  final VoidCallback? onTap;
  final IconData trailing;
  final bool divider;

  @override
  Widget build(BuildContext context) {
    final tk = context.tokens;
    final bool interactive = onTap != null;
    final Widget content = Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 4,
        vertical: RatelSpacing.md - 1,
      ),
      decoration: divider
          ? BoxDecoration(
              border: Border(
                bottom: BorderSide(color: tk.border, width: tk.hairline),
              ),
            )
          : null,
      child: Row(
        children: <Widget>[
          Icon(icon, size: 19, color: iconColor),
          const SizedBox(width: RatelSpacing.md - 1),
          Expanded(
            child: Text(label, style: TextStyle(color: tk.text, fontSize: 13)),
          ),
          if (interactive) Icon(trailing, size: 16, color: tk.textMuted),
        ],
      ),
    );
    if (!interactive) return content;
    return Semantics(
      button: true,
      label: label,
      onTap: onTap,
      child: ExcludeSemantics(
        child: InkWell(onTap: onTap, child: content),
      ),
    );
  }
}
