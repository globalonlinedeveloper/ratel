import 'package:flutter/material.dart';
import '../../../core/i18n/strings.dart';
import '../../../core/theme/tokens.dart';
import '../../../design_system/components/ratel_button.dart';
import '../../../design_system/components/ratel_medallion.dart';

/// Avatar builder — mock Page-6 · screen 3 (illustrated avatar, no photo).
/// Design-only (no backend yet).
class AvatarBuilderScreen extends StatefulWidget {
  const AvatarBuilderScreen({super.key});

  @override
  State<AvatarBuilderScreen> createState() => _AvatarBuilderScreenState();
}

class _AvatarBuilderScreenState extends State<AvatarBuilderScreen> {
  int _skin = 0;
  final TextEditingController _bio = TextEditingController();

  @override
  void dispose() {
    _bio.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tk = context.tokens;
    Widget tab(String label, bool active) => Expanded(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 3),
            padding: const EdgeInsets.symmetric(vertical: 6),
            decoration: BoxDecoration(color: active ? tk.primary : tk.surface2, borderRadius: BorderRadius.circular(tk.radiusSm)),
            child: Text(label, textAlign: TextAlign.center, style: TextStyle(color: active ? Colors.white : tk.text, fontSize: 10)),
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
        child: Align(alignment: Alignment.topCenter,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(RatelSpacing.md, 0, RatelSpacing.md, RatelSpacing.md),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Text(S.t('avatar_title', 'Edit avatar'), style: TextStyle(color: tk.text, fontSize: 15, fontWeight: FontWeight.w600)),
                  const SizedBox(height: RatelSpacing.md),
                  Center(child: RatelMedallion(icon: Icons.sentiment_satisfied_alt, background: tk.warningBg, foreground: tk.brand, size: 96, iconSize: 54, cornerRadius: 24)),
                  const SizedBox(height: RatelSpacing.md),
                  Row(
                    children: <Widget>[
                      tab(S.t('avatar_skin', 'Skin'), true),
                      tab(S.t('avatar_hair', 'Hair'), false),
                      tab(S.t('avatar_outfit', 'Outfit'), false),
                    ],
                  ),
                  const SizedBox(height: RatelSpacing.md),
                  Row(
                    children: <Widget>[
                      for (int i = 0; i < RatelSkin.tones.length; i++) ...<Widget>[
                        GestureDetector(
                          onTap: () => setState(() => _skin = i),
                          child: Container(
                            width: 34,
                            height: 34,
                            decoration: BoxDecoration(
                              color: RatelSkin.tones[i],
                              shape: BoxShape.circle,
                              border: i == _skin ? Border.all(color: tk.primary, width: 1.5) : null,
                            ),
                          ),
                        ),
                        const SizedBox(width: RatelSpacing.sm),
                      ],
                    ],
                  ),
                  const SizedBox(height: RatelSpacing.md),
                  Container(
                    height: 42,
                    padding: const EdgeInsets.symmetric(horizontal: RatelSpacing.md),
                    alignment: Alignment.centerLeft,
                    decoration: BoxDecoration(border: Border.all(color: tk.border, width: tk.hairline), borderRadius: BorderRadius.circular(tk.radiusMd)),
                    child: Text(S.t('avatar_username', 'Username · raj_learns'), style: TextStyle(color: tk.textMuted, fontSize: 12)),
                  ),
                  const SizedBox(height: RatelSpacing.sm),
                  Container(
                    decoration: BoxDecoration(border: Border.all(color: tk.border, width: tk.hairline), borderRadius: BorderRadius.circular(tk.radiusMd)),
                    child: TextField(
                      controller: _bio,
                      maxLines: 2,
                      style: TextStyle(color: tk.text, fontSize: 12),
                      decoration: InputDecoration(
                        hintText: S.t('avatar_bio', 'Bio…'),
                        hintStyle: TextStyle(color: tk.textMuted, fontSize: 12),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.all(RatelSpacing.md),
                      ),
                    ),
                  ),
                  const SizedBox(height: RatelSpacing.xs),
                  Text(S.t('avatar_note', 'illustrated avatar only — no photo upload (privacy & safety)'), style: TextStyle(color: tk.textMuted, fontSize: 9)),
                  const SizedBox(height: RatelSpacing.md),
                  RatelButton.filled(label: S.t('avatar_cta', 'Save'), onPressed: () {}),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
