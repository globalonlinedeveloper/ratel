import 'package:flutter/material.dart';
import '../../../core/i18n/strings.dart';
import '../../../core/theme/tokens.dart';
import '../../../design_system/components/ratel_button.dart';

/// Grammar topic explainer (audit P2-2). A single rule card with worked
/// examples (the key word highlighted, like the Stories reader) plus a
/// "Save to notebook" action. Design-only: the topic content is static and
/// "Save" is a stub — the saved notebook persists in Phase 3.
class GrammarTopicScreen extends StatelessWidget {
  const GrammarTopicScreen({super.key});

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
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: Text(
                          S.t('grammar_topic_title', 'Present simple'),
                          style: TextStyle(
                            color: tk.text,
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: RatelSpacing.sm,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: tk.infoBg,
                          borderRadius: BorderRadius.circular(tk.radiusPill),
                        ),
                        child: Text(
                          S.t('grammar_topic_tag', 'Tenses'),
                          style: TextStyle(
                            color: tk.info,
                            fontSize: 9.5,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: RatelSpacing.md),
                  Container(
                    padding: const EdgeInsets.all(RatelSpacing.md),
                    decoration: BoxDecoration(
                      color: tk.surface2,
                      borderRadius: BorderRadius.circular(tk.radiusMd),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Row(
                          children: <Widget>[
                            Icon(
                              Icons.lightbulb_outline,
                              size: 16,
                              color: tk.info,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              S.t('grammar_rule_label', 'The rule'),
                              style: TextStyle(
                                color: tk.text,
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: RatelSpacing.xs),
                        Text(
                          S.t(
                            'grammar_rule_body',
                            'Use the present simple for habits, routines and '
                                'facts. Add -s for he, she or it.',
                          ),
                          style: TextStyle(
                            color: tk.textMuted,
                            fontSize: 12,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: RatelSpacing.md),
                  Text(
                    S.t('grammar_examples_label', 'Examples'),
                    style: TextStyle(
                      color: tk.textMuted,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: RatelSpacing.sm),
                  const _Example(
                    before: 'I ',
                    keyword: 'drink',
                    after: ' coffee every morning.',
                  ),
                  const SizedBox(height: RatelSpacing.sm),
                  const _Example(
                    before: 'She ',
                    keyword: 'works',
                    after: ' at a hospital.',
                  ),
                  const SizedBox(height: RatelSpacing.sm),
                  const _Example(
                    before: 'Water ',
                    keyword: 'boils',
                    after: ' at 100 degrees.',
                  ),
                  const SizedBox(height: RatelSpacing.md),
                  RatelButton.outline(
                    label: S.t('grammar_save', 'Save to notebook'),
                    icon: Icons.bookmark_add_outlined,
                    onPressed: () {},
                  ),
                  const SizedBox(height: RatelSpacing.sm),
                  Text(
                    S.t(
                      'grammar_save_note',
                      'Design preview - saved notes sync in a later update',
                    ),
                    textAlign: TextAlign.center,
                    style: TextStyle(color: tk.textMuted, fontSize: 9.5),
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

class _Example extends StatelessWidget {
  const _Example({
    required this.before,
    required this.keyword,
    required this.after,
  });

  final String before;
  final String keyword;
  final String after;

  @override
  Widget build(BuildContext context) {
    final tk = context.tokens;
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: RatelSpacing.md,
        vertical: RatelSpacing.sm,
      ),
      decoration: BoxDecoration(
        border: Border.all(color: tk.border, width: tk.hairline),
        borderRadius: BorderRadius.circular(tk.radiusMd),
      ),
      child: Text.rich(
        TextSpan(
          children: <InlineSpan>[
            TextSpan(text: before),
            WidgetSpan(
              alignment: PlaceholderAlignment.middle,
              child: Container(
                decoration: BoxDecoration(
                  color: tk.warningBg,
                  borderRadius: BorderRadius.circular(3),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 3,
                  vertical: 1,
                ),
                child: Text(
                  keyword,
                  style: TextStyle(
                    color: tk.text,
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            TextSpan(text: after),
          ],
          style: TextStyle(color: tk.text, fontSize: 12.5, height: 1.5),
        ),
      ),
    );
  }
}
