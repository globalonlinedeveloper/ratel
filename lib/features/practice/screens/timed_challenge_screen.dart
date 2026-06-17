import 'package:flutter/material.dart';
import '../../../core/i18n/strings.dart';
import '../../../core/theme/tokens.dart';
import '../../../design_system/components/ratel_button.dart';
import '../../../design_system/components/ratel_medallion.dart';

/// Timed challenge — mock Page-4 · screen 3 (60-second sprint, no energy at
/// risk). Design-only (no backend yet).
class TimedChallengeScreen extends StatelessWidget {
  const TimedChallengeScreen({super.key});

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
            padding: const EdgeInsets.fromLTRB(RatelSpacing.xl, 0, RatelSpacing.xl, RatelSpacing.xl),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Center(
                    child: RatelMedallion(
                      icon: Icons.timer_outlined,
                      background: tk.warningBg,
                      foreground: tk.coral,
                      size: 66,
                      iconSize: 34,
                    ),
                  ),
                  const SizedBox(height: RatelSpacing.md),
                  Text(
                    S.t('timed_title', 'Timed challenge'),
                    textAlign: TextAlign.center,
                    style: TextStyle(color: tk.text, fontSize: 18, fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: RatelSpacing.xs),
                  Text(
                    S.t('timed_sub', 'Answer as many as you can in 60 seconds. No energy at risk — pure practice.'),
                    textAlign: TextAlign.center,
                    style: TextStyle(color: tk.textMuted, fontSize: 12, height: 1.5),
                  ),
                  const SizedBox(height: RatelSpacing.md),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      _Stat(value: S.t('timed_clock', '60s'), label: S.t('timed_clock_l', 'clock'), color: tk.text),
                      const SizedBox(width: RatelSpacing.xl),
                      _Stat(value: S.t('timed_best', '42'), label: S.t('timed_best_l', 'best score'), color: tk.brand),
                    ],
                  ),
                  const SizedBox(height: RatelSpacing.lg),
                  RatelButton.filled(label: S.t('timed_cta', 'Start challenge'), onPressed: () {}),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

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
        Text(value, style: TextStyle(color: color, fontSize: 17, fontWeight: FontWeight.w600)),
        const SizedBox(height: 2),
        Text(label, style: TextStyle(color: tk.textMuted, fontSize: 10)),
      ],
    );
  }
}
