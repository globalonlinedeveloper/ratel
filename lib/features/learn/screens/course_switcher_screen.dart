import 'package:flutter/material.dart';
import '../../../core/i18n/strings.dart';
import '../../../core/theme/tokens.dart';
import '../../../design_system/components/ratel_button.dart';
import '../../../design_system/components/ratel_option_tile.dart';

/// Course switcher — mock Page-3 · screen 12 (multi-target, each course keeps
/// its own progress). Design-only (no backend yet).
class CourseSwitcherScreen extends StatefulWidget {
  const CourseSwitcherScreen({super.key});

  @override
  State<CourseSwitcherScreen> createState() => _CourseSwitcherScreenState();
}

class _CourseSwitcherScreenState extends State<CourseSwitcherScreen> {
  String _course = 'English';

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
            padding: const EdgeInsets.fromLTRB(
              RatelSpacing.md,
              0,
              RatelSpacing.md,
              RatelSpacing.md,
            ),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text(
                    S.t('course_title', 'My courses'),
                    style: TextStyle(color: tk.text, fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: RatelSpacing.xs),
                  Text(
                    S.t('course_sub', 'Learn several languages — each keeps its own streak & progress.'),
                    style: TextStyle(color: tk.textMuted, fontSize: 11),
                  ),
                  const SizedBox(height: RatelSpacing.md),
                  RatelOptionTile(
                    leadingIcon: Icons.flag,
                    title: S.t('course_en', 'English'),
                    subtitle: S.t('course_en_sub', 'A2 · 7-day streak'),
                    selected: _course == 'English',
                    onTap: () => setState(() => _course = 'English'),
                  ),
                  const SizedBox(height: RatelSpacing.sm),
                  RatelOptionTile(
                    leadingIcon: Icons.flag,
                    title: S.t('course_es', 'Spanish'),
                    subtitle: S.t('course_es_sub', 'A1 · just started'),
                    selected: _course == 'Spanish',
                    onTap: () => setState(() => _course = 'Spanish'),
                  ),
                  const SizedBox(height: RatelSpacing.sm),
                  Material(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(tk.radiusMd),
                    child: InkWell(
                      onTap: () {},
                      borderRadius: BorderRadius.circular(tk.radiusMd),
                      child: Container(
                        padding: const EdgeInsets.all(RatelSpacing.md),
                        decoration: BoxDecoration(
                          border: Border.all(color: tk.border, width: tk.hairline),
                          borderRadius: BorderRadius.circular(tk.radiusMd),
                        ),
                        child: Row(
                          children: <Widget>[
                            Icon(Icons.add, size: 19, color: tk.textMuted),
                            const SizedBox(width: RatelSpacing.md),
                            Text(
                              S.t('course_add', 'Add a language'),
                              style: TextStyle(color: tk.textMuted, fontSize: 12.5),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: RatelSpacing.sm),
                  Row(
                    children: <Widget>[
                      Icon(Icons.wifi_off, size: 13, color: tk.textMuted),
                      const SizedBox(width: RatelSpacing.xs),
                      Expanded(
                        child: Text(
                          S.t('course_offline', 'offline mode · data-light · cross-device sync'),
                          style: TextStyle(color: tk.textMuted, fontSize: 9),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: RatelSpacing.md),
                  RatelButton.filled(
                    label: S.t('course_cta', 'Continue English'),
                    onPressed: () {},
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
