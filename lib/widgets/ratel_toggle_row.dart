import 'package:flutter/material.dart';
import '../theme.dart';

/// A labelled switch row (whole row tappable). Supersedes SwitchListTile.
/// Optional [leading] icon/widget; [padding] is overridable for embedding in a
/// screen that already provides its own horizontal insets.
class RatelToggleRow extends StatelessWidget {
  const RatelToggleRow({
    super.key,
    this.leading,
    required this.title,
    this.subtitle,
    required this.value,
    required this.onChanged,
    this.padding,
  });

  final Widget? leading;
  final String title;
  final String? subtitle;
  final bool value;
  final ValueChanged<bool>? onChanged;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onChanged == null ? null : () => onChanged!(!value),
      child: Padding(
        padding:
            padding ??
            const EdgeInsets.symmetric(
              horizontal: RatelSpacing.lg,
              vertical: RatelSpacing.sm,
            ),
        child: Row(
          children: [
            if (leading != null) ...[
              leading!,
              const SizedBox(width: RatelSpacing.md),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontFamily: kBodyFont,
                      fontWeight: FontWeight.w600,
                      color: context.textC,
                    ),
                  ),
                  if (subtitle != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Text(
                        subtitle!,
                        style: TextStyle(
                          fontFamily: kBodyFont,
                          fontSize: 13,
                          color: context.mutedC,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(width: RatelSpacing.md),
            Switch(value: value, onChanged: onChanged),
          ],
        ),
      ),
    );
  }
}
