import 'package:flutter/material.dart';
import '../../../core/i18n/strings.dart';
import '../../../core/theme/tokens.dart';

/// Classroom — mock Page-5 · screen 14 (teacher join-code + roster).
/// Design-only (no backend yet).
class ClassroomScreen extends StatelessWidget {
  const ClassroomScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final tk = context.tokens;
    Widget student(String initial, Color color, String name, double progress, Color barColor, String level) => Container(
          padding: const EdgeInsets.symmetric(horizontal: RatelSpacing.md, vertical: RatelSpacing.sm),
          decoration: BoxDecoration(color: tk.surface2, borderRadius: BorderRadius.circular(tk.radiusMd)),
          child: Row(
            children: <Widget>[
              Container(
                width: 28,
                height: 28,
                alignment: Alignment.center,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                child: Text(initial, style: const TextStyle(color: Colors.white, fontSize: 11)),
              ),
              const SizedBox(width: RatelSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(name, style: TextStyle(color: tk.text, fontSize: 11.5)),
                    const SizedBox(height: 3),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(tk.radiusPill),
                      child: LinearProgressIndicator(value: progress, minHeight: 4, backgroundColor: tk.border, valueColor: AlwaysStoppedAnimation<Color>(barColor)),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: RatelSpacing.sm),
              Text(level, style: TextStyle(color: tk.textMuted, fontSize: 10)),
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
                      Icon(Icons.school_outlined, size: 20, color: tk.info),
                      const SizedBox(width: RatelSpacing.sm),
                      Text(S.t('class_title', 'Classroom'), style: TextStyle(color: tk.text, fontSize: 16, fontWeight: FontWeight.w600)),
                    ],
                  ),
                  const SizedBox(height: RatelSpacing.sm),
                  Container(
                    padding: const EdgeInsets.all(RatelSpacing.md),
                    decoration: BoxDecoration(color: tk.infoBg, borderRadius: BorderRadius.circular(tk.radiusLg)),
                    child: Column(
                      children: <Widget>[
                        Text(S.t('class_code_label', 'JOIN CODE'), style: TextStyle(color: tk.info, fontSize: 10)),
                        Text(S.t('class_code', 'RTL-294'), style: TextStyle(color: tk.info, fontSize: 26, fontWeight: FontWeight.w600, letterSpacing: 3)),
                      ],
                    ),
                  ),
                  const SizedBox(height: RatelSpacing.sm),
                  Text(S.t('class_dash', 'Teacher dashboard'), style: TextStyle(color: tk.textMuted, fontSize: 11, fontWeight: FontWeight.w600)),
                  const SizedBox(height: RatelSpacing.sm),
                  student('P', tk.hearts, S.t('class_s1', 'Priya'), 0.8, tk.primary, 'A2'),
                  const SizedBox(height: RatelSpacing.sm),
                  student('K', tk.info, S.t('class_s2', 'Karan'), 0.45, tk.win, 'A1'),
                  const SizedBox(height: RatelSpacing.xs),
                  Text(S.t('class_note', 'auto progress tracking · 24 students'), style: TextStyle(color: tk.textMuted, fontSize: 9)),
                  const SizedBox(height: RatelSpacing.md),
                  Material(
                    color: tk.info,
                    borderRadius: BorderRadius.circular(tk.radiusMd),
                    clipBehavior: Clip.antiAlias,
                    child: InkWell(
                      onTap: () {},
                      child: Container(
                        height: 44,
                        alignment: Alignment.center,
                        child: Text(S.t('class_cta', 'Manage class'), style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)),
                      ),
                    ),
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
