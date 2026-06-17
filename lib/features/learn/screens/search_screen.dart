import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/i18n/strings.dart';
import '../../../core/theme/tokens.dart';
import '../../../design_system/components/ratel_choice_chip.dart';
import '../../../design_system/components/ratel_empty_state.dart';
import '../../../design_system/components/ratel_field.dart';
import '../../../design_system/components/ratel_medallion.dart';

/// Global search (`/search`) — a design-phase search surface across lessons,
/// stories, words and skills. Typing filters an in-memory `const` corpus
/// (honest stub; real federated/FTS search lands Phase 2 content / Phase 3 DB).
/// Empty query shows Recent + Suggested chips; a miss shows a no-results state.
class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _controller = TextEditingController();
  String _query = '';

  static const List<_Result> _corpus = <_Result>[
    _Result('Everyday phrases', _Kind.lesson, Icons.menu_book, '/lesson/choice'),
    _Result('Ordering coffee', _Kind.lesson, Icons.menu_book, '/lesson/choice'),
    _Result('Past tense basics', _Kind.lesson, Icons.menu_book, '/lesson/choice'),
    _Result('Travel small talk', _Kind.lesson, Icons.menu_book, '/lesson/choice'),
    _Result('At the market', _Kind.story, Icons.auto_stories, '/stories'),
    _Result('A train journey', _Kind.story, Icons.auto_stories, '/stories'),
    _Result('Coffee shop chatter', _Kind.story, Icons.auto_stories, '/stories'),
    _Result('commute', _Kind.word, Icons.translate, '/stories'),
    _Result('reservation', _Kind.word, Icons.translate, '/stories'),
    _Result('itinerary', _Kind.word, Icons.translate, '/stories'),
    _Result('Pronunciation', _Kind.skill, Icons.graphic_eq, '/practice'),
    _Result('Listening', _Kind.skill, Icons.headphones, '/listen'),
    _Result('Verb agreement', _Kind.skill, Icons.spellcheck, '/practice/smart'),
  ];

  static const List<String> _suggested = <String>[
    'Greetings',
    'Past tense',
    'Travel',
    'Food',
    'Numbers',
  ];
  static const List<String> _recent = <String>['coffee', 'verbs'];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _setQuery(String q) {
    _controller.text = q;
    _controller.selection = TextSelection.collapsed(offset: q.length);
    setState(() => _query = q);
  }

  List<_Result> get _matches {
    final String q = _query.trim().toLowerCase();
    if (q.isEmpty) return const <_Result>[];
    return _corpus
        .where(
          (_Result r) =>
              r.label.toLowerCase().contains(q) ||
              r.kind.label.toLowerCase().contains(q),
        )
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final tk = context.tokens;
    final bool empty = _query.trim().isEmpty;
    final List<_Result> matches = _matches;
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
                    S.t('search_title', 'Search'),
                    style: TextStyle(
                      color: tk.text,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: RatelSpacing.sm),
                  RatelField(
                    controller: _controller,
                    hint: S.t('search_hint', 'Search lessons, stories, words…'),
                    keyboardType: TextInputType.text,
                    textInputAction: TextInputAction.search,
                    onChanged: (String v) => setState(() => _query = v),
                  ),
                  const SizedBox(height: RatelSpacing.md),
                  if (empty)
                    _suggestions(tk)
                  else if (matches.isEmpty)
                    RatelEmptyState(
                      icon: Icons.search_off,
                      title: S.t('search_no_title', 'No matches'),
                      message:
                          '${S.t('search_no_msg', 'Nothing found for')} "${_query.trim()}".',
                    )
                  else
                    for (final _Result r in matches) ...<Widget>[
                      _ResultRow(result: r),
                      const SizedBox(height: 4),
                    ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _suggestions(RatelTokens tk) {
    Widget section(String title, List<String> chips) => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          title,
          style: TextStyle(
            color: tk.textMuted,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: RatelSpacing.sm),
        Wrap(
          spacing: RatelSpacing.sm,
          runSpacing: RatelSpacing.sm,
          children: <Widget>[
            for (final String c in chips)
              RatelChoiceChip(
                label: c,
                selected: false,
                onTap: () => _setQuery(c),
              ),
          ],
        ),
      ],
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        section(S.t('search_recent', 'Recent'), _recent),
        const SizedBox(height: RatelSpacing.md),
        section(S.t('search_suggested', 'Suggested'), _suggested),
      ],
    );
  }
}

enum _Kind {
  lesson('Lesson'),
  story('Story'),
  word('Word'),
  skill('Skill');

  const _Kind(this.label);
  final String label;
}

class _Result {
  const _Result(this.label, this.kind, this.icon, this.route);
  final String label;
  final _Kind kind;
  final IconData icon;
  final String route;
}

class _ResultRow extends StatelessWidget {
  const _ResultRow({required this.result});

  final _Result result;

  @override
  Widget build(BuildContext context) {
    final tk = context.tokens;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(tk.radiusMd),
        onTap: () => context.push(result.route),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: RatelSpacing.sm,
            vertical: RatelSpacing.sm,
          ),
          child: Row(
            children: <Widget>[
              RatelMedallion(
                icon: result.icon,
                background: tk.surface2,
                foreground: tk.info,
                size: 38,
                iconSize: 19,
              ),
              const SizedBox(width: RatelSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      result.label,
                      style: TextStyle(
                        color: tk.text,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      result.kind.label,
                      style: TextStyle(color: tk.textMuted, fontSize: 11),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, size: 18, color: tk.textMuted),
            ],
          ),
        ),
      ),
    );
  }
}
