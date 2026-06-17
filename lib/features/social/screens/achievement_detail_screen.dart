import 'package:flutter/material.dart';
import '../../../core/i18n/strings.dart';
import '../../../core/theme/tokens.dart';
import '../../../design_system/components/ratel_button.dart';
import '../../../design_system/components/ratel_medallion.dart';

/// Achievement detail — mock Page-5 · screen 5 (single award + progress).
/// Design-only (no backend yet).
class AchievementDetailScreen extends StatelessWidget {
  const AchievementDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final tk = context.tokens;
    return Scaffold(
      backgroundColor: tk.surface2,
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
            padding: const EdgeInsets.all(RatelSpacing.lg),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 360),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: RatelSpacing.lg, vertical: RatelSpacing.xl),
                decoration: BoxDecoration(
                  color: tk.surface,
                  border: Border.all(color: tk.border, width: tk.hairline),
                  borderRadius: BorderRadius.circular(tk.radiusLg + 6),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    RatelMedallion(icon: Icons.local_fire_department, background: tk.warningBg, foreground: tk.brand, size: 84, iconSize: 44, cornerRadius: 20),
                    const SizedBox(height: RatelSpacing.md),
                    Text(S.t('achd_title', 'Wildfire'), style: TextStyle(color: tk.text, fontSize: 17, fontWeight: FontWeight.w600)),
                    const SizedBox(height: RatelSpacing.xs),
                    Text(S.t('achd_sub', "Reach a 14-day streak. You're on a roll!"), textAlign: TextAlign.center, style: TextStyle(color: tk.textMuted, fontSize: 11)),
                    const SizedBox(height: RatelSpacing.md),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Text(S.t('achd_tier_from', 'Silver'), style: TextStyle(color: tk.textMuted, fontSize: 10)),
                        Text(S.t('achd_tier_to', 'Gold · 7/10 days'), style: TextStyle(color: tk.textMuted, fontSize: 10)),
                      ],
                    ),
                    const SizedBox(height: 4),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(tk.radiusPill),
                      child: LinearProgressIndicator(value: 0.7, minHeight: 7, backgroundColor: tk.border, valueColor: AlwaysStoppedAnimation<Color>(tk.win)),
                    ),
                    const SizedBox(height: RatelSpacing.md),
                    RatelButton.filled(label: S.t('achd_cta', 'Share'), onPressed: () {}),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
