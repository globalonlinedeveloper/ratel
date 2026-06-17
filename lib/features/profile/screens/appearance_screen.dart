import 'package:flutter/material.dart';
import '../../../core/i18n/strings.dart';
import '../../../core/theme/tokens.dart';
import '../../../design_system/components/ratel_select_field.dart';
import '../../../design_system/components/ratel_toggle_row.dart';

/// Appearance & language — mock Page-6 · screen 5. Design-only (no backend yet).
class AppearanceScreen extends StatefulWidget {
  const AppearanceScreen({super.key});

  @override
  State<AppearanceScreen> createState() => _AppearanceScreenState();
}

class _AppearanceScreenState extends State<AppearanceScreen> {
  String _theme = 'System';
  bool _reduceMotion = false;
  int _accent = 0;

  @override
  Widget build(BuildContext context) {
    final tk = context.tokens;
    final TextStyle label = TextStyle(color: tk.textMuted, fontSize: 10, fontWeight: FontWeight.w600);
    Widget themePill(String name) {
      final bool active = _theme == name;
      return Expanded(
        child: GestureDetector(
          onTap: () => setState(() => _theme = name),
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

    final List<Color> accents = <Color>[tk.primary, tk.brand, RatelSociety.purple];
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
                  Row(children: <Widget>[themePill(S.t('appear_light', 'Light')), themePill(S.t('appear_dark', 'Dark')), themePill(S.t('appear_system', 'System'))]),
                  const SizedBox(height: RatelSpacing.md),
                  RatelToggleRow(label: S.t('appear_motion', 'Reduce motion'), value: _reduceMotion, onChanged: (bool v) => setState(() => _reduceMotion = v)),
                  const SizedBox(height: RatelSpacing.sm),
                  Row(
                    children: <Widget>[
                      Expanded(child: Text(S.t('appear_accent', 'Accent colour'), style: TextStyle(color: tk.text, fontSize: 12))),
                      for (int i = 0; i < accents.length; i++) ...<Widget>[
                        GestureDetector(
                          onTap: () => setState(() => _accent = i),
                          child: Container(
                            width: 22,
                            height: 22,
                            decoration: BoxDecoration(color: accents[i], shape: BoxShape.circle, border: i == _accent ? Border.all(color: tk.text, width: 1.5) : null),
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
