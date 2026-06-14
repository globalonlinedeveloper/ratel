import '../flags.dart';
import 'package:flutter/material.dart';
import '../theme.dart';
import '../app_state.dart';
import '../strings.dart';
import '../widgets/ratel_mascot.dart';
import '../widgets/ratel_scaffold.dart';

/// Ratel Pro paywall. Lists the plan + benefits and starts the 7-day trial.
/// NOTE: this is TEST mode — `start_pro_trial` unlocks Pro with no charge.
/// Real billing (Stripe web checkout / App Store + Play IAP) replaces that call.
class PaywallScreen extends StatefulWidget {
  const PaywallScreen({super.key});

  @override
  State<PaywallScreen> createState() => _PaywallScreenState();
}

class _PaywallScreenState extends State<PaywallScreen> {
  bool _busy = false;

  Future<void> _start() async {
    setState(() => _busy = true);
    await appState.startProTrial();
    if (mounted) setState(() => _busy = false);
  }

  Future<void> _cancel() async {
    setState(() => _busy = true);
    await appState.cancelPro();
    if (mounted) setState(() => _busy = false);
  }

  @override
  Widget build(BuildContext context) {
    final pro = appState.isPro;
    return RatelScaffold(
      title: S.instance.t('pw_title', 'Ratel Pro'),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Center(
            child: Column(
              children: [
                ExcludeSemantics(
                  child: Image.asset('assets/images/ratel-crown.webp',
                      width: 120,
                      height: 120,
                      errorBuilder: (_, _, _) => const RatelMascot(
                          pose: RatelPose.celebrate, size: 120)),
                ),
                const SizedBox(height: RatelSpacing.sm),
                Text(
                    pro
                        ? S.instance.t('pw_head_pro', "You're Ratel Pro ✨")
                        : S.instance
                            .t('pw_head', 'Go fearless with Ratel Pro'),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        fontSize: 22, fontWeight: FontWeight.w800)),
              ],
            ),
          ),
          const SizedBox(height: 20),
          _benefit(
              Icons.favorite,
              S.instance.t('pw_b1_t', 'Unlimited hearts'),
              S.instance.t('pw_b1_s',
                  'Never get blocked by mistakes — learn at your pace.')),
          _benefit(
              Icons.auto_awesome,
              S.instance.t('pw_b2_t', 'Support development'),
              S.instance.t('pw_b2_s',
                  'Help build the fearless honey badger you love.')),
          _benefit(
              Icons.rocket_launch,
              S.instance.t('pw_b3_t', 'Early access'),
              S.instance.t('pw_b3_s',
                  'New features and content land for Pro first.')),
          _compareTable(context),
          const SizedBox(height: 20),
          if (pro) ...[
            _card(
              child: Text(
                  S.instance.t('pw_trial',
                      'Your Pro trial is active. Thanks for backing Ratel!'),
                  style: const TextStyle(fontWeight: FontWeight.w600)),
              tint: RatelColors.teal,
            ),
            const SizedBox(height: RatelSpacing.md),
            OutlinedButton(
              onPressed: _busy ? null : _cancel,
              child: Text(_busy
                  ? S.instance.t('pw_working', 'Working…')
                  : S.instance.t('pw_cancel', 'Cancel Pro')),
            ),
          ] else ...[
            _plan(
                S.instance.t('pw_yearly', 'Yearly'),
                Flags.instance.str('price_year', '\$59.99/yr'),
                S.instance.t('pw_best_value', 'Best value'), true),
            const SizedBox(height: 10),
            _plan(
                S.instance.t('pw_monthly', 'Monthly'),
                Flags.instance.str('price_month', '\$9.99/mo'),
                S.instance.t('pw_cancel_any', 'Cancel anytime'), false),
            const SizedBox(height: RatelSpacing.lg),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _busy ? null : _start,
                child: Text(_busy
                    ? S.instance.t('pw_starting', 'Starting…')
                    : S.instance.t('pw_start', 'Start 7-day free trial')),
              ),
            ),
            const SizedBox(height: 10),
            Text(
                S.instance.t('pw_test_note',
                    'Test mode — no payment is taken yet. Real billing arrives with the app-store and web checkout.'),
                textAlign: TextAlign.center,
                style: const TextStyle(
                    color: RatelColors.textMuted, fontSize: 12)),
            TextButton(
              onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                      content: Text(S.instance.t('restore_soon',
                          'Restore arrives with the store build.')))),
              child: Text(S.instance.t('pw_restore', 'Restore purchases'),
                  style: const TextStyle(
                      color: RatelColors.textMuted, fontSize: 12)),
            ),
          ],
        ],
      ),
    );
  }

  Widget _benefit(IconData icon, String title, String body) => Padding(
        padding: const EdgeInsets.only(bottom: RatelSpacing.md),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: RatelColors.honey),
            const SizedBox(width: RatelSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(
                          fontWeight: FontWeight.w700, fontSize: 15)),
                  Text(body,
                      style: const TextStyle(color: RatelColors.textMuted)),
                ],
              ),
            ),
          ],
        ),
      );

  Widget _compareTable(BuildContext context) {
    TableRow row(String label, String free, String proV,
            {bool head = false}) =>
        TableRow(
          children: [
            for (final (i, t) in [label, free, proV].indexed)
              Padding(
                padding: const EdgeInsets.symmetric(
                    vertical: RatelSpacing.sm, horizontal: RatelSpacing.sm),
                child: Text(t,
                    textAlign:
                        i == 0 ? TextAlign.left : TextAlign.center,
                    style: TextStyle(
                        fontSize: head ? 13 : 13.5,
                        fontWeight: head || i == 2
                            ? FontWeight.w800
                            : FontWeight.w500,
                        color: head
                            ? RatelColors.textMuted
                            : (i == 2 ? RatelColors.honey : null))),
              ),
          ],
        );
    return Container(
      decoration: BoxDecoration(
        color: context.surfaceC,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: context.borderC),
      ),
      child: Table(
        columnWidths: const {
          0: FlexColumnWidth(1.6),
          1: FlexColumnWidth(1),
          2: FlexColumnWidth(1),
        },
        children: [
          row('', S.instance.t('pw_c_free', 'Free'),
              S.instance.t('pw_c_pro', 'Pro'),
              head: true),
          row(
              S.instance.t('hearts_title', 'Hearts'),
              S.instance.t('pw_c_regen', '5 + regen'),
              S.instance.t('pw_c_unlim', 'Unlimited')),
          row(
              S.instance.t('pw_c_coach', 'Coach messages'),
              S.instance.t('pw_c_perday', '{n}/day').replaceAll('{n}', '20'),
              S.instance.t('pw_c_perday', '{n}/day').replaceAll('{n}', '200')),
          row(S.instance.t('pw_c_all', 'Every lesson & villain'), '✓', '✓'),
          row(S.instance.t('pw_c_early', 'Early features'), '—', '✓'),
        ],
      ),
    );
  }

  Widget _plan(String name, String price, String note, bool best) => Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: context.surfaceC,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
              color: best ? RatelColors.honey : context.borderC,
              width: best ? 2 : 1),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    Flexible(
                      child: Text(name,
                          style: const TextStyle(
                              fontWeight: FontWeight.w700, fontSize: 16)),
                    ),
                    if (best) ...[
                      const SizedBox(width: RatelSpacing.sm),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                            color: RatelColors.honey,
                            borderRadius: BorderRadius.circular(8)),
                        child: Text(S.instance.t('pw_best', 'BEST'),
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.w700)),
                      ),
                    ],
                  ]),
                  Text(note,
                      style: const TextStyle(
                          color: RatelColors.textMuted, fontSize: 13)),
                ],
              ),
            ),
            Text(price,
                style: const TextStyle(
                    fontWeight: FontWeight.w800, fontSize: 16)),
          ],
        ),
      );

  Widget _card({required Widget child, required Color tint}) => Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: tint.withValues(alpha: 0.10),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: tint.withValues(alpha: 0.4)),
        ),
        child: child,
      );
}
