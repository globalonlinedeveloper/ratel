import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/i18n/strings.dart';
import '../../../core/theme/tokens.dart';
import '../../../design_system/components/ratel_button.dart';

/// Level result — mock Page-2 · screen 8 (CEFR placement + path preview).
/// Design-only (no backend yet).
class LevelResultScreen extends StatelessWidget {
  const LevelResultScreen({super.key});

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
                  Center(
                    child: Container(
                      width: 84,
                      height: 84,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: tk.successBg,
                        shape: BoxShape.circle,
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Text(
                            S.t('ob_level_cefr', 'A2'),
                            style: TextStyle(
                              color: tk.success,
                              fontSize: 26,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          Text(
                            S.t('ob_level_cefr_label', 'CEFR'),
                            style: TextStyle(color: tk.success, fontSize: 9),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: RatelSpacing.md),
                  Text(
                    S.t('ob_level_title', "You're at A2 — Elementary"),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: tk.text,
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: RatelSpacing.xs),
                  Text(
                    S.t(
                      'ob_level_sub',
                      "We've placed you on the right rung. Here's your path:",
                    ),
                    textAlign: TextAlign.center,
                    style: TextStyle(color: tk.textMuted, fontSize: 12, height: 1.5),
                  ),
                  const SizedBox(height: RatelSpacing.md),
                  _PathRow(
                    done: true,
                    label: S.t('ob_level_p1', 'Everyday phrases'),
                  ),
                  const SizedBox(height: RatelSpacing.sm),
                  _PathRow(
                    done: false,
                    label: S.t('ob_level_p2', 'Past & future tense'),
                  ),
                  const SizedBox(height: RatelSpacing.sm),
                  _PathRow(
                    done: false,
                    label: S.t('ob_level_p3', 'Conversations'),
                  ),
                  const SizedBox(height: RatelSpacing.lg),
                  RatelButton.filled(
                    label: S.t('ob_level_cta', 'Start learning'),
                    onPressed: () => context.push('/onboarding/first-win'),
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

/// One path milestone: a done check or an empty circle + label.
class _PathRow extends StatelessWidget {
  const _PathRow({required this.done, required this.label});

  final bool done;
  final String label;

  @override
  Widget build(BuildContext context) {
    final tk = context.tokens;
    return Row(
      children: <Widget>[
        Icon(
          done ? Icons.check_circle : Icons.circle_outlined,
          size: 17,
          color: done ? tk.success : tk.textMuted,
        ),
        const SizedBox(width: RatelSpacing.sm),
        Text(label, style: TextStyle(color: tk.text, fontSize: 12)),
      ],
    );
  }
}
