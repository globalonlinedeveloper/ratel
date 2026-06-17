import 'package:flutter/material.dart';
import '../../core/i18n/strings.dart';
import '../../core/theme/tokens.dart';

/// Lesson header: a close (✕), a progress bar, and the remaining energy count.
/// Shared by every in-lesson exercise screen. Composes tokens only.
class LessonTopBar extends StatelessWidget {
  const LessonTopBar({
    super.key,
    required this.progress,
    required this.energy,
    this.onClose,
  });

  /// 0..1 lesson completion.
  final double progress;
  final int energy;
  final VoidCallback? onClose;

  @override
  Widget build(BuildContext context) {
    final tk = context.tokens;
    return Row(
      children: <Widget>[
        IconButton(
          icon: Icon(Icons.close, size: 20, color: tk.textMuted),
          onPressed: onClose ?? () {},
          tooltip: S.t('a11y_close', 'Close'),
          visualDensity: VisualDensity.compact,
        ),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(tk.radiusPill),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: tk.border,
              valueColor: AlwaysStoppedAnimation<Color>(tk.primary),
            ),
          ),
        ),
        const SizedBox(width: RatelSpacing.sm),
        Semantics(
          label: '${S.t('lesson_energy_a11y', 'Energy remaining')}: $energy',
          excludeSemantics: true,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Icon(Icons.bolt, size: 16, color: tk.brand),
              const SizedBox(width: 2),
              Text(
                '$energy',
                style: TextStyle(
                  color: tk.brand,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
