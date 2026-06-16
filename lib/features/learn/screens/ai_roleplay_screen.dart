import 'package:flutter/material.dart';
import '../../../core/i18n/strings.dart';
import '../../../core/theme/tokens.dart';

/// AI roleplay — mock Page-3 · screen 4 (café scenario chat, disclosed AI
/// tutor). Design-only (no backend/LLM yet).
class AiRoleplayScreen extends StatelessWidget {
  const AiRoleplayScreen({super.key});

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
              padding: const EdgeInsets.fromLTRB(
                RatelSpacing.md,
                0,
                RatelSpacing.md,
                RatelSpacing.md,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Container(
                        width: 34,
                        height: 34,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(color: tk.warningBg, shape: BoxShape.circle),
                        child: Icon(Icons.coffee, size: 18, color: tk.brand),
                      ),
                      const SizedBox(width: RatelSpacing.sm),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            S.t('roleplay_title', 'Café roleplay'),
                            style: TextStyle(color: tk.text, fontSize: 13, fontWeight: FontWeight.w600),
                          ),
                          Text(
                            S.t('roleplay_sub', 'order a drink · AI adapts'),
                            style: TextStyle(color: tk.textMuted, fontSize: 10),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: RatelSpacing.md),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
                          _Bubble(
                            text: S.t('roleplay_ai1', 'Hi! What can I get you today?'),
                            fromAi: true,
                          ),
                          const SizedBox(height: RatelSpacing.sm),
                          _Bubble(
                            text: S.t('roleplay_user1', "I'd like a coffee, please."),
                            fromAi: false,
                          ),
                          const SizedBox(height: RatelSpacing.xs),
                          Align(
                            alignment: Alignment.centerRight,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                Icon(Icons.check_circle, size: 13, color: tk.success),
                                const SizedBox(width: RatelSpacing.xs),
                                Text(
                                  S.t('roleplay_feedback', 'great phrasing'),
                                  style: TextStyle(color: tk.success, fontSize: 10),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: RatelSpacing.md,
                      vertical: RatelSpacing.sm,
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(color: tk.border, width: tk.hairline),
                      borderRadius: BorderRadius.circular(tk.radiusPill),
                    ),
                    child: Row(
                      children: <Widget>[
                        Icon(Icons.mic, size: 18, color: tk.primary),
                        const SizedBox(width: RatelSpacing.sm),
                        Expanded(
                          child: Text(
                            S.t('roleplay_input', 'Speak or type your reply…'),
                            style: TextStyle(color: tk.textMuted, fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: RatelSpacing.sm),
                  Row(
                    children: <Widget>[
                      Icon(Icons.auto_awesome, size: 12, color: tk.textMuted),
                      const SizedBox(width: RatelSpacing.xs),
                      Expanded(
                        child: Text(
                          S.t('roleplay_disclosure', 'AI tutor · disclosed · rate-limited · free since 2026'),
                          style: TextStyle(color: tk.textMuted, fontSize: 9),
                        ),
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
}

/// A chat bubble — AI (left, neutral) or learner (right, success tint).
class _Bubble extends StatelessWidget {
  const _Bubble({required this.text, required this.fromAi});

  final String text;
  final bool fromAi;

  @override
  Widget build(BuildContext context) {
    final tk = context.tokens;
    return Align(
      alignment: fromAi ? Alignment.centerLeft : Alignment.centerRight,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 280),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: RatelSpacing.md,
            vertical: RatelSpacing.sm,
          ),
          decoration: BoxDecoration(
            color: fromAi ? tk.surface2 : tk.successBg,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(fromAi ? 3 : tk.radiusLg),
              topRight: Radius.circular(fromAi ? tk.radiusLg : 3),
              bottomLeft: Radius.circular(tk.radiusLg),
              bottomRight: Radius.circular(tk.radiusLg),
            ),
          ),
          child: Text(
            text,
            style: TextStyle(
              color: fromAi ? tk.text : tk.success,
              fontSize: 12.5,
            ),
          ),
        ),
      ),
    );
  }
}
