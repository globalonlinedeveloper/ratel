import 'package:flutter/material.dart';
import '../../core/theme/tokens.dart';

/// Selectable bordered option card. Optional leading icon, title, subtitle and
/// trailing label. Selected = teal border + success tint. Composes tokens only.
/// (Daily goal, referral source, start point, placement answers, …)
class RatelOptionTile extends StatelessWidget {
  const RatelOptionTile({
    super.key,
    required this.title,
    required this.onTap,
    this.subtitle,
    this.leadingIcon,
    this.trailing,
    this.selected = false,
  });

  final String title;
  final VoidCallback onTap;
  final String? subtitle;
  final IconData? leadingIcon;
  final String? trailing;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final tk = context.tokens;
    final Color titleColor = selected ? tk.success : tk.text;
    final Color subColor = selected ? tk.success : tk.textMuted;
    return Material(
      color: selected ? tk.successBg : Colors.transparent,
      borderRadius: BorderRadius.circular(tk.radiusMd),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(tk.radiusMd),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: RatelSpacing.md,
            vertical: RatelSpacing.md,
          ),
          decoration: BoxDecoration(
            border: Border.all(
              color: selected ? tk.primary : tk.border,
              width: selected ? 1.5 : tk.hairline,
            ),
            borderRadius: BorderRadius.circular(tk.radiusMd),
          ),
          child: Row(
            children: <Widget>[
              if (leadingIcon != null) ...<Widget>[
                Icon(
                  leadingIcon,
                  size: 19,
                  color: selected ? tk.primary : tk.textMuted,
                ),
                const SizedBox(width: RatelSpacing.md),
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      title,
                      style: TextStyle(
                        color: titleColor,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (subtitle != null) ...<Widget>[
                      const SizedBox(height: 2),
                      Text(
                        subtitle!,
                        style: TextStyle(color: subColor, fontSize: 11, height: 1.4),
                      ),
                    ],
                  ],
                ),
              ),
              if (trailing != null) ...<Widget>[
                const SizedBox(width: RatelSpacing.sm),
                Text(
                  trailing!,
                  style: TextStyle(color: subColor, fontSize: 12),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
