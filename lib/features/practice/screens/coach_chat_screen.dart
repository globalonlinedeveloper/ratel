import 'package:flutter/material.dart';
import '../../../core/i18n/strings.dart';
import '../../../core/theme/tokens.dart';

/// Coach chat — mock Page-4 · screen 4 (AI tutor chat with quick prompts).
/// Design-only (no backend/LLM yet).
class CoachChatScreen extends StatelessWidget {
  const CoachChatScreen({super.key});

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
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 440),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(RatelSpacing.md, 0, RatelSpacing.md, RatelSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Container(
                        width: 32,
                        height: 32,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(color: tk.warningBg, shape: BoxShape.circle),
                        child: Icon(Icons.sentiment_satisfied_alt, size: 18, color: tk.brand),
                      ),
                      const SizedBox(width: RatelSpacing.sm),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(S.t('coach_name', 'Coach'),
                                style: TextStyle(color: tk.text, fontSize: 13, fontWeight: FontWeight.w600)),
                            Text(S.t('coach_sub', 'AI tutor · remembers your sessions'),
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(color: tk.textMuted, fontSize: 9)),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: RatelSpacing.md),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
                          _bubble(tk, S.t('coach_ai1', 'Want to review past tense, or free chat today?'), fromAi: true),
                          const SizedBox(height: RatelSpacing.sm),
                          _bubble(tk, S.t('coach_user1', 'Why is it "went" not "goed"?'), fromAi: false),
                          const SizedBox(height: RatelSpacing.sm),
                          Wrap(
                            spacing: RatelSpacing.sm,
                            runSpacing: RatelSpacing.xs,
                            children: <Widget>[
                              _chip(tk, S.t('coach_c1', 'Explain a word')),
                              _chip(tk, S.t('coach_c2', 'Roleplay')),
                              _chip(tk, S.t('coach_c3', 'Quiz me')),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: RatelSpacing.md, vertical: RatelSpacing.sm),
                    decoration: BoxDecoration(
                      border: Border.all(color: tk.border, width: tk.hairline),
                      borderRadius: BorderRadius.circular(tk.radiusPill),
                    ),
                    child: Row(
                      children: <Widget>[
                        Expanded(child: Text(S.t('coach_input', 'Message…'), style: TextStyle(color: tk.textMuted, fontSize: 12))),
                        Icon(Icons.mic, size: 17, color: tk.primary),
                      ],
                    ),
                  ),
                  const SizedBox(height: RatelSpacing.xs),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Flexible(
                        child: Text(S.t('coach_disclosure', 'AI · may be imperfect'),
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(color: tk.textMuted, fontSize: 9)),
                      ),
                      const SizedBox(width: RatelSpacing.sm),
                      Flexible(
                        child: Text(S.t('coach_saved', 'new words saved to review'),
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.right,
                            style: TextStyle(color: tk.textMuted, fontSize: 9)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _bubble(RatelTokens tk, String text, {required bool fromAi}) => Align(
        alignment: fromAi ? Alignment.centerLeft : Alignment.centerRight,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 290),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: RatelSpacing.md, vertical: RatelSpacing.sm),
            decoration: BoxDecoration(
              color: fromAi ? tk.surface2 : tk.successBg,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(fromAi ? 3 : tk.radiusLg),
                topRight: Radius.circular(fromAi ? tk.radiusLg : 3),
                bottomLeft: Radius.circular(tk.radiusLg),
                bottomRight: Radius.circular(tk.radiusLg),
              ),
            ),
            child: Text(text, style: TextStyle(color: fromAi ? tk.text : tk.success, fontSize: 12)),
          ),
        ),
      );

  Widget _chip(RatelTokens tk, String label) => Container(
        padding: const EdgeInsets.symmetric(horizontal: RatelSpacing.md, vertical: 5),
        decoration: BoxDecoration(
          border: Border.all(color: tk.border, width: tk.hairline),
          borderRadius: BorderRadius.circular(tk.radiusPill),
        ),
        child: Text(label, style: TextStyle(color: tk.text, fontSize: 10.5)),
      );
}
