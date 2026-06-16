import 'package:flutter/material.dart';
import '../theme.dart';

/// A labelled switch row (whole row tappable). Supersedes SwitchListTile in
/// settings_screen.dart.
class RatelToggleRow extends StatelessWidget {
  const RatelToggleRow({
    super.key,
    required this.title,
    this.subtitle,
    required this.value,
    required this.onChanged,
  });

  final String title;
  final String? subtitle;
  final bool value;
  final ValueChanged<bool>? onChanged;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onChanged == null ? null : () => onChanged!(!value),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: RatelSpacing.lg,
          vertical: RatelSpacing.sm,
        ),
        child: Row(
          children: [
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
