import 'package:flutter/material.dart';
import '../../../core/i18n/strings.dart';
import '../../../core/theme/tokens.dart';
import '../../../design_system/components/ratel_toggle_row.dart';

/// Accessibility — mock Page-6 · screen 6 (text size slider + a11y toggles).
/// Design-only (no backend yet).
class AccessibilityScreen extends StatefulWidget {
  const AccessibilityScreen({super.key});

  @override
  State<AccessibilityScreen> createState() => _AccessibilityScreenState();
}

class _AccessibilityScreenState extends State<AccessibilityScreen> {
  double _textSize = 0.55;
  bool _contrast = true;
  bool _motion = true;
  bool _dyslexia = false;
  bool _captions = true;
  bool _noTime = false;

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
                  Text(S.t('a11y_title', 'Accessibility'), style: TextStyle(color: tk.text, fontSize: 15, fontWeight: FontWeight.w600)),
                  const SizedBox(height: RatelSpacing.md),
                  Text(S.t('a11y_textsize', 'Text size'), style: TextStyle(color: tk.text, fontSize: 12)),
                  Slider(value: _textSize, onChanged: (double v) => setState(() => _textSize = v)),
                  const SizedBox(height: RatelSpacing.sm),
                  RatelToggleRow(label: S.t('a11y_contrast', 'Increase contrast'), value: _contrast, onChanged: (bool v) => setState(() => _contrast = v)),
                  const SizedBox(height: RatelSpacing.md),
                  RatelToggleRow(label: S.t('a11y_motion', 'Reduce motion'), value: _motion, onChanged: (bool v) => setState(() => _motion = v)),
                  const SizedBox(height: RatelSpacing.md),
                  RatelToggleRow(label: S.t('a11y_dyslexia', 'Dyslexia-friendly font'), value: _dyslexia, onChanged: (bool v) => setState(() => _dyslexia = v)),
                  const SizedBox(height: RatelSpacing.md),
                  RatelToggleRow(label: S.t('a11y_captions', 'Captions on audio'), value: _captions, onChanged: (bool v) => setState(() => _captions = v)),
                  const SizedBox(height: RatelSpacing.md),
                  RatelToggleRow(label: S.t('a11y_notime', 'No-time-pressure mode'), value: _noTime, onChanged: (bool v) => setState(() => _noTime = v)),
                  const SizedBox(height: RatelSpacing.md),
                  Text(S.t('a11y_note', 'WCAG 2.2 AA / EAA · EN 301 549'), style: TextStyle(color: tk.textMuted, fontSize: 9)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
