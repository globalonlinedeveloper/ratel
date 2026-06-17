import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/i18n/strings.dart';
import '../../../core/theme/tokens.dart';
import '../../../design_system/components/ratel_medallion.dart';

/// Passive listening / "radio" feed — DuoRadio-style low-pressure listening
/// (audit P1-1). Browse short episodes; tapping one opens the now-playing
/// shell. Design-only: episodes are a mock list and there is no audio engine
/// yet (real playback + audio assets land in Phase 2/3).
class ListeningFeedScreen extends StatelessWidget {
  const ListeningFeedScreen({super.key});

  static const List<_Episode> _episodes = <_Episode>[
    _Episode('Morning news, slowly', 'A2', '4 min', 'Daily life'),
    _Episode('Coffee shop chatter', 'A1', '3 min', 'Everyday talk'),
    _Episode('A walk in the city', 'B1', '6 min', 'Travel'),
    _Episode('Two friends catch up', 'A2', '5 min', 'Conversation'),
    _Episode('Science in five minutes', 'B1', '5 min', 'Ideas'),
    _Episode('Bedtime story: the kind fox', 'A1', '7 min', 'Stories'),
  ];

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
                  Text(
                    S.t('listen_title', 'Listening'),
                    style: TextStyle(
                      color: tk.text,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    S.t(
                      'listen_sub',
                      'Low-pressure listening — tune in on the go',
                    ),
                    style: TextStyle(color: tk.textMuted, fontSize: 10.5),
                  ),
                  const SizedBox(height: RatelSpacing.md),
                  for (final _Episode e in _episodes) ...<Widget>[
                    _EpisodeCard(episode: e),
                    const SizedBox(height: RatelSpacing.sm),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Episode {
  const _Episode(this.title, this.level, this.duration, this.topic);

  final String title;
  final String level;
  final String duration;
  final String topic;
}

class _EpisodeCard extends StatelessWidget {
  const _EpisodeCard({required this.episode});

  final _Episode episode;

  @override
  Widget build(BuildContext context) {
    final tk = context.tokens;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => context.push('/listen/episode'),
      child: Container(
        padding: const EdgeInsets.all(RatelSpacing.sm + 2),
        decoration: BoxDecoration(
          border: Border.all(color: tk.border, width: tk.hairline),
          borderRadius: BorderRadius.circular(tk.radiusMd),
        ),
        child: Row(
          children: <Widget>[
            RatelMedallion(
              icon: Icons.podcasts,
              background: tk.infoBg,
              foreground: tk.info,
              size: 44,
              iconSize: 22,
            ),
            const SizedBox(width: RatelSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text(
                    episode.title,
                    style: TextStyle(
                      color: tk.text,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: <Widget>[
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: RatelSpacing.sm,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: tk.successBg,
                          borderRadius: BorderRadius.circular(tk.radiusPill),
                        ),
                        child: Text(
                          episode.level,
                          style: TextStyle(
                            color: tk.success,
                            fontSize: 9.5,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(width: RatelSpacing.sm),
                      Expanded(
                        child: Text(
                          '${episode.duration} · ${episode.topic}',
                          style: TextStyle(
                            color: tk.textMuted,
                            fontSize: 10.5,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: RatelSpacing.sm),
            Icon(Icons.play_circle_outline, color: tk.primary, size: 26),
          ],
        ),
      ),
    );
  }
}
