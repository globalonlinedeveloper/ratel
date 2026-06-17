import 'package:flutter/material.dart';
import '../../../core/i18n/strings.dart';
import '../../../core/state/app_settings.dart';
import '../../../core/state/app_settings_scope.dart';
import '../../../core/theme/tokens.dart';
import '../../../design_system/components/ratel_toggle_row.dart';

/// Accessibility — mock Page-6 · screen 6. Six controls bound to [AppSettings]
/// (persisted, app-wide). textScale + reduce-motion + contrast + dyslexia-font
/// take effect immediately (via A11yMediaQuery + theme); captions +
/// no-time-pressure persist for the media/timer screens to consume.
class AccessibilityScreen extends StatelessWidget {
  const AccessibilityScreen({super.key});

  // slider 0..1 <-> textScale 0.85..1.6
  static const double _minScale = 0.85;
  static const double _maxScale = 1.6;
  static double _toScale(double v) => _minScale + v * (_maxScale - _minScale);
  static double _toSlider(double scale) =>
      ((scale - _minScale) / (_maxScale - _minScale)).clamp(0.0, 1.0);

  @override
  Widget build(BuildContext context) {
    final tk = context.tokens;
    final AppSettings settings = AppSettingsScope.of(context);
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
                  Text(S.t('a11y_title', 'Accessibility'), style: TextStyle(color: tk.text, fontSize: 15, fontWeight: FontWeight.w600)),
                  const SizedBox(height: RatelSpacing.md),
                  Text(S.t('a11y_textsize', 'Text size'), style: TextStyle(color: tk.text, fontSize: 12)),
                  Slider(
                    key: const Key('a11y.slider.textsize'),
                    value: _toSlider(settings.textScale),
                    onChanged: (double v) => AppSettingsScope.read(context).setTextScale(_toScale(v)),
                  ),
                  const SizedBox(height: RatelSpacing.sm),
                  RatelToggleRow(label: S.t('a11y_contrast', 'Increase contrast'), value: settings.highContrast, onChanged: (bool v) => AppSettingsScope.read(context).setHighContrast(v), switchKey: const Key('a11y.toggle.contrast')),
                  const SizedBox(height: RatelSpacing.md),
                  RatelToggleRow(label: S.t('a11y_motion', 'Reduce motion'), value: settings.reduceMotion, onChanged: (bool v) => AppSettingsScope.read(context).setReduceMotion(v), switchKey: const Key('a11y.toggle.motion')),
                  const SizedBox(height: RatelSpacing.md),
                  RatelToggleRow(label: S.t('a11y_dyslexia', 'Dyslexia-friendly font'), value: settings.dyslexiaFont, onChanged: (bool v) => AppSettingsScope.read(context).setDyslexiaFont(v), switchKey: const Key('a11y.toggle.dyslexia')),
                  const SizedBox(height: RatelSpacing.md),
                  RatelToggleRow(label: S.t('a11y_captions', 'Captions on audio'), value: settings.captions, onChanged: (bool v) => AppSettingsScope.read(context).setCaptions(v), switchKey: const Key('a11y.toggle.captions')),
                  const SizedBox(height: RatelSpacing.md),
                  RatelToggleRow(label: S.t('a11y_notime', 'No-time-pressure mode'), value: settings.noTimePressure, onChanged: (bool v) => AppSettingsScope.read(context).setNoTimePressure(v), switchKey: const Key('a11y.toggle.notime')),
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
