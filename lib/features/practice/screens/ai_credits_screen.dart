import 'package:flutter/material.dart';
import '../../../core/i18n/strings.dart';
import '../../../core/theme/tokens.dart';
import '../../../design_system/components/ratel_medallion.dart';

/// AI credits — mock Page-4 · screen 13 (daily AI budget spent, keep free or go
/// Super). Design-only (no backend/monetization yet).
class AiCreditsScreen extends StatelessWidget {
  const AiCreditsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final tk = context.tokens;
    return Scaffold(
      backgroundColor: tk.surface2,
      body: SafeArea(
        child: Column(
          children: <Widget>[
            const Spacer(),
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: tk.surface,
                border: Border(top: BorderSide(color: tk.border, width: tk.hairline)),
                borderRadius: BorderRadius.vertical(top: Radius.circular(tk.radiusLg + 4)),
              ),
              padding: const EdgeInsets.fromLTRB(RatelSpacing.lg, RatelSpacing.lg, RatelSpacing.lg, RatelSpacing.xl),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 440),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Center(
                        child: Container(
                          width: 36,
                          height: 4,
                          decoration: BoxDecoration(color: tk.border, borderRadius: BorderRadius.circular(tk.radiusPill)),
                        ),
                      ),
                      const SizedBox(height: RatelSpacing.md),
                      Center(
                        child: Column(
                          children: <Widget>[
                            RatelMedallion(icon: Icons.auto_awesome, background: tk.infoBg, foreground: tk.info, size: 52, iconSize: 28),
                            const SizedBox(height: RatelSpacing.sm),
                            Text(S.t('credits_title', "You've used today's AI"), style: TextStyle(color: tk.text, fontSize: 16, fontWeight: FontWeight.w600)),
                            const SizedBox(height: RatelSpacing.xs),
                            Text(S.t('credits_sub', 'Voice & AI feedback reset in 5h 20m.'), textAlign: TextAlign.center, style: TextStyle(color: tk.textMuted, fontSize: 11)),
                          ],
                        ),
                      ),
                      const SizedBox(height: RatelSpacing.md),
                      Row(
                        children: <Widget>[
                          for (int i = 0; i < 5; i++)
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 2),
                                child: Container(
                                  height: 6,
                                  decoration: BoxDecoration(color: tk.info, borderRadius: BorderRadius.circular(tk.radiusPill)),
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: RatelSpacing.md),
                      Container(
                        padding: const EdgeInsets.all(RatelSpacing.md),
                        decoration: BoxDecoration(border: Border.all(color: tk.primary, width: 1.5), borderRadius: BorderRadius.circular(tk.radiusMd)),
                        child: Row(
                          children: <Widget>[
                            Icon(Icons.keyboard_alt_outlined, size: 18, color: tk.primary),
                            const SizedBox(width: RatelSpacing.sm),
                            Expanded(child: Text(S.t('credits_free', 'Keep practising free (text & review)'), style: TextStyle(color: tk.success, fontSize: 12.5))),
                          ],
                        ),
                      ),
                      const SizedBox(height: RatelSpacing.sm),
                      Material(
                        color: tk.win,
                        borderRadius: BorderRadius.circular(tk.radiusMd),
                        clipBehavior: Clip.antiAlias,
                        child: InkWell(
                          onTap: () {},
                          child: Container(
                            height: 44,
                            alignment: Alignment.center,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Icon(Icons.all_inclusive, size: 16, color: tk.text),
                                const SizedBox(width: RatelSpacing.sm),
                                Flexible(
                                  child: Text(S.t('credits_super', 'Unlimited AI with Super'),
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(color: tk.text, fontSize: 13, fontWeight: FontWeight.w600)),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: RatelSpacing.sm),
                      Text(
                        S.t('credits_note', 'AI is disclosed · voice processed on-device where possible · no raw-speech kept'),
                        textAlign: TextAlign.center,
                        style: TextStyle(color: tk.textMuted, fontSize: 9),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
