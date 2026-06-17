import 'package:flutter/material.dart';
import '../../../core/i18n/strings.dart';
import '../../../core/theme/tokens.dart';
import '../../../design_system/components/ratel_medallion.dart';

/// Radio episode — the "now playing" shell for a listening-feed episode
/// (audit P1-1). Static design-only mock: the medallion, scrubber, transport
/// controls and transcript are presentational; there is no audio engine yet
/// (real playback + audio assets land in Phase 2/3). Transport buttons are
/// Phase-3 stubs and carry Semantics/tooltip labels for screen readers.
class RadioEpisodeScreen extends StatelessWidget {
  const RadioEpisodeScreen({super.key});

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
                tooltip: S.t('a11y_back', 'Back'),
                onPressed: () => Navigator.of(context).maybePop(),
              )
            : null,
      ),
      body: SafeArea(
        child: Align(
          alignment: Alignment.topCenter,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(
              RatelSpacing.md,
              0,
              RatelSpacing.md,
              RatelSpacing.md,
            ),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  const SizedBox(height: RatelSpacing.md),
                  Center(
                    child: RatelMedallion(
                      icon: Icons.podcasts,
                      background: tk.infoBg,
                      foreground: tk.info,
                      size: 104,
                      iconSize: 52,
                    ),
                  ),
                  const SizedBox(height: RatelSpacing.md),
                  Text(
                    S.t('listen_ep_title', 'Morning news, slowly'),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: tk.text,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    S.t('listen_ep_meta', 'A2 · with Mei · 4 min'),
                    textAlign: TextAlign.center,
                    style: TextStyle(color: tk.textMuted, fontSize: 11.5),
                  ),
                  const SizedBox(height: RatelSpacing.lg),
                  Stack(
                    alignment: Alignment.centerLeft,
                    children: <Widget>[
                      Container(
                        height: 4,
                        decoration: BoxDecoration(
                          color: tk.border,
                          borderRadius: BorderRadius.circular(tk.radiusPill),
                        ),
                      ),
                      Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: tk.primary,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Text(
                        S.t('listen_ep_elapsed', '00:00'),
                        style: TextStyle(color: tk.textMuted, fontSize: 10.5),
                      ),
                      Text(
                        S.t('listen_ep_total', '04:00'),
                        style: TextStyle(color: tk.textMuted, fontSize: 10.5),
                      ),
                    ],
                  ),
                  const SizedBox(height: RatelSpacing.lg),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      IconButton(
                        icon: const Icon(Icons.skip_previous),
                        tooltip: S.t('listen_prev', 'Previous'),
                        color: tk.text,
                        iconSize: 30,
                        onPressed: () {},
                      ),
                      const SizedBox(width: RatelSpacing.lg),
                      Semantics(
                        button: true,
                        label: S.t('listen_play', 'Play'),
                        child: GestureDetector(
                          onTap: () {},
                          child: Container(
                            width: 64,
                            height: 64,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: tk.primary,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.play_arrow,
                              color: Colors.white,
                              size: 34,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: RatelSpacing.lg),
                      IconButton(
                        icon: const Icon(Icons.skip_next),
                        tooltip: S.t('listen_next', 'Next'),
                        color: tk.text,
                        iconSize: 30,
                        onPressed: () {},
                      ),
                    ],
                  ),
                  const SizedBox(height: RatelSpacing.lg),
                  Container(
                    padding: const EdgeInsets.all(RatelSpacing.md),
                    decoration: BoxDecoration(
                      color: tk.surface2,
                      borderRadius: BorderRadius.circular(tk.radiusMd),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Row(
                          children: <Widget>[
                            Icon(Icons.notes, size: 14, color: tk.textMuted),
                            const SizedBox(width: 6),
                            Text(
                              S.t('listen_transcript', 'Transcript'),
                              style: TextStyle(
                                color: tk.textMuted,
                                fontSize: 10.5,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: RatelSpacing.sm),
                        Text(
                          S.t(
                            'listen_transcript_body',
                            'Good morning. Today the weather is sunny and '
                            'warm. Many people are walking in the park. A '
                            'small dog runs after a red ball near the lake.',
                          ),
                          style: TextStyle(
                            color: tk.text,
                            fontSize: 12,
                            height: 1.5,
                          ),
                        ),
                      ],
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
