import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/i18n/strings.dart';
import '../../../core/theme/tokens.dart';
import '../../../design_system/components/ratel_button.dart';
import '../../../design_system/components/ratel_option_tile.dart';

/// Start point — mock Page-2 · screen 6 (begin from scratch vs placement test).
/// Design-only (no backend yet).
class StartPointScreen extends StatefulWidget {
  const StartPointScreen({super.key});

  @override
  State<StartPointScreen> createState() => _StartPointScreenState();
}

class _StartPointScreenState extends State<StartPointScreen> {
  String _selected = 'scratch';

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
                    S.t('ob_start_title', 'Where should we start?'),
                    style: TextStyle(
                      color: tk.text,
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: RatelSpacing.md),
                  RatelOptionTile(
                    leadingIcon: Icons.eco_outlined,
                    title: S.t('ob_start_scratch', 'Start from scratch'),
                    subtitle: S.t(
                      'ob_start_scratch_sub',
                      'New to English — begin at the basics.',
                    ),
                    selected: _selected == 'scratch',
                    onTap: () => setState(() => _selected = 'scratch'),
                  ),
                  const SizedBox(height: RatelSpacing.sm),
                  RatelOptionTile(
                    leadingIcon: Icons.stairs_outlined,
                    title: S.t('ob_start_place', 'I know some — place me'),
                    subtitle: S.t(
                      'ob_start_place_sub',
                      'Take a 2-minute test to skip ahead.',
                    ),
                    selected: _selected == 'place',
                    onTap: () => setState(() => _selected = 'place'),
                  ),
                  const SizedBox(height: RatelSpacing.lg),
                  RatelButton.filled(
                    label: S.t('ob_start_cta', 'Continue'),
                    onPressed: () => context.push('/onboarding/placement'),
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
