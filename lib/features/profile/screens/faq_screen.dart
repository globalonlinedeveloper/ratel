import 'package:flutter/material.dart';
import '../../../core/i18n/strings.dart';
import '../../../core/theme/tokens.dart';

/// FAQ / help-centre (`/faq`) — mock Page-6. Self-authored Q&A (design-phase
/// stub content; no legal sign-off needed). Token-pure question/answer Text
/// pairs separated by hairline dividers.
class FaqScreen extends StatelessWidget {
  const FaqScreen({super.key});

  static const List<List<String>> _qa = <List<String>>[
    <String>[
      'faq_q1', 'How do streaks work?',
      'faq_a1',
      'Practice any day to keep your streak. Miss a day and a streak freeze can save it.',
    ],
    <String>[
      'faq_q2', 'What is energy?',
      'faq_a2',
      'Lessons use energy; it refills over time or with gems — never with real money pressure.',
    ],
    <String>[
      'faq_q3', 'Can I learn offline?',
      'faq_a3', 'Offline mode is coming soon.',
    ],
    <String>[
      'faq_q4', 'How do I manage my subscription?',
      'faq_a4', 'Open Settings → Account, or your app-store subscriptions.',
    ],
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
                    S.t('faq_title', 'Help centre'),
                    style: TextStyle(
                      color: tk.text,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: RatelSpacing.sm),
                  for (final List<String> qa in _qa) ...<Widget>[
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: RatelSpacing.sm,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            S.t(qa[0], qa[1]),
                            style: TextStyle(
                              color: tk.text,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: RatelSpacing.xs),
                          Text(
                            S.t(qa[2], qa[3]),
                            style: TextStyle(
                              color: tk.textMuted,
                              fontSize: 12,
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Divider(color: tk.border, height: tk.hairline),
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
