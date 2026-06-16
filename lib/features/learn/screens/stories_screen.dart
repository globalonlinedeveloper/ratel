import 'package:flutter/material.dart';
import '../../../core/i18n/strings.dart';
import '../../../core/theme/tokens.dart';
import '../../../design_system/components/ratel_button.dart';

/// Stories / reading — mock Page-3 · screen 10 (karaoke text + comprehension).
/// Design-only (no backend/audio yet).
class StoriesScreen extends StatefulWidget {
  const StoriesScreen({super.key});

  @override
  State<StoriesScreen> createState() => _StoriesScreenState();
}

class _StoriesScreenState extends State<StoriesScreen> {
  String _answer = 'Coffee';

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
                      Expanded(
                        child: Text(
                          S.t('story_title', 'At the café'),
                          style: TextStyle(color: tk.text, fontSize: 14, fontWeight: FontWeight.w600),
                        ),
                      ),
                      Text(
                        S.t('story_meta', 'A2 · 2 min'),
                        style: TextStyle(color: tk.textMuted, fontSize: 10),
                      ),
                    ],
                  ),
                  const SizedBox(height: RatelSpacing.sm),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: RatelSpacing.md,
                              vertical: RatelSpacing.sm,
                            ),
                            decoration: BoxDecoration(
                              color: tk.surface2,
                              borderRadius: BorderRadius.circular(tk.radiusMd),
                            ),
                            child: Row(
                              children: <Widget>[
                                Icon(Icons.volume_up, size: 17, color: tk.primary),
                                const SizedBox(width: RatelSpacing.sm),
                                Expanded(
                                  child: Text.rich(
                                    TextSpan(
                                      children: <InlineSpan>[
                                        const TextSpan(text: 'She walked '),
                                        WidgetSpan(
                                          alignment: PlaceholderAlignment.middle,
                                          child: Container(
                                            decoration: BoxDecoration(
                                              color: tk.warningBg,
                                              borderRadius: BorderRadius.circular(3),
                                            ),
                                            padding: const EdgeInsets.symmetric(horizontal: 2),
                                            child: Text('into', style: TextStyle(color: tk.text, fontSize: 12.5)),
                                          ),
                                        ),
                                        const TextSpan(text: ' the café…'),
                                      ],
                                      style: TextStyle(color: tk.text, fontSize: 12.5),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: RatelSpacing.xs),
                          Text(
                            S.t('story_karaoke', 'karaoke highlight syncs with audio · tap a word to define'),
                            style: TextStyle(color: tk.textMuted, fontSize: 9.5),
                          ),
                          const SizedBox(height: RatelSpacing.sm),
                          Text(
                            S.t('story_body', '"What would you like?" asked the waiter. She smiled and said, "A coffee, please."'),
                            style: TextStyle(color: tk.textMuted, fontSize: 12.5, height: 1.6),
                          ),
                          const SizedBox(height: RatelSpacing.md),
                          Container(
                            padding: const EdgeInsets.all(RatelSpacing.md),
                            decoration: BoxDecoration(
                              border: Border.all(color: tk.border, width: tk.hairline),
                              borderRadius: BorderRadius.circular(tk.radiusMd),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text(
                                  S.t('story_q', 'What did she order?'),
                                  style: TextStyle(color: tk.text, fontSize: 12, fontWeight: FontWeight.w600),
                                ),
                                const SizedBox(height: RatelSpacing.sm),
                                Row(
                                  children: <Widget>[
                                    Expanded(
                                      child: _AnswerBox(
                                        label: S.t('story_a1', 'Coffee'),
                                        selected: _answer == 'Coffee',
                                        onTap: () => setState(() => _answer = 'Coffee'),
                                      ),
                                    ),
                                    const SizedBox(width: RatelSpacing.sm),
                                    Expanded(
                                      child: _AnswerBox(
                                        label: S.t('story_a2', 'Tea'),
                                        selected: _answer == 'Tea',
                                        onTap: () => setState(() => _answer = 'Tea'),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  RatelButton.filled(
                    label: S.t('story_cta', 'Continue'),
                    onPressed: () {},
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

/// A small selectable answer box (Coffee / Tea).
class _AnswerBox extends StatelessWidget {
  const _AnswerBox({required this.label, required this.selected, required this.onTap});

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final tk = context.tokens;
    return Material(
      color: selected ? tk.successBg : Colors.transparent,
      borderRadius: BorderRadius.circular(tk.radiusSm),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(tk.radiusSm),
        child: Container(
          height: 38,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            border: Border.all(
              color: selected ? tk.primary : tk.border,
              width: selected ? 1.5 : tk.hairline,
            ),
            borderRadius: BorderRadius.circular(tk.radiusSm),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: selected ? tk.success : tk.text,
              fontSize: 12,
            ),
          ),
        ),
      ),
    );
  }
}
