import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/i18n/strings.dart';
import '../../../core/theme/tokens.dart';
import '../../../design_system/components/ratel_button.dart';
import '../../../design_system/components/ratel_medallion.dart';

/// First win — mock Page-2 · screen 9 (the guaranteed early dopamine hit).
/// Design-only (no backend yet).
class FirstWinScreen extends StatelessWidget {
  const FirstWinScreen({super.key});

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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Icon(Icons.celebration, size: 22, color: tk.brand),
                      const SizedBox(width: RatelSpacing.xs),
                      Icon(Icons.celebration, size: 22, color: tk.primary),
                      const SizedBox(width: RatelSpacing.xs),
                      Icon(Icons.celebration, size: 22, color: tk.coral),
                    ],
                  ),
                  const SizedBox(height: RatelSpacing.md),
                  Center(
                    child: RatelMedallion(
                      icon: Icons.emoji_events,
                      background: tk.warningBg,
                      foreground: tk.brand,
                      size: 84,
                      iconSize: 46,
                    ),
                  ),
                  const SizedBox(height: RatelSpacing.md),
                  Text(
                    S.t('ob_firstwin_title', 'First lesson done!'),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: tk.text,
                      fontSize: 19,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: RatelSpacing.md),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      _Stat(
                        value: S.t('ob_firstwin_xp', '+10'),
                        label: S.t('ob_firstwin_xp_label', 'XP'),
                        color: tk.brand,
                      ),
                      const SizedBox(width: RatelSpacing.xl),
                      _Stat(
                        value: S.t('ob_firstwin_streak', '1'),
                        label: S.t('ob_firstwin_streak_label', 'day streak'),
                        color: tk.coral,
                      ),
                    ],
                  ),
                  const SizedBox(height: RatelSpacing.sm),
                  Text(
                    S.t(
                      'ob_firstwin_note',
                      'The guaranteed early win — the dopamine that brings them back.',
                    ),
                    textAlign: TextAlign.center,
                    style: TextStyle(color: tk.textMuted, fontSize: 12, height: 1.5),
                  ),
                  const SizedBox(height: RatelSpacing.md),
                  RatelButton.filled(
                    label: S.t('ob_firstwin_cta', 'Continue'),
                    onPressed: () => context.go('/welcome'),
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
        Text(label, style: TextStyle(color: tk.textMuted, fontSize: 10)),
      ],
    );
  }
}
