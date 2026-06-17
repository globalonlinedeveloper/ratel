import 'package:flutter/material.dart';
import '../../core/i18n/strings.dart';
import '../../core/theme/tokens.dart';

/// Live password-strength meter: three bars + a level label, driven by
/// [strength] (0–3, from `passwordStrength`). Tokens only — replaces the old
/// per-screen static stubs.
class RatelPasswordStrength extends StatelessWidget {
  const RatelPasswordStrength({super.key, required this.strength});

  final int strength;

  @override
  Widget build(BuildContext context) {
    final tk = context.tokens;
    final Color levelColor = switch (strength) {
      >= 3 => tk.success,
      2 => tk.warning,
      1 => tk.danger,
      _ => tk.border,
    };
    final String? label = switch (strength) {
      >= 3 => S.t('pw_good', 'Good'),
      2 => S.t('pw_fair', 'Fair'),
      1 => S.t('pw_weak', 'Weak'),
      _ => null,
    };
    return Row(
      children: <Widget>[
        for (int i = 0; i < 3; i++) ...<Widget>[
          if (i > 0) const SizedBox(width: RatelSpacing.xs),
          Expanded(
            child: Container(
              height: 5,
              decoration: BoxDecoration(
                color: i < strength ? levelColor : tk.border,
                borderRadius: BorderRadius.circular(tk.radiusSm),
              ),
            ),
          ),
        ],
        if (label != null) ...<Widget>[
          const SizedBox(width: RatelSpacing.sm),
          Text(label, style: TextStyle(color: levelColor, fontSize: 11, fontWeight: FontWeight.w600)),
        ],
      ],
    );
  }
}
