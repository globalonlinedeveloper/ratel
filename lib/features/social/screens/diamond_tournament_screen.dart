import 'package:flutter/material.dart';
import '../../../core/i18n/strings.dart';
import '../../../core/theme/tokens.dart';
import '../../../design_system/components/ratel_button.dart';
import '../../../design_system/components/ratel_medallion.dart';

/// Diamond tournament — mock Page-5 · screen 10 (multi-week bracket).
/// Design-only (no backend yet).
class DiamondTournamentScreen extends StatelessWidget {
  const DiamondTournamentScreen({super.key});

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
                  Center(child: RatelMedallion(icon: Icons.emoji_events, background: tk.infoBg, foreground: tk.info, size: 60, iconSize: 32)),
                  const SizedBox(height: RatelSpacing.md),
                  Text(S.t('tourn_title', 'Diamond Tournament'), textAlign: TextAlign.center, style: TextStyle(color: tk.text, fontSize: 17, fontWeight: FontWeight.w600)),
                  const SizedBox(height: RatelSpacing.xs),
                  Text(S.t('tourn_sub', 'Top Diamond players compete over 3 weeks. Top 10 advance each round.'), textAlign: TextAlign.center, style: TextStyle(color: tk.textMuted, fontSize: 11, height: 1.5)),
                  const SizedBox(height: RatelSpacing.md),
                  _Round(icon: Icons.check_circle, iconColor: tk.success, label: S.t('tourn_r1', 'Quarter-final'), status: S.t('tourn_r1s', 'advanced'), statusColor: tk.success, border: false),
                  const SizedBox(height: RatelSpacing.sm),
                  _Round(icon: Icons.play_arrow, iconColor: tk.info, label: S.t('tourn_r2', 'Semi-final · rank 6'), status: S.t('tourn_r2s', 'live'), statusColor: tk.info, border: true),
                  const SizedBox(height: RatelSpacing.sm),
                  _Round(icon: Icons.lock_outline, iconColor: tk.textMuted, label: S.t('tourn_r3', 'Final'), status: '', statusColor: tk.textMuted, border: false),
                  const SizedBox(height: RatelSpacing.md),
                  RatelButton.filled(label: S.t('tourn_cta', 'Compete now'), onPressed: () {}),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Round extends StatelessWidget {
  const _Round({required this.icon, required this.iconColor, required this.label, required this.status, required this.statusColor, required this.border});

  final IconData icon;
  final Color iconColor;
  final String label;
  final String status;
  final Color statusColor;
  final bool border;

  @override
  Widget build(BuildContext context) {
    final tk = context.tokens;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: RatelSpacing.md, vertical: RatelSpacing.sm),
      decoration: BoxDecoration(
        color: border ? Colors.transparent : tk.surface2,
        border: border ? Border.all(color: tk.info, width: 1.5) : null,
        borderRadius: BorderRadius.circular(tk.radiusSm),
      ),
      child: Row(
        children: <Widget>[
          Icon(icon, size: 16, color: iconColor),
          const SizedBox(width: RatelSpacing.sm),
          Expanded(child: Text(label, style: TextStyle(color: status.isEmpty ? tk.textMuted : tk.text, fontSize: 11.5))),
          if (status.isNotEmpty) Text(status, style: TextStyle(color: statusColor, fontSize: 10)),
        ],
      ),
    );
  }
}
