import 'package:flutter/material.dart';
import '../../../core/i18n/strings.dart';
import '../../../core/theme/tokens.dart';
import '../../../design_system/components/ratel_button.dart';
import '../../../design_system/components/ratel_medallion.dart';

/// Referral hub — mock Page-6 · screen 15 (invite friends, WhatsApp-first).
/// Design-only (no backend yet).
class ReferralHubScreen extends StatelessWidget {
  const ReferralHubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final tk = context.tokens;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Navigator.of(context).canPop()
            ? IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => Navigator.of(context).maybePop())
            : null,
      ),
      body: SafeArea(
        child: Align(alignment: Alignment.topCenter,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(RatelSpacing.md, 0, RatelSpacing.md, RatelSpacing.md),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Center(child: RatelMedallion(icon: Icons.card_giftcard, background: tk.successBg, foreground: tk.success)),
                  const SizedBox(height: RatelSpacing.md),
                  Text(S.t('ref_title', 'Invite friends, earn gems'), textAlign: TextAlign.center, style: TextStyle(color: tk.text, fontSize: 17, fontWeight: FontWeight.w600)),
                  const SizedBox(height: RatelSpacing.xs),
                  Text(S.t('ref_sub', 'You both get 500 gems when a friend finishes their first lesson.'), textAlign: TextAlign.center, style: TextStyle(color: tk.textMuted, fontSize: 12, height: 1.5)),
                  const SizedBox(height: RatelSpacing.md),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: RatelSpacing.md, vertical: RatelSpacing.sm),
                    decoration: BoxDecoration(border: Border.all(color: tk.border, width: tk.hairline), borderRadius: BorderRadius.circular(tk.radiusMd)),
                    child: Row(
                      children: <Widget>[
                        Expanded(child: Text(S.t('ref_link', 'ratel.app/r/RAJ7K'), style: TextStyle(color: tk.textMuted, fontSize: 12))),
                        Icon(Icons.copy, size: 16, color: tk.primary),
                      ],
                    ),
                  ),
                  const SizedBox(height: RatelSpacing.md),
                  RatelButton.filled(icon: Icons.chat, label: S.t('ref_share', 'Share on WhatsApp'), onPressed: () {}),
                  const SizedBox(height: RatelSpacing.sm),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Text(S.t('ref_invited', 'Invited 3'), style: TextStyle(color: tk.textMuted, fontSize: 10)),
                      Text(S.t('ref_joined', 'Joined 2'), style: TextStyle(color: tk.textMuted, fontSize: 10)),
                      Text(S.t('ref_earned', '+1,000 gems'), style: TextStyle(color: tk.textMuted, fontSize: 10)),
                    ],
                  ),
                  const SizedBox(height: RatelSpacing.sm),
                  Text(S.t('ref_note', "reward on referee's first action · WhatsApp-first for India"), style: TextStyle(color: tk.textMuted, fontSize: 9)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
