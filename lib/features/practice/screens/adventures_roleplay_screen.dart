import 'package:flutter/material.dart';
import '../../../core/i18n/strings.dart';
import '../../../core/theme/tokens.dart';
import '../../../design_system/components/ratel_button.dart';

/// Adventures roleplay — mock Page-4 · screen 9 (scenario branching + end-of-
/// scene scorecard). Design-only (no backend/LLM yet).
class AdventuresRoleplayScreen extends StatefulWidget {
  const AdventuresRoleplayScreen({super.key});

  @override
  State<AdventuresRoleplayScreen> createState() => _AdventuresRoleplayScreenState();
}

class _AdventuresRoleplayScreenState extends State<AdventuresRoleplayScreen> {
  int _reply = 0;

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
                  Text(S.t('adv_title', 'Job interview'), style: TextStyle(color: tk.text, fontSize: 15, fontWeight: FontWeight.w600)),
                  const SizedBox(height: RatelSpacing.sm),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 300),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: RatelSpacing.md, vertical: RatelSpacing.sm),
                        decoration: BoxDecoration(
                          color: tk.surface2,
                          borderRadius: BorderRadius.only(
                            topLeft: const Radius.circular(3),
                            topRight: Radius.circular(tk.radiusLg),
                            bottomLeft: Radius.circular(tk.radiusLg),
                            bottomRight: Radius.circular(tk.radiusLg),
                          ),
                        ),
                        child: Text(S.t('adv_prompt', '"So, why do you want this job?"'), style: TextStyle(color: tk.text, fontSize: 12)),
                      ),
                    ),
                  ),
                  const SizedBox(height: RatelSpacing.sm),
                  Text(S.t('adv_choose', 'Choose your reply:'), style: TextStyle(color: tk.textMuted, fontSize: 11)),
                  const SizedBox(height: RatelSpacing.sm),
                  _Reply(label: S.t('adv_r1', '"I\'m passionate about this field and eager to grow."'), selected: _reply == 0, onTap: () => setState(() => _reply = 0)),
                  const SizedBox(height: RatelSpacing.sm),
                  _Reply(label: S.t('adv_r2', '"I need the money."'), selected: _reply == 1, onTap: () => setState(() => _reply = 1)),
                  const SizedBox(height: RatelSpacing.sm),
                  _Reply(label: S.t('adv_r3', 'Say it your own way'), selected: _reply == 2, onTap: () => setState(() => _reply = 2), trailingIcon: Icons.mic),
                  const SizedBox(height: RatelSpacing.sm),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: RatelSpacing.md, vertical: RatelSpacing.sm),
                    decoration: BoxDecoration(color: tk.surface2, borderRadius: BorderRadius.circular(tk.radiusMd)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(S.t('adv_scorecard', 'END-OF-SCENE SCORECARD'), style: TextStyle(color: tk.textMuted, fontSize: 10)),
                        const SizedBox(height: RatelSpacing.xs),
                        Wrap(
                          spacing: RatelSpacing.sm,
                          children: <Widget>[
                            Text(S.t('adv_acc', 'Accuracy 90%'), style: TextStyle(color: tk.success, fontSize: 10)),
                            Text(S.t('adv_vocab', 'Vocab variety 7'), style: TextStyle(color: tk.info, fontSize: 10)),
                            Text(S.t('adv_flu', 'Fluency B1'), style: TextStyle(color: tk.hearts, fontSize: 10)),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: RatelSpacing.md),
                  RatelButton.filled(label: S.t('adv_cta', 'Reply'), onPressed: () {}),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Reply extends StatelessWidget {
  const _Reply({required this.label, required this.selected, required this.onTap, this.trailingIcon});

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final IconData? trailingIcon;

  @override
  Widget build(BuildContext context) {
    final tk = context.tokens;
    return Material(
      color: selected ? tk.successBg : Colors.transparent,
      borderRadius: BorderRadius.circular(tk.radiusLg - 2),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(tk.radiusLg - 2),
        child: Container(
          padding: const EdgeInsets.all(RatelSpacing.sm + 2),
          decoration: BoxDecoration(
            border: Border.all(color: selected ? tk.primary : tk.border, width: selected ? 1.5 : tk.hairline),
            borderRadius: BorderRadius.circular(tk.radiusLg - 2),
          ),
          child: Row(
            children: <Widget>[
              Expanded(child: Text(label, style: TextStyle(color: selected ? tk.success : tk.text, fontSize: 12))),
              if (trailingIcon != null) ...<Widget>[
                const SizedBox(width: RatelSpacing.sm),
                Icon(trailingIcon, size: 14, color: tk.textMuted),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
