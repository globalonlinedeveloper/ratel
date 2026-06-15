import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

/// Phase 2.3 — renders [text] with each WORD individually tappable (a dotted
/// underline hints it). Tapping a word calls [onWord] with the cleaned word
/// (letters only) so the caller can offer hear + picture + meaning. Whitespace
/// and punctuation render normally and are not tappable. Tap recognizers are
/// rebuilt on each build and disposed with the widget — no leak.
class WordTapText extends StatefulWidget {
  const WordTapText(this.text, {super.key, this.style, required this.onWord});

  final String text;
  final TextStyle? style;
  final void Function(String word) onWord;

  @override
  State<WordTapText> createState() => _WordTapTextState();
}

class _WordTapTextState extends State<WordTapText> {
  final List<TapGestureRecognizer> _recognizers = [];

  void _clear() {
    for (final r in _recognizers) {
      r.dispose();
    }
    _recognizers.clear();
  }

  @override
  void dispose() {
    _clear();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _clear();
    final spans = <InlineSpan>[];
    widget.text.splitMapJoin(
      RegExp(r'\s+'),
      onMatch: (m) {
        spans.add(TextSpan(text: m[0]));
        return '';
      },
      onNonMatch: (chunk) {
        if (chunk.isEmpty) return '';
        final clean = chunk.replaceAll(RegExp(r'[^A-Za-z]'), '');
        if (clean.isEmpty) {
          spans.add(TextSpan(text: chunk));
          return '';
        }
        final r = TapGestureRecognizer()..onTap = () => widget.onWord(clean);
        _recognizers.add(r);
        spans.add(TextSpan(
          text: chunk,
          recognizer: r,
          style: const TextStyle(
            decoration: TextDecoration.underline,
            decorationStyle: TextDecorationStyle.dotted,
          ),
        ));
        return '';
      },
    );
    return Text.rich(TextSpan(style: widget.style, children: spans));
  }
}
