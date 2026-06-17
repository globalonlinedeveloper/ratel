import 'package:flutter/material.dart';
import '../../core/i18n/strings.dart';
import '../../core/theme/tokens.dart';
import 'ratel_button.dart';

/// Tap-to-define bottom sheet: word + part-of-speech + definition + example,
/// with stubbed audio + add-to-flashcards actions (design-phase). Present it
/// via [RatelDefineSheet.show]. Styled like the logout sheet; tokens only.
class RatelDefineSheet extends StatelessWidget {
  const RatelDefineSheet({
    super.key,
    required this.word,
    this.partOfSpeech,
    this.definition,
    this.example,
  });

  final String word;
  final String? partOfSpeech;
  final String? definition;
  final String? example;

  static Future<void> show(
    BuildContext context, {
    required String word,
    String? partOfSpeech,
    String? definition,
    String? example,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => RatelDefineSheet(
        word: word,
        partOfSpeech: partOfSpeech,
        definition: definition,
        example: example,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tk = context.tokens;
    return SafeArea(
      child: Container(
        decoration: BoxDecoration(
          color: tk.surface,
          borderRadius:
              BorderRadius.vertical(top: Radius.circular(tk.radiusLg + 4)),
          border: Border(top: BorderSide(color: tk.border, width: tk.hairline)),
        ),
        padding: const EdgeInsets.fromLTRB(
          RatelSpacing.lg,
          RatelSpacing.md,
          RatelSpacing.lg,
          RatelSpacing.xl,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: tk.border,
                  borderRadius: BorderRadius.circular(tk.radiusPill),
                ),
              ),
            ),
            const SizedBox(height: RatelSpacing.md),
            Row(
              children: <Widget>[
                Flexible(
                  child: Text(
                    word,
                    style: TextStyle(
                      color: tk.text,
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                if (partOfSpeech != null) ...<Widget>[
                  const SizedBox(width: RatelSpacing.sm),
                  Text(
                    partOfSpeech!,
                    style: TextStyle(
                      color: tk.textMuted,
                      fontSize: 11,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
                const Spacer(),
                IconButton(
                  icon: Icon(Icons.volume_up, color: tk.primary),
                  onPressed: () {},
                  tooltip: S.t('define_audio', 'Play audio'),
                ),
              ],
            ),
            const SizedBox(height: RatelSpacing.xs),
            Text(
              definition ?? S.t('define_none', 'Definition coming soon.'),
              style: TextStyle(color: tk.text, fontSize: 13, height: 1.5),
            ),
            if (example != null) ...<Widget>[
              const SizedBox(height: RatelSpacing.md),
              Container(
                padding: const EdgeInsets.all(RatelSpacing.md),
                decoration: BoxDecoration(
                  color: tk.surface2,
                  borderRadius: BorderRadius.circular(tk.radiusMd),
                ),
                child: Text(
                  '“${example!}”',
                  style: TextStyle(
                    color: tk.textMuted,
                    fontSize: 12,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            ],
            const SizedBox(height: RatelSpacing.md),
            RatelButton.neutral(
              icon: Icons.bookmark_add_outlined,
              label: S.t('define_flashcard', 'Add to flashcards'),
              onPressed: () {},
            ),
          ],
        ),
      ),
    );
  }
}
