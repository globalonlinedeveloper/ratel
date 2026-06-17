import 'package:flutter/material.dart';
import '../../../core/i18n/strings.dart';
import '../../../core/theme/tokens.dart';
import '../../../content/word_definitions.dart';
import '../../../design_system/components/ratel_button.dart';
import '../../../design_system/components/ratel_define_sheet.dart';

/// Video lesson — mock Page-4 · screen 10 (interactive-subtitle clip + quiz).
/// Design-only (no backend/video yet). Subtitle words are tap-to-define.
class VideoLessonScreen extends StatefulWidget {
  const VideoLessonScreen({super.key});

  @override
  State<VideoLessonScreen> createState() => _VideoLessonScreenState();
}

class _VideoLessonScreenState extends State<VideoLessonScreen> {
  String _answer = 'Train';

  void _define(String word) {
    final Map<String, String>? d = lookupWord(word);
    RatelDefineSheet.show(
      context,
      word: word,
      partOfSpeech: d?['pos'],
      definition: d?['definition'],
      example: d?['example'],
    );
  }

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
                  Stack(
                    alignment: Alignment.center,
                    children: <Widget>[
                      Container(
                        height: 130,
                        decoration: BoxDecoration(color: tk.text, borderRadius: BorderRadius.circular(tk.radiusMd)),
                      ),
                      const Icon(Icons.play_arrow, size: 40, color: Colors.white),
                      Positioned(
                        bottom: 6,
                        right: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(4)),
                          child: const Text('1.0×', style: TextStyle(color: Colors.white, fontSize: 9)),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: RatelSpacing.sm),
                  Text.rich(
                    TextSpan(
                      children: <InlineSpan>[
                        const TextSpan(text: '"I\'ll '),
                        _hl(tk, S.t('video_w1', 'take')),
                        const TextSpan(text: ' the '),
                        _hl(tk, S.t('video_w2', 'train')),
                        const TextSpan(text: ' to work."'),
                      ],
                      style: TextStyle(color: tk.text, fontSize: 13, height: 1.5),
                    ),
                  ),
                  const SizedBox(height: RatelSpacing.xs),
                  Text(S.t('video_hint', 'tap any subtitle word → definition · audio · add to flashcards'), style: TextStyle(color: tk.textMuted, fontSize: 9.5)),
                  const SizedBox(height: RatelSpacing.sm),
                  Container(
                    padding: const EdgeInsets.all(RatelSpacing.sm + 2),
                    decoration: BoxDecoration(border: Border.all(color: tk.border, width: tk.hairline), borderRadius: BorderRadius.circular(tk.radiusMd)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(S.t('video_q', 'Quiz: how does he travel?'), style: TextStyle(color: tk.text, fontSize: 11.5, fontWeight: FontWeight.w600)),
                        const SizedBox(height: RatelSpacing.sm),
                        Row(
                          children: <Widget>[
                            Expanded(child: _Opt(label: S.t('video_a1', 'Train'), selected: _answer == 'Train', onTap: () => setState(() => _answer = 'Train'))),
                            const SizedBox(width: RatelSpacing.sm),
                            Expanded(child: _Opt(label: S.t('video_a2', 'Bus'), selected: _answer == 'Bus', onTap: () => setState(() => _answer = 'Bus'))),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: RatelSpacing.md),
                  RatelButton.filled(label: S.t('video_cta', 'Next clip'), onPressed: () {}),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  InlineSpan _hl(RatelTokens tk, String word) => WidgetSpan(
        alignment: PlaceholderAlignment.middle,
        child: GestureDetector(
          onTap: () => _define(word),
          child: Container(
            decoration: BoxDecoration(color: tk.successBg, borderRadius: BorderRadius.circular(3)),
            padding: const EdgeInsets.symmetric(horizontal: 2),
            child: Text(word, style: TextStyle(color: tk.success, fontSize: 13)),
          ),
        ),
      );
}

class _Opt extends StatelessWidget {
  const _Opt({required this.label, required this.selected, required this.onTap});

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
