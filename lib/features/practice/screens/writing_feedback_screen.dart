import 'package:flutter/material.dart';
import '../../../core/i18n/strings.dart';
import '../../../core/theme/tokens.dart';
import '../../../design_system/components/ratel_button.dart';

/// Writing feedback — mock Page-4 · screen 12 (AI redline of a short text).
/// Design-only (no backend/LLM yet).
class WritingFeedbackScreen extends StatelessWidget {
  const WritingFeedbackScreen({super.key});

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
        child: Align(alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 440),
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(RatelSpacing.md, 0, RatelSpacing.md, RatelSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Text(S.t('write_title', 'Write about your weekend'), style: TextStyle(color: tk.text, fontSize: 15, fontWeight: FontWeight.w600)),
                  const SizedBox(height: RatelSpacing.sm),
                  Container(
                    padding: const EdgeInsets.all(RatelSpacing.md),
                    decoration: BoxDecoration(border: Border.all(color: tk.border, width: tk.hairline), borderRadius: BorderRadius.circular(tk.radiusMd)),
                    child: Text.rich(
                      TextSpan(
                        children: <TextSpan>[
                          const TextSpan(text: 'On Saturday I '),
                          TextSpan(text: 'go', style: TextStyle(color: tk.danger, decoration: TextDecoration.lineThrough, decorationColor: tk.danger)),
                          const TextSpan(text: ' '),
                          TextSpan(text: 'went', style: TextStyle(color: tk.primary)),
                          const TextSpan(text: ' to the market and '),
                          TextSpan(text: 'buyed', style: TextStyle(color: tk.danger, decoration: TextDecoration.lineThrough, decorationColor: tk.danger)),
                          const TextSpan(text: ' '),
                          TextSpan(text: 'bought', style: TextStyle(color: tk.primary)),
                          const TextSpan(text: ' some fruit.'),
                        ],
                        style: TextStyle(color: tk.text, fontSize: 12.5, height: 1.7),
                      ),
                    ),
                  ),
                  const SizedBox(height: RatelSpacing.sm),
                  Container(
                    padding: const EdgeInsets.all(RatelSpacing.sm + 2),
                    decoration: BoxDecoration(color: tk.successBg, borderRadius: BorderRadius.circular(tk.radiusSm)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Row(
                          children: <Widget>[
                            Icon(Icons.auto_awesome, size: 14, color: tk.success),
                            const SizedBox(width: RatelSpacing.xs),
                            Text(S.t('write_redline', 'AI redline · 2 fixes'), style: TextStyle(color: tk.success, fontSize: 11, fontWeight: FontWeight.w600)),
                          ],
                        ),
                        const SizedBox(height: 3),
                        Text(S.t('write_redline_body', 'Both are past-tense verbs. More natural: "I headed to the market."'), style: TextStyle(color: tk.success, fontSize: 10.5)),
                      ],
                    ),
                  ),
                  const SizedBox(height: RatelSpacing.sm),
                  Wrap(
                    spacing: RatelSpacing.md,
                    children: <Widget>[
                      Text(S.t('write_grammar', 'Grammar 8/10'), style: TextStyle(color: tk.success, fontSize: 10)),
                      Text(S.t('write_range', 'Range 7/10'), style: TextStyle(color: tk.info, fontSize: 10)),
                      Text(S.t('write_cefr', 'CEFR B1'), style: TextStyle(color: tk.hearts, fontSize: 10)),
                    ],
                  ),
                  const SizedBox(height: RatelSpacing.md),
                  RatelButton.filled(label: S.t('write_cta', 'Rewrite with tips'), onPressed: () {}),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
