import 'package:flutter/material.dart';
import '../../../core/i18n/strings.dart';
import '../../../core/state/app_settings.dart';
import '../../../core/state/app_settings_scope.dart';
import '../../../core/theme/theme.dart';
import '../../../core/theme/tokens.dart';
import '../../../design_system/components/ratel_select_field.dart';
import '../../../design_system/components/ratel_toggle_row.dart';

/// Appearance & language — mock Page-6 · screen 5. Theme / accent / reduce-motion
/// are bound to [AppSettings] (persisted, app-wide). Design-only otherwise.
class AppearanceScreen extends StatelessWidget {
  const AppearanceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final tk = context.tokens;
    final AppSettings settings = AppSettingsScope.of(context);
    final TextStyle label = TextStyle(color: tk.textMuted, fontSize: 10, fontWeight: FontWeight.w600);

    Widget themePill(String name, ThemeMode mode, Key key) {
      final bool active = settings.themeMode == mode;
      return Expanded(
        child: GestureDetector(
          key: key,
          onTap: () => AppSettingsScope.read(context).setThemeMode(mode),
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 3),
            padding: const EdgeInsets.symmetric(vertical: 9),
            decoration: BoxDecoration(
              color: active ? tk.successBg : Colors.transparent,
              border: Border.all(color: active ? tk.primary : tk.border, width: active ? 1.5 : tk.hairline),
              borderRadius: BorderRadius.circular(tk.radiusSm),
            ),
            child: Text(name, textAlign: TextAlign.center, style: TextStyle(color: active ? tk.success : tk.text, fontSize: 11)),
          ),
        ),
      );
    }

    final List<Color> accents = ratelAccents(context.isDark);
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
                  Text(S.t('appear_title', 'Appearance & language'), style: TextStyle(color: tk.text, fontSize: 15, fontWeight: FontWeight.w600)),
                  const SizedBox(height: RatelSpacing.sm),
                  Text(S.t('appear_lang', 'App language'), style: label),
                  const SizedBox(height: RatelSpacing.xs),
                  RatelSelectField(label: S.t('appear_lang_value', 'தமிழ் · Tamil'), onTap: () {}),
                  const SizedBox(height: RatelSpacing.xs),
                  Text(S.t('appear_lang_hint', 'one progress record, switch UI language freely (lens model)'), style: TextStyle(color: tk.textMuted, fontSize: 9)),
                  const SizedBox(height: RatelSpacing.md),
                  Text(S.t('appear_theme', 'Theme'), style: label),
                  const SizedBox(height: RatelSpacing.xs),
                  Row(children: <Widget>[
                    themePill(S.t('appear_light', 'Light'), ThemeMode.light, const Key('appearance.pill.light')),
                    themePill(S.t('appear_dark', 'Dark'), ThemeMode.dark, const Key('appearance.pill.dark')),
                    themePill(S.t('appear_system', 'System'), ThemeMode.system, const Key('appearance.pill.system')),
                  ]),
                  const SizedBox(height: RatelSpacing.md),
                  RatelToggleRow(label: S.t('appear_motion', 'Reduce motion'), value: settings.reduceMotion, onChanged: (bool v) => AppSettingsScope.read(context).setReduceMotion(v)),
                  const SizedBox(height: RatelSpacing.sm),
                  Row(
                    children: <Widget>[
                      Expanded(child: Text(S.t('appear_accent', 'Accent colour'), style: TextStyle(color: tk.text, fontSize: 12))),
                      for (int i = 0; i < accents.length; i++) ...<Widget>[
                        GestureDetector(
                          key: Key('appearance.accent.$i'),
                          onTap: () => AppSettingsScope.read(context).setAccentIndex(i),
                          child: Container(
                            width: 22,
                            height: 22,
                            decoration: BoxDecoration(color: accents[i], shape: BoxShape.circle, border: i == settings.accentIndex ? Border.all(color: tk.text, width: 1.5) : null),
                          ),
                        ),
                        const SizedBox(width: RatelSpacing.sm),
                      ],
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
