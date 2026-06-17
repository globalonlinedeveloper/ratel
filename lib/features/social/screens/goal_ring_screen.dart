import 'package:flutter/material.dart';
import '../../../core/i18n/strings.dart';
import '../../../core/theme/tokens.dart';
import '../../../design_system/components/ratel_button.dart';

/// Goal ring + chest — mock Page-5 · screen 8 (endowed daily-goal ring + daily
/// chest). Design-only (no backend yet).
class GoalRingScreen extends StatelessWidget {
  const GoalRingScreen({super.key});

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
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(RatelSpacing.md, 0, RatelSpacing.md, RatelSpacing.md),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text(S.t('ring_title', 'Daily goal'), style: TextStyle(color: tk.text, fontSize: 15, fontWeight: FontWeight.w600)),
                  const SizedBox(height: RatelSpacing.md),
                  Center(
                    child: SizedBox(
                      width: 120,
                      height: 120,
                      child: Stack(
                        alignment: Alignment.center,
                        children: <Widget>[
                          SizedBox(
                            width: 120,
                            height: 120,
                            child: CircularProgressIndicator(
                              value: 0.6,
                              strokeWidth: 13,
                              backgroundColor: tk.border,
                              valueColor: AlwaysStoppedAnimation<Color>(tk.primary),
                            ),
                          ),
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              Text(S.t('ring_xp', '12'), style: TextStyle(color: tk.text, fontSize: 22, fontWeight: FontWeight.w600)),
                              Text(S.t('ring_goal', '/ 20 XP'), style: TextStyle(color: tk.textMuted, fontSize: 10)),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: RatelSpacing.sm),
                  Center(child: Text(S.t('ring_note', 'starts part-filled (endowed progress)'), style: TextStyle(color: tk.textMuted, fontSize: 10))),
                  const SizedBox(height: RatelSpacing.md),
                  Container(
                    padding: const EdgeInsets.all(RatelSpacing.md),
                    decoration: BoxDecoration(color: tk.warningBg, borderRadius: BorderRadius.circular(tk.radiusLg)),
                    child: Row(
                      children: <Widget>[
                        Icon(Icons.card_giftcard, size: 28, color: tk.brand),
                        const SizedBox(width: RatelSpacing.md),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(S.t('ring_chest', 'Daily chest'), style: TextStyle(color: tk.warning, fontSize: 13, fontWeight: FontWeight.w600)),
                              Text(S.t('ring_chest_sub', 'gems · freeze · XP boost'), style: TextStyle(color: tk.warning, fontSize: 10)),
                            ],
                          ),
                        ),
                        Icon(Icons.chevron_right, size: 18, color: tk.warning),
                      ],
                    ),
                  ),
                  const SizedBox(height: RatelSpacing.md),
                  RatelButton.filled(label: S.t('ring_cta', 'Open chest'), onPressed: () {}),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
