import 'package:flutter/material.dart';
import '../../core/theme/tokens.dart';

/// A labelled setting toggle (label + optional subtitle + Switch). Composes
/// tokens only. (Appearance, Accessibility, Privacy, Notifications.)
class RatelToggleRow extends StatelessWidget {
  const RatelToggleRow({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
    this.subtitle,
    this.switchKey,
  });

  final String label;
  final bool value;
  final ValueChanged<bool>? onChanged;
  final String? subtitle;
  final Key? switchKey;

  @override
  Widget build(BuildContext context) {
    final tk = context.tokens;
    return Row(
      children: <Widget>[
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(label, style: TextStyle(color: tk.text, fontSize: 12)),
              if (subtitle != null)
                Text(subtitle!, style: TextStyle(color: tk.textMuted, fontSize: 9)),
            ],
          ),
        ),
        Switch(key: switchKey, value: value, onChanged: onChanged),
      ],
    );
  }
}
