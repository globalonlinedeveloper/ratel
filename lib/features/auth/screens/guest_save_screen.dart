import 'package:flutter/material.dart';
import '../../../core/i18n/strings.dart';
import '../../../core/theme/tokens.dart';
import '../../../design_system/components/ratel_button.dart';
import '../../../design_system/components/ratel_medallion.dart';

/// Guest → save progress — mock Page-1 · screen 17 (prompt to save streak/XP
/// after a first lesson). Design-only (no backend yet).
class GuestSaveScreen extends StatelessWidget {
  const GuestSaveScreen({super.key});

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
                      icon: Icons.emoji_events_outlined,
                      background: tk.successBg,
                      foreground: tk.success,
                    ),
                  ),
                  const SizedBox(height: RatelSpacing.md),
                  Text(
                    S.t('guest_title', 'Nice — first lesson done!'),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: tk.text,
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: RatelSpacing.xs),
                  Text(
                    S.t('guest_sub', 'Save your streak & XP before you go.'),
                    textAlign: TextAlign.center,
                    style: TextStyle(color: tk.textMuted, fontSize: 12, height: 1.5),
                  ),
                  const SizedBox(height: RatelSpacing.md),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      _Stat(
                        value: S.t('guest_xp', '+10'),
                        label: S.t('guest_xp_label', 'XP'),
                        color: tk.brand,
                      ),
                      const SizedBox(width: RatelSpacing.xl),
                      _Stat(
                        value: S.t('guest_streak', '1'),
                        label: S.t('guest_streak_label', 'day streak'),
                        color: tk.coral,
                      ),
                    ],
                  ),
                  const SizedBox(height: RatelSpacing.lg),
                  RatelButton.outline(
                    icon: Icons.fingerprint,
                    label: S.t('guest_passkey', 'Save with a passkey'),
                    onPressed: () {},
                  ),
                  const SizedBox(height: RatelSpacing.sm),
                  RatelButton.filled(
                    label: S.t('guest_email', 'Save with email'),
                    onPressed: () {},
                  ),
                  const SizedBox(height: RatelSpacing.sm),
                  Center(
                    child: TextButton(
                      onPressed: () {},
                      child: Text(
                        S.t('guest_later', 'Maybe later'),
                        style: TextStyle(color: tk.textMuted, fontSize: 13),
                      ),
                    ),
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

/// One reward stat: a large coloured number over a muted label.
class _Stat extends StatelessWidget {
  const _Stat({required this.value, required this.label, required this.color});

  final String value;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final tk = context.tokens;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: 20,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(color: tk.textMuted, fontSize: 10),
        ),
      ],
    );
  }
}
