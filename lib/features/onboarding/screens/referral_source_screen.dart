import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/i18n/strings.dart';
import '../../../core/theme/tokens.dart';
import '../../../design_system/components/ratel_button.dart';
import '../../../design_system/components/ratel_option_tile.dart';

/// Referral source — mock Page-2 · screen 4 ("how'd you hear about us"). One
/// selectable source. Design-only (no backend yet).
class ReferralSourceScreen extends StatefulWidget {
  const ReferralSourceScreen({super.key});

  @override
  State<ReferralSourceScreen> createState() => _ReferralSourceScreenState();
}

class _ReferralSourceScreenState extends State<ReferralSourceScreen> {
  static const List<(String, IconData)> _sources = <(String, IconData)>[
    ('YouTube', Icons.play_circle_outline),
    ('TikTok / Instagram', Icons.movie_outlined),
    ('Friend or family', Icons.group_outlined),
    ('App store / search', Icons.search),
  ];
  String? _selected;

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
              RatelSpacing.xl,
              0,
              RatelSpacing.xl,
              RatelSpacing.xl,
            ),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text(
                    S.t('ob_referral_title', "How'd you hear about us?"),
                    style: TextStyle(
                      color: tk.text,
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: RatelSpacing.xs),
                  Text(
                    S.t('ob_referral_sub', 'Helps us reach more learners like you.'),
                    style: TextStyle(color: tk.textMuted, fontSize: 11),
                  ),
                  const SizedBox(height: RatelSpacing.md),
                  for (final (String name, IconData icon) in _sources) ...<Widget>[
                    RatelOptionTile(
                      leadingIcon: icon,
                      title: S.t('ob_referral_$name', name),
                      selected: name == _selected,
                      onTap: () => setState(() => _selected = name),
                    ),
                    const SizedBox(height: RatelSpacing.sm),
                  ],
                  const SizedBox(height: RatelSpacing.sm),
                  RatelButton.filled(
                    label: S.t('ob_referral_cta', 'Continue'),
                    onPressed: () => context.push('/onboarding/notify'),
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
