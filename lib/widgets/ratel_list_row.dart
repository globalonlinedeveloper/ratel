import 'package:flutter/material.dart';
import '../theme.dart';

/// Standard tappable row: optional leading, title (+ optional subtitle),
/// optional trailing (defaults to a chevron when [onTap] is set). Supersedes
/// ad-hoc ListTile/Row rows. Sits on the current surface; pair with RatelCard.
class RatelListRow extends StatelessWidget {
  const RatelListRow({
    super.key,
    this.leading,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
  });

  final Widget? leading;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final trail =
        trailing ??
        (onTap != null
            ? Icon(Icons.chevron_right, color: context.mutedC, size: 22)
            : null);
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: RatelSpacing.lg,
          vertical: RatelSpacing.md,
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
            if (trail != null) ...[
              const SizedBox(width: RatelSpacing.sm),
              trail,
            ],
          ],
        ),
      ),
    );
  }
}
