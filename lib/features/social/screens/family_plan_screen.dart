import 'package:flutter/material.dart';
import '../../../core/i18n/strings.dart';
import '../../../core/theme/tokens.dart';
import '../../../design_system/components/ratel_button.dart';

/// Family plan — mock Page-5 · screen 13 (up to 6 members, invite-by-link).
/// Design-only (no backend yet).
class FamilyPlanScreen extends StatelessWidget {
  const FamilyPlanScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final tk = context.tokens;
    Widget member(String initial, Color color, String name, Widget trailing) => Container(
          padding: const EdgeInsets.all(RatelSpacing.sm + 2),
          decoration: BoxDecoration(border: Border.all(color: tk.border, width: tk.hairline), borderRadius: BorderRadius.circular(tk.radiusMd)),
          child: Row(
            children: <Widget>[
              Container(
                width: 30,
                height: 30,
                alignment: Alignment.center,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                child: Text(initial, style: const TextStyle(color: Colors.white, fontSize: 11)),
              ),
              const SizedBox(width: RatelSpacing.sm),
              Expanded(child: Text(name, style: TextStyle(color: tk.text, fontSize: 12))),
              trailing,
            ],
          ),
        );
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Navigator.of(context).canPop()
            ? IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => Navigator.of(context).maybePop())
            : null,
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(RatelSpacing.md, 0, RatelSpacing.md, RatelSpacing.md),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Icon(Icons.favorite_border, size: 20, color: tk.primary),
                      const SizedBox(width: RatelSpacing.sm),
                      Text(S.t('family_title', 'Family'), style: TextStyle(color: tk.text, fontSize: 16, fontWeight: FontWeight.w600)),
                    ],
                  ),
                  const SizedBox(height: RatelSpacing.xs),
                  Text(S.t('family_sub', 'Up to 6 members · everyone keeps their own progress.'), style: TextStyle(color: tk.textMuted, fontSize: 11)),
                  const SizedBox(height: RatelSpacing.md),
                  member('Y', tk.primary, S.t('family_you', 'You · manager'), Icon(Icons.workspace_premium, size: 16, color: tk.brand)),
                  const SizedBox(height: RatelSpacing.sm),
                  member('A', tk.hearts, S.t('family_asha', 'Asha'), Text(S.t('family_active', 'active'), style: TextStyle(color: tk.success, fontSize: 10))),
                  const SizedBox(height: RatelSpacing.sm),
                  Container(
                    padding: const EdgeInsets.all(RatelSpacing.sm + 2),
                    decoration: BoxDecoration(border: Border.all(color: tk.border, width: tk.hairline), borderRadius: BorderRadius.circular(tk.radiusMd)),
                    child: Row(
                      children: <Widget>[
                        Icon(Icons.forward_to_inbox, size: 19, color: tk.textMuted),
                        const SizedBox(width: RatelSpacing.sm),
                        Expanded(child: Text(S.t('family_invite_row', 'Invite by link (they accept)'), style: TextStyle(color: tk.textMuted, fontSize: 12))),
                      ],
                    ),
                  ),
                  const SizedBox(height: RatelSpacing.xs),
                  Text(S.t('family_note', 'no auto-add · 3 seats free'), style: TextStyle(color: tk.textMuted, fontSize: 9)),
                  const SizedBox(height: RatelSpacing.md),
                  RatelButton.filled(label: S.t('family_cta', 'Send invite'), onPressed: () {}),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
