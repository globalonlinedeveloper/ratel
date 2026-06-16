import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/i18n/strings.dart';
import '../../../core/theme/tokens.dart';
import '../../../design_system/components/ratel_button.dart';
import '../../../design_system/components/ratel_medallion.dart';

/// Notification opt-in — mock Page-2 · screen 5 (value-framed soft-ask before
/// the OS prompt). Design-only (no backend yet).
class NotificationOptinScreen extends StatelessWidget {
  const NotificationOptinScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final tk = context.tokens;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Navigator.of(context).canPop()
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => Navigator.of(context).maybePop(),
              )
            : null,
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(
              RatelSpacing.xl,
              0,
              RatelSpacing.xl,
              RatelSpacing.xl,
            ),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Center(
                    child: RatelMedallion(
                      icon: Icons.notifications_active_outlined,
                      background: tk.warningBg,
                      foreground: tk.brand,
                    ),
                  ),
                  const SizedBox(height: RatelSpacing.md),
                  Text(
                    S.t('ob_notify_title', 'Keep your streak alive'),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: tk.text,
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: RatelSpacing.xs),
                  Text(
                    S.t(
                      'ob_notify_sub',
                      "A gentle daily reminder doubles the odds you'll stick with it.",
                    ),
                    textAlign: TextAlign.center,
                    style: TextStyle(color: tk.textMuted, fontSize: 12, height: 1.5),
                  ),
                  const SizedBox(height: RatelSpacing.md),
                  RatelButton.filled(
                    label: S.t('ob_notify_cta', 'Turn on reminders'),
                    onPressed: () => context.push('/onboarding/start'),
                  ),
                  const SizedBox(height: RatelSpacing.sm),
                  Center(
                    child: TextButton(
                      onPressed: () => context.push('/onboarding/start'),
                      child: Text(
                        S.t('ob_notify_skip', 'Not now'),
                        style: TextStyle(color: tk.textMuted, fontSize: 13),
                      ),
                    ),
                  ),
                  const SizedBox(height: RatelSpacing.sm),
                  Text(
                    S.t(
                      'ob_notify_note',
                      'Value-framed soft-ask before the OS prompt fires',
                    ),
                    textAlign: TextAlign.center,
                    style: TextStyle(color: tk.textMuted, fontSize: 10, height: 1.4),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
