import 'package:flutter/material.dart';
import '../../../core/i18n/strings.dart';
import '../../../core/theme/tokens.dart';

/// Shared legal-document layout (Terms, Privacy Policy). Renders a visible
/// "Draft — pending legal review" banner so placeholder copy can NEVER be
/// mistaken for finalized terms. [sections] are `[heading, body]` pairs (the
/// caller resolves them via `S.t`). Tokens only.
class LegalDocView extends StatelessWidget {
  const LegalDocView({super.key, required this.title, required this.sections});

  final String title;
  final List<List<String>> sections;

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
        child: Align(
          alignment: Alignment.topCenter,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(
              RatelSpacing.md,
              0,
              RatelSpacing.md,
              RatelSpacing.xl,
            ),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text(
                    title,
                    style: TextStyle(
                      color: tk.text,
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: RatelSpacing.sm),
                  Container(
                    padding: const EdgeInsets.all(RatelSpacing.md),
                    decoration: BoxDecoration(
                      color: tk.warningBg,
                      borderRadius: BorderRadius.circular(tk.radiusMd),
                    ),
                    child: Text(
                      S.t(
                        'legal_draft',
                        'Draft — placeholder text pending legal review. Not the final agreement.',
                      ),
                      style: TextStyle(
                        color: tk.warning,
                        fontSize: 11,
                        height: 1.4,
                      ),
                    ),
                  ),
                  const SizedBox(height: RatelSpacing.sm),
                  Text(
                    S.t('legal_updated', 'Last updated: —'),
                    style: TextStyle(color: tk.textMuted, fontSize: 10),
                  ),
                  const SizedBox(height: RatelSpacing.md),
                  for (final List<String> sec in sections) ...<Widget>[
                    Text(
                      sec[0],
                      style: TextStyle(
                        color: tk.text,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: RatelSpacing.xs),
                    Text(
                      sec[1],
                      style: TextStyle(
                        color: tk.textMuted,
                        fontSize: 12,
                        height: 1.6,
                      ),
                    ),
                    const SizedBox(height: RatelSpacing.md),
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
