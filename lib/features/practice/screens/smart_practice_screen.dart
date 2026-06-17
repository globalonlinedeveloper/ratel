import 'package:flutter/material.dart';
import '../../../core/i18n/strings.dart';
import '../../../core/theme/tokens.dart';
import '../../../design_system/components/ratel_button.dart';

/// Smart practice — mock Page-4 · screen 2 (worst-first weak-skill queue).
/// Design-only (no backend yet).
class SmartPracticeScreen extends StatelessWidget {
  const SmartPracticeScreen({super.key});

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
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(RatelSpacing.md, 0, RatelSpacing.md, RatelSpacing.md),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text(S.t('smart_title', 'Smart practice'), style: TextStyle(color: tk.text, fontSize: 17, fontWeight: FontWeight.w600)),
                  const SizedBox(height: RatelSpacing.xs),
                  Text(S.t('smart_sub', 'Worst-first, from your weak skills & due reviews. No energy at risk.'), style: TextStyle(color: tk.textMuted, fontSize: 11)),
                  const SizedBox(height: RatelSpacing.md),
                  _SkillRow(color: tk.coral, name: S.t('smart_s1', 'Verb agreement'), detail: S.t('smart_s1d', 'mastery 38% · 6 items due')),
                  const SizedBox(height: RatelSpacing.sm),
                  _SkillRow(color: tk.brand, name: S.t('smart_s2', 'Café vocabulary'), detail: S.t('smart_s2d', 'mastery 55% · 4 items due')),
                  const SizedBox(height: RatelSpacing.sm),
                  _SkillRow(color: tk.success, name: S.t('smart_s3', 'Listening · numbers'), detail: S.t('smart_s3d', 'mastery 71% · 2 items due')),
                  const SizedBox(height: RatelSpacing.sm),
                  Row(
                    children: <Widget>[
                      Icon(Icons.psychology_outlined, size: 13, color: tk.textMuted),
                      const SizedBox(width: RatelSpacing.xs),
                      Expanded(
                        child: Text(S.t('smart_engine', 'FSRS-6 + knowledge tracing pick the order'), style: TextStyle(color: tk.textMuted, fontSize: 9.5)),
                      ),
                    ],
                  ),
                  const SizedBox(height: RatelSpacing.md),
                  RatelButton.filled(label: S.t('smart_cta', 'Start · 12 items'), onPressed: () {}),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// A weak-skill row: a coloured alert dot + name + mastery detail.
class _SkillRow extends StatelessWidget {
  const _SkillRow({required this.color, required this.name, required this.detail});

  final Color color;
  final String name;
  final String detail;

  @override
  Widget build(BuildContext context) {
    final tk = context.tokens;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: RatelSpacing.md, vertical: RatelSpacing.sm + 2),
      decoration: BoxDecoration(color: tk.surface2, borderRadius: BorderRadius.circular(tk.radiusLg - 2)),
      child: Row(
        children: <Widget>[
          Icon(Icons.error_outline, size: 17, color: color),
          const SizedBox(width: RatelSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(name, style: TextStyle(color: tk.text, fontSize: 12)),
                Text(detail, style: TextStyle(color: tk.textMuted, fontSize: 10)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
