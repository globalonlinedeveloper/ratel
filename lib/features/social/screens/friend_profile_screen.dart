import 'package:flutter/material.dart';
import '../../../core/i18n/strings.dart';
import '../../../core/theme/tokens.dart';
import '../../../design_system/components/ratel_button.dart';

/// Friend profile — mock Page-5 · screen 12 (pseudonymous, with block/report).
/// Design-only (no backend yet).
class FriendProfileScreen extends StatelessWidget {
  const FriendProfileScreen({super.key});

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
                  Center(
                    child: Container(
                      width: 70,
                      height: 70,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(color: tk.hearts, shape: BoxShape.circle),
                      child: const Text('A', style: TextStyle(color: Colors.white, fontSize: 30)),
                    ),
                  ),
                  const SizedBox(height: RatelSpacing.sm),
                  Center(child: Text(S.t('fprof_name', 'asha_learns'), style: TextStyle(color: tk.text, fontSize: 17, fontWeight: FontWeight.w600))),
                  Center(child: Text(S.t('fprof_meta', 'pseudonymous · joined 2025'), style: TextStyle(color: tk.textMuted, fontSize: 11))),
                  const SizedBox(height: RatelSpacing.md),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      _Stat(value: '30', label: S.t('fprof_streak', 'streak'), color: tk.coral),
                      const SizedBox(width: RatelSpacing.lg),
                      _Stat(value: '8.2k', label: S.t('fprof_xp', 'XP'), color: tk.brand),
                      const SizedBox(width: RatelSpacing.lg),
                      _Stat(value: 'Gold', label: S.t('fprof_league', 'league'), color: tk.info),
                    ],
                  ),
                  const SizedBox(height: RatelSpacing.md),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: RatelSpacing.md, vertical: RatelSpacing.sm),
                    decoration: BoxDecoration(color: tk.warningBg, borderRadius: BorderRadius.circular(tk.radiusMd)),
                    child: Row(
                      children: <Widget>[
                        Icon(Icons.local_fire_department, size: 18, color: tk.coral),
                        const SizedBox(width: RatelSpacing.sm),
                        Expanded(child: Text(S.t('fprof_friendstreak', '12-day friend streak with you'), style: TextStyle(color: tk.warning, fontSize: 11.5))),
                      ],
                    ),
                  ),
                  const SizedBox(height: RatelSpacing.md),
                  RatelButton.filled(label: S.t('fprof_kudos', 'Send kudos'), onPressed: () {}),
                  const SizedBox(height: RatelSpacing.sm),
                  Row(
                    children: <Widget>[
                      Expanded(child: RatelButton.neutral(icon: Icons.block, label: S.t('fprof_block', 'Block'), onPressed: () {})),
                      const SizedBox(width: RatelSpacing.sm),
                      Expanded(child: RatelButton.neutral(icon: Icons.flag_outlined, label: S.t('fprof_report', 'Report'), onPressed: () {})),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.value, required this.label, required this.color});

  final String value;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final tk = context.tokens;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Text(value, style: TextStyle(color: color, fontSize: 16, fontWeight: FontWeight.w600)),
        Text(label, style: TextStyle(color: tk.textMuted, fontSize: 9)),
      ],
    );
  }
}
