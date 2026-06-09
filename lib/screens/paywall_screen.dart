import 'package:flutter/material.dart';
import '../theme.dart';
import '../app_state.dart';
import '../widgets/ratel_mascot.dart';

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
    return Scaffold(
      appBar: AppBar(title: const Text('Ratel Pro')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Center(
            child: Column(
              children: [
                const RatelMascot(pose: RatelPose.celebrate, size: 120),
                const SizedBox(height: 8),
                Text(pro ? "You're Ratel Pro ✨" : 'Go fearless with Ratel Pro',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        fontSize: 22, fontWeight: FontWeight.w800)),
              ],
            ),
          ),
          const SizedBox(height: 20),
          _benefit(Icons.favorite, 'Unlimited hearts',
              'Never get blocked by mistakes — learn at your pace.'),
          _benefit(Icons.auto_awesome, 'Support development',
              'Help build the fearless honey badger you love.'),
          _benefit(Icons.rocket_launch, 'Early access',
              'New features and content land for Pro first.'),
          const SizedBox(height: 20),
          if (pro) ...[
            _card(
              child: const Text(
                  'Your Pro trial is active. Thanks for backing Ratel!',
                  style: TextStyle(fontWeight: FontWeight.w600)),
              tint: RatelColors.teal,
            ),
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: _busy ? null : _cancel,
              child: Text(_busy ? 'Working…' : 'Cancel Pro'),
            ),
          ] else ...[
            _plan('Yearly', '\$59.99/yr', 'Best value · ~\$5/mo', true),
            const SizedBox(height: 10),
            _plan('Monthly', '\$9.99/mo', 'Cancel anytime', false),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _busy ? null : _start,
                child: Text(_busy ? 'Starting…' : 'Start 7-day free trial'),
              ),
            ),
            const SizedBox(height: 10),
            const Text(
                'Test mode — no payment is taken yet. Real billing arrives with the app-store and web checkout.',
                textAlign: TextAlign.center,
                style: TextStyle(color: RatelColors.textMuted, fontSize: 12)),
          ],
        ],
      ),
    );
  }

  Widget _benefit(IconData icon, String title, String body) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: RatelColors.honey),
            const SizedBox(width: 12),
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

  Widget _plan(String name, String price, String note, bool best) => Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: RatelColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
              color: best ? RatelColors.honey : const Color(0xFFEAEAEA),
              width: best ? 2 : 1),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    Text(name,
                        style: const TextStyle(
                            fontWeight: FontWeight.w700, fontSize: 16)),
                    if (best) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                            color: RatelColors.honey,
                            borderRadius: BorderRadius.circular(8)),
                        child: const Text('BEST',
                            style: TextStyle(
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
