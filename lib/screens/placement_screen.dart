import 'package:flutter/material.dart';
import '../widgets/mascot_anim.dart';
import '../theme.dart';
import '../app_state.dart';
import '../placement.dart';
import '../widgets/ratel_mascot.dart';

/// Optional onboarding placement check: 8 quick questions spanning Units 2-5;
/// a strong score skips the learner past the basics (no XP side-effects).
class PlacementScreen extends StatefulWidget {
  const PlacementScreen({super.key, required this.goal, this.probes});
  final int goal;
  final List<PlacementProbe>? probes; // injectable for tests

  @override
  State<PlacementScreen> createState() => _PlacementScreenState();
}

class _PlacementScreenState extends State<PlacementScreen> {
  late final List<PlacementProbe> _probes =
      widget.probes ?? buildPlacementProbes();
  int _i = 0;
  int _correct = 0;
  int? _selected;
  bool _checked = false;
  bool _done = false;
  bool _busy = false;

  void _check() {
    if (_selected == null) return;
    setState(() {
      _checked = true;
      if (_selected == _probes[_i].exercise.correctIndex) _correct++;
    });
  }

  void _next() {
    if (_i + 1 >= _probes.length) {
      setState(() => _done = true);
    } else {
      setState(() {
        _i++;
        _selected = null;
        _checked = false;
      });
    }
  }

  Future<void> _finish() async {
    setState(() => _busy = true);
    final int skip = unitsToSkipFor(_correct, _probes.length);
    if (skip > 0) {
      await appState.skipAhead(lessonIdsForUnits(skip));
    }
    await appState.setDailyGoal(widget.goal);
    await appState.markOnboarded();
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    if (_probes.isEmpty || _done) return _result(context);
    final probe = _probes[_i];
    final ex = probe.exercise;
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: ListView(
              padding: const EdgeInsets.all(24),
              children: [
                Row(
                  children: [
                    IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.close)),
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: LinearProgressIndicator(
                            value: (_i + (_checked ? 1 : 0)) / _probes.length,
                            minHeight: 10),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text('${_i + 1}/${_probes.length}',
                        style: TextStyle(color: context.mutedC)),
                  ],
                ),
                const SizedBox(height: 16),
                const Text('Placement check',
                    style: TextStyle(
                        fontFamily: kDisplayFont,
                        fontSize: 20,
                        fontWeight: FontWeight.w700)),
                const SizedBox(height: 4),
                Text('Answer what you can — no pressure.',
                    style: TextStyle(color: context.mutedC, fontSize: 13)),
                const SizedBox(height: 18),
                Text(ex.prompt,
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w700)),
                if (ex.sentence != null) ...[
                  const SizedBox(height: 8),
                  Text(ex.sentence!, style: const TextStyle(fontSize: 16)),
                ],
                const SizedBox(height: 14),
                for (int j = 0; j < ex.options.length; j++)
                  _option(context, ex, j),
                const SizedBox(height: 18),
                _checked
                    ? FilledButton(
                        onPressed: _next,
                        child: Text(_i + 1 >= _probes.length
                            ? 'See result'
                            : 'Continue'))
                    : FilledButton(
                        onPressed: _selected == null ? null : _check,
                        child: const Text('Check')),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _option(BuildContext context, ex, int j) {
    final bool sel = _selected == j;
    Color border = sel ? RatelColors.honey : context.borderC;
    Color? tint;
    if (_checked) {
      if (j == ex.correctIndex) {
        border = RatelColors.teal;
        tint = RatelColors.teal.withValues(alpha: 0.10);
      } else if (sel) {
        border = RatelColors.coral;
        tint = RatelColors.coral.withValues(alpha: 0.10);
      }
    }
    return GestureDetector(
      onTap: _checked ? null : () => setState(() => _selected = j),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: tint ?? context.surfaceC,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: border, width: sel ? 2 : 1),
        ),
        child: Text(ex.options[j],
            style: const TextStyle(fontWeight: FontWeight.w600)),
      ),
    );
  }

  Widget _result(BuildContext context) {
    final int skip =
        _probes.isEmpty ? 0 : unitsToSkipFor(_correct, _probes.length);
    final String headline = switch (skip) {
      0 => 'Starting from the beginning is perfect!',
      1 => 'Nice — you can skip Unit 1.',
      2 => 'Great — you can skip Units 1-2.',
      _ => 'Impressive — you can skip Units 1-3!',
    };
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  skip > 0
                      ? const RatelActionAnim(
                          action: 'gradcap',
                          fallbackPose: RatelPose.celebrate,
                          size: 120)
                      : const RatelMascot(
                          pose: RatelPose.celebrate, size: 120),
                  const SizedBox(height: 16),
                  Text('$_correct / ${_probes.length} correct',
                      style: TextStyle(color: context.mutedC)),
                  const SizedBox(height: 6),
                  Text(headline,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                          fontFamily: kDisplayFont,
                          fontSize: 20,
                          fontWeight: FontWeight.w700)),
                  const SizedBox(height: 22),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: _busy ? null : _finish,
                      child: Text(_busy ? 'Setting up…' : 'Start learning'),
                    ),
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
