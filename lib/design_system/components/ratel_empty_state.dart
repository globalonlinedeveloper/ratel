import 'package:flutter/material.dart';
import '../../core/theme/tokens.dart';
import 'ratel_button.dart';
import 'ratel_medallion.dart';

/// Reusable empty-list affordance: medallion + title + optional message +
/// optional outline action. Composes tokens + existing components only.
class RatelEmptyState extends StatelessWidget {
  const RatelEmptyState({
    super.key,
    required this.icon,
    required this.title,
    this.message,
    this.actionLabel,
    this.onAction,
  });

  final IconData icon;
  final String title;
  final String? message;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final tk = context.tokens;
    return Padding(
      padding: const EdgeInsets.all(RatelSpacing.xl),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          RatelMedallion(icon: icon, background: tk.surface2, foreground: tk.textMuted),
          const SizedBox(height: RatelSpacing.md),
          Text(title, textAlign: TextAlign.center, style: TextStyle(color: tk.text, fontSize: 16, fontWeight: FontWeight.w800)),
          if (message != null) ...<Widget>[
            const SizedBox(height: RatelSpacing.xs),
            Text(message!, textAlign: TextAlign.center, style: TextStyle(color: tk.textMuted, fontSize: 13, height: 1.5)),
          ],
          if (actionLabel != null && onAction != null) ...<Widget>[
            const SizedBox(height: RatelSpacing.lg),
            RatelButton.outline(label: actionLabel!, onPressed: onAction),
          ],
        ],
      ),
    );
  }
}
