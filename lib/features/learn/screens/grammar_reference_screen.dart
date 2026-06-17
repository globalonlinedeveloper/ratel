import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/i18n/strings.dart';
import '../../../core/theme/tokens.dart';
import '../../../design_system/components/ratel_medallion.dart';

/// Grammar reference + notebook surface (audit P2-2). A categorized list of
/// grammar topics grouped under section headers; each row opens a topic
/// explainer. Design-only: the reference content is a static `const` list and
/// the "Saved notes" notebook is a sample preview — saving your own notes
/// (real persistence) lands in Phase 3.
class GrammarReferenceScreen extends StatelessWidget {
  const GrammarReferenceScreen({super.key});

  static const List<_Section> _sections = <_Section>[
    _Section('Tenses', <_Topic>[
      _Topic('Present simple', 'Habits, routines and facts', Icons.schedule),
      _Topic('Present continuous', 'Happening right now', Icons.sync),
      _Topic('Past simple', 'Finished actions', Icons.history),
    ]),
    _Section('Articles', <_Topic>[
      _Topic('A / an', 'First mention of a thing', Icons.looks_one_outlined),
      _Topic('The', 'Something specific', Icons.push_pin_outlined),
    ]),
    _Section('Prepositions', <_Topic>[
      _Topic('In / on / at - time', 'When things happen', Icons.event_outlined),
      _Topic('In / on / at - place', 'Where things are', Icons.place_outlined),
    ]),
  ];

  // Notebook is a design-phase sample only (no persistence yet).
  static const List<String> _savedNotes = <String>[
    'Past simple: add -ed to most regular verbs',
    'Use a before consonant sounds, an before vowel sounds',
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
                    S.t('grammar_title', 'Grammar'),
                    style: TextStyle(
                      color: tk.text,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    S.t('grammar_sub', 'Quick reference - rules with examples'),
                    style: TextStyle(color: tk.textMuted, fontSize: 10.5),
                  ),
                  const SizedBox(height: RatelSpacing.md),
                  for (final _Section s in _sections) ...<Widget>[
                    Text(
                      s.title,
                      style: TextStyle(
                        color: tk.textMuted,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: RatelSpacing.xs),
                    for (final _Topic t in s.topics) ...<Widget>[
                      _TopicRow(topic: t),
                      const SizedBox(height: RatelSpacing.sm),
                    ],
                    const SizedBox(height: RatelSpacing.xs),
                  ],
                  const SizedBox(height: RatelSpacing.sm),
                  Row(
                    children: <Widget>[
                      Icon(Icons.bookmark_outline, size: 15, color: tk.info),
                      const SizedBox(width: 5),
                      Text(
                        S.t('grammar_notebook', 'Saved notes'),
                        style: TextStyle(
                          color: tk.text,
                          fontSize: 12.5,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    S.t(
                      'grammar_notebook_sample',
                      'Sample preview - saving your own notes lands soon',
                    ),
                    style: TextStyle(color: tk.textMuted, fontSize: 9.5),
                  ),
                  const SizedBox(height: RatelSpacing.sm),
                  for (final String note in _savedNotes) ...<Widget>[
                    _NoteRow(text: note),
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

class _Section {
  const _Section(this.title, this.topics);

  final String title;
  final List<_Topic> topics;
}

class _Topic {
  const _Topic(this.title, this.summary, this.icon);

  final String title;
  final String summary;
  final IconData icon;
}

class _TopicRow extends StatelessWidget {
  const _TopicRow({required this.topic});

  final _Topic topic;

  @override
  Widget build(BuildContext context) {
    final tk = context.tokens;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => context.push('/grammar/topic'),
      child: Container(
        padding: const EdgeInsets.all(RatelSpacing.sm + 2),
        decoration: BoxDecoration(
          border: Border.all(color: tk.border, width: tk.hairline),
          borderRadius: BorderRadius.circular(tk.radiusMd),
        ),
        child: Row(
          children: <Widget>[
            RatelMedallion(
              icon: topic.icon,
              background: tk.infoBg,
              foreground: tk.info,
              size: 38,
              iconSize: 19,
            ),
            const SizedBox(width: RatelSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text(
                    topic.title,
                    style: TextStyle(
                      color: tk.text,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    topic.summary,
                    style: TextStyle(color: tk.textMuted, fontSize: 10.5),
                  ),
                ],
              ),
            ),
            const SizedBox(width: RatelSpacing.sm),
            Icon(Icons.chevron_right, size: 20, color: tk.textMuted),
          ],
        ),
      ),
    );
  }
}

class _NoteRow extends StatelessWidget {
  const _NoteRow({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final tk = context.tokens;
    return Container(
      padding: const EdgeInsets.all(RatelSpacing.sm + 2),
      decoration: BoxDecoration(
        color: tk.surface2,
        borderRadius: BorderRadius.circular(tk.radiusMd),
      ),
      child: Row(
        children: <Widget>[
          Icon(Icons.sticky_note_2_outlined, size: 16, color: tk.info),
          const SizedBox(width: RatelSpacing.sm),
          Expanded(
            child: Text(
              text,
              style: TextStyle(color: tk.text, fontSize: 11.5, height: 1.4),
            ),
          ),
        ],
      ),
    );
  }
}
