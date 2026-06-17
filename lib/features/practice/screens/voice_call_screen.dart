import 'package:flutter/material.dart';
import '../../../core/i18n/strings.dart';
import '../../../core/theme/tokens.dart';

/// Voice call — mock Page-4 · screen 5 (live AI voice conversation, immersive
/// dark). Design-only (no backend/voice yet).
class VoiceCallScreen extends StatelessWidget {
  const VoiceCallScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final tk = context.tokens;
    return Scaffold(
      backgroundColor: RatelCall.bg,
      body: SafeArea(
        child: Align(alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 440),
            child: Padding(
              padding: const EdgeInsets.all(RatelSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          Icon(Icons.circle, size: 9, color: RatelCall.wave),
                          const SizedBox(width: 4),
                          Text(S.t('call_live', 'live · 02:14'), style: const TextStyle(color: RatelCall.caption, fontSize: 11)),
                        ],
                      ),
                      Text(S.t('call_ai', '2/5 AI'), style: const TextStyle(color: RatelCall.caption, fontSize: 11)),
                    ],
                  ),
                  const Spacer(),
                  Center(
                    child: Container(
                      width: 96,
                      height: 96,
                      alignment: Alignment.center,
                      decoration: const BoxDecoration(color: RatelCall.avatar, shape: BoxShape.circle),
                      child: const Icon(Icons.person, size: 50, color: Colors.white),
                    ),
                  ),
                  const SizedBox(height: RatelSpacing.md),
                  Text(
                    S.t('call_name', 'Maya · café scene'),
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: RatelSpacing.md),
                  const _CallWave(),
                  const SizedBox(height: RatelSpacing.md),
                  Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: RatelSpacing.md, vertical: RatelSpacing.sm),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(tk.radiusMd),
                      ),
                      child: Text(
                        S.t('call_caption', '"What would you like to drink?"'),
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: RatelCall.caption, fontSize: 11.5),
                      ),
                    ),
                  ),
                  const Spacer(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      _CallButton(icon: Icons.mic_off, color: Colors.white.withValues(alpha: 0.14)),
                      const SizedBox(width: RatelSpacing.lg),
                      _CallButton(icon: Icons.call_end, color: tk.danger),
                      const SizedBox(width: RatelSpacing.lg),
                      _CallButton(icon: Icons.closed_caption, color: Colors.white.withValues(alpha: 0.14)),
                    ],
                  ),
                  const SizedBox(height: RatelSpacing.md),
                  Text(
                    S.t('call_footer', 'AI voice · live captions · transcript & feedback after'),
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: RatelCall.caption, fontSize: 9),
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

class _CallWave extends StatelessWidget {
  const _CallWave();

  @override
  Widget build(BuildContext context) {
    const List<double> heights = <double>[0.4, 0.8, 1.0, 0.6, 0.3];
    return SizedBox(
      height: 30,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: <Widget>[
          for (final double h in heights) ...<Widget>[
            Container(
              width: 4,
              height: 30 * h,
              decoration: BoxDecoration(color: RatelCall.wave, borderRadius: BorderRadius.circular(2)),
            ),
            const SizedBox(width: 3),
          ],
        ],
      ),
    );
  }
}

class _CallButton extends StatelessWidget {
  const _CallButton({required this.icon, required this.color});

  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 48,
      height: 48,
      alignment: Alignment.center,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      child: Icon(icon, size: 22, color: Colors.white),
    );
  }
}
