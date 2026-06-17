import 'package:flutter/material.dart';
import '../../../core/i18n/strings.dart';
import '../../../core/theme/tokens.dart';
import '../../../design_system/components/ratel_button.dart';

/// Stories — mock Page-4 · screen 8 (market reading + comprehension).
/// Design-only (no backend/audio yet).
class MarketStoryScreen extends StatefulWidget {
  const MarketStoryScreen({super.key});

  @override
  State<MarketStoryScreen> createState() => _MarketStoryScreenState();
}

class _MarketStoryScreenState extends State<MarketStoryScreen> {
  String _answer = 'Mangoes';

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
                      Expanded(child: Text(S.t('mstory_title', 'At the market'), style: TextStyle(color: tk.text, fontSize: 15, fontWeight: FontWeight.w600))),
                      Text(S.t('mstory_meta', 'A2 · 3 min'), style: TextStyle(color: tk.textMuted, fontSize: 10)),
                    ],
                  ),
                  const SizedBox(height: RatelSpacing.sm),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: RatelSpacing.md, vertical: RatelSpacing.sm),
                            decoration: BoxDecoration(color: tk.surface2, borderRadius: BorderRadius.circular(tk.radiusMd)),
                            child: Row(
                              children: <Widget>[
                                Icon(Icons.play_arrow, size: 17, color: tk.primary),
                                const SizedBox(width: RatelSpacing.sm),
                                Expanded(
                                  child: Text.rich(
                                    TextSpan(
                                      children: <InlineSpan>[
                                        const TextSpan(text: 'He '),
                                        WidgetSpan(
                                          alignment: PlaceholderAlignment.middle,
                                          child: Container(
                                            decoration: BoxDecoration(color: tk.warningBg, borderRadius: BorderRadius.circular(3)),
                                            padding: const EdgeInsets.symmetric(horizontal: 2),
                                            child: Text('bought', style: TextStyle(color: tk.text, fontSize: 12.5)),
                                          ),
                                        ),
                                        const TextSpan(text: ' some fresh fruit.'),
                                      ],
                                      style: TextStyle(color: tk.text, fontSize: 12.5),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: RatelSpacing.xs),
                          Text(S.t('mstory_karaoke', 'karaoke highlight follows the audio · tap a word to define'), style: TextStyle(color: tk.textMuted, fontSize: 9.5)),
                          const SizedBox(height: RatelSpacing.sm),
                          Text(S.t('mstory_body', '"How much for the mangoes?" he asked. The seller smiled, "Fifty rupees a kilo."'), style: TextStyle(color: tk.textMuted, fontSize: 12.5, height: 1.6)),
                          const SizedBox(height: RatelSpacing.md),
                          Container(
                            padding: const EdgeInsets.all(RatelSpacing.sm + 2),
                            decoration: BoxDecoration(border: Border.all(color: tk.border, width: tk.hairline), borderRadius: BorderRadius.circular(tk.radiusMd)),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text(S.t('mstory_q', 'Comprehension: what did he buy?'), style: TextStyle(color: tk.text, fontSize: 11.5, fontWeight: FontWeight.w600)),
                                const SizedBox(height: RatelSpacing.sm),
                                Row(
                                  children: <Widget>[
                                    Expanded(child: _Answer(label: S.t('mstory_a1', 'Mangoes'), selected: _answer == 'Mangoes', onTap: () => setState(() => _answer = 'Mangoes'))),
                                    const SizedBox(width: RatelSpacing.sm),
                                    Expanded(child: _Answer(label: S.t('mstory_a2', 'Bread'), selected: _answer == 'Bread', onTap: () => setState(() => _answer = 'Bread'))),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: RatelSpacing.xs),
                          Row(
                            children: <Widget>[
                              Icon(Icons.auto_awesome, size: 12, color: tk.info),
                              const SizedBox(width: RatelSpacing.xs),
                              Expanded(child: Text(S.t('mstory_ai', 'AI can spin a story from your weak words'), style: TextStyle(color: tk.info, fontSize: 9.5))),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  RatelButton.filled(label: S.t('mstory_cta', 'Continue'), onPressed: () {}),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Answer extends StatelessWidget {
  const _Answer({required this.label, required this.selected, required this.onTap});

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
          height: 36,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            border: Border.all(color: selected ? tk.primary : tk.border, width: selected ? 1.5 : tk.hairline),
            borderRadius: BorderRadius.circular(tk.radiusSm),
          ),
          child: Text(label, style: TextStyle(color: selected ? tk.success : tk.text, fontSize: 11.5)),
        ),
      ),
    );
  }
}
