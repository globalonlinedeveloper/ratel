import 'package:flutter/material.dart';
import '../../core/i18n/strings.dart';
import '../../core/theme/tokens.dart';
import 'ratel_button.dart';
import 'ratel_medallion.dart';

/// Failed-load affordance: error-toned medallion + title + message + optional
/// retry. Composes tokens + existing components only.
class RatelErrorRetry extends StatelessWidget {
  const RatelErrorRetry({super.key, this.title, this.message, this.onRetry});

  final String? title;
  final String? message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final tk = context.tokens;
    return Padding(
      padding: const EdgeInsets.all(RatelSpacing.xl),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          RatelMedallion(icon: Icons.wifi_off_outlined, background: tk.dangerBg, foreground: tk.danger),
          const SizedBox(height: RatelSpacing.md),
          Text(title ?? S.t('error_title', 'Something went wrong'), textAlign: TextAlign.center, style: TextStyle(color: tk.text, fontSize: 16, fontWeight: FontWeight.w800)),
          const SizedBox(height: RatelSpacing.xs),
          Text(message ?? S.t('error_message', 'Check your connection and try again.'), textAlign: TextAlign.center, style: TextStyle(color: tk.textMuted, fontSize: 13, height: 1.5)),
          if (onRetry != null) ...<Widget>[
            const SizedBox(height: RatelSpacing.lg),
            RatelButton.filled(label: S.t('error_retry', 'Retry'), onPressed: onRetry),
          ],
        ],
      ),
    );
  }
}
