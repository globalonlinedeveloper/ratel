import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/i18n/strings.dart';
import '../../../core/theme/tokens.dart';
import '../../../design_system/components/ratel_button.dart';
import '../../../design_system/components/ratel_option_tile.dart';

/// Placement test — mock Page-2 · screen 7 (a single sample question with a
/// progress bar). Design-only (no backend yet).
class PlacementTestScreen extends StatefulWidget {
  const PlacementTestScreen({super.key});

  @override
  State<PlacementTestScreen> createState() => _PlacementTestScreenState();
}

class _PlacementTestScreenState extends State<PlacementTestScreen> {
  String _answer = 'goes';

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
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(tk.radiusPill),
                          child: LinearProgressIndicator(
                            value: 3 / 7,
                            minHeight: 7,
                            backgroundColor: tk.border,
                            valueColor: AlwaysStoppedAnimation<Color>(tk.primary),
                          ),
                        ),
                      ),
                      const SizedBox(width: RatelSpacing.sm),
                      Text(
                        S.t('ob_placement_progress', '3 / 7'),
                        style: TextStyle(color: tk.textMuted, fontSize: 11),
                      ),
                    ],
                  ),
                  const SizedBox(height: RatelSpacing.md),
                  Text(
                    S.t('ob_placement_q', 'Choose the correct word'),
                    style: TextStyle(
                      color: tk.text,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: RatelSpacing.sm),
                  Text(
                    S.t('ob_placement_sentence', 'She ___ to school every day.'),
                    style: TextStyle(color: tk.textMuted, fontSize: 13),
                  ),
                  const SizedBox(height: RatelSpacing.md),
                  for (final String option in <String>['goes', 'go', 'going']) ...<Widget>[
                    RatelOptionTile(
                      title: option,
                      selected: option == _answer,
                      onTap: () => setState(() => _answer = option),
                    ),
                    const SizedBox(height: RatelSpacing.sm),
                  ],
                  const SizedBox(height: RatelSpacing.sm),
                  RatelButton.filled(
                    label: S.t('ob_placement_cta', 'Check'),
                    onPressed: () => context.push('/onboarding/level'),
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
