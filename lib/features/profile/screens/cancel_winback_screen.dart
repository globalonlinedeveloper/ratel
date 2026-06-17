import 'package:flutter/material.dart';
import '../../../core/i18n/strings.dart';
import '../../../core/theme/tokens.dart';
import '../../../design_system/components/ratel_button.dart';

/// Cancel / win-back — mock Page-6 · screen 13 (easy-cancel, honest offer).
/// Design-only (no backend yet).
class CancelWinbackScreen extends StatelessWidget {
  const CancelWinbackScreen({super.key});

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
                  Text(S.t('cancel_title', 'Before you go'), style: TextStyle(color: tk.text, fontSize: 15, fontWeight: FontWeight.w600)),
                  const SizedBox(height: RatelSpacing.md),
                  Container(
                    padding: const EdgeInsets.all(RatelSpacing.md),
                    decoration: BoxDecoration(color: tk.warningBg, borderRadius: BorderRadius.circular(tk.radiusLg)),
                    child: Column(
                      children: <Widget>[
                        Icon(Icons.local_offer_outlined, size: 28, color: tk.brand),
                        const SizedBox(height: RatelSpacing.xs),
                        Text(S.t('cancel_offer', 'Stay for 50% off 3 months?'), textAlign: TextAlign.center, style: TextStyle(color: tk.warning, fontSize: 13, fontWeight: FontWeight.w600)),
                        Text(S.t('cancel_offer_sub', 'one-time offer · no tricks'), style: TextStyle(color: tk.warning, fontSize: 10)),
                      ],
                    ),
                  ),
                  const SizedBox(height: RatelSpacing.md),
                  RatelButton.filled(label: S.t('cancel_keep', 'Keep Super at 50% off'), onPressed: () {}),
                  const SizedBox(height: RatelSpacing.sm),
                  RatelButton.neutral(label: S.t('cancel_anyway', 'Cancel anyway'), onPressed: () {}),
                  const SizedBox(height: RatelSpacing.sm),
                  Text(S.t('cancel_note', 'Both choices equally easy (no maze). Cancelling stops the RBI auto-debit; you keep Super until 30 Jun 2026.'), style: TextStyle(color: tk.textMuted, fontSize: 9.5, height: 1.5)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
