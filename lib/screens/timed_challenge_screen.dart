import 'dart:async';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../app_state.dart';
import '../flags.dart';
import '../milestones.dart';
import '../models.dart';
import '../placement.dart';
import '../sfx.dart';
import '../strings.dart';
import '../theme.dart';
import '../widgets/ratel_mascot.dart';

/// Opt-in, kind by design: NO hearts at risk, ever. Beat the clock,
/// keep your best, earn a few gems.
class TimedChallengeScreen extends StatefulWidget {
  const TimedChallengeScreen(
      {super.key, this.pool, this.duration = const Duration(seconds: 60)});

  final List<Exercise>? pool; // test injection
  final Duration duration;

  @override
  State<TimedChallengeScreen> createState() =>
      _TimedChallengeScreenState();
}

class _TimedChallengeScreenState extends State<TimedChallengeScreen> {
  late final List<Exercise> _pool = widget.pool ?? timedPool();
  Timer? _tick;
  int _left = 0; // seconds remaining; 0 + !_running = start screen
  bool _running = false;
  bool _done = false;
  bool _boosted = false;
  int _i = 0;
  int _correct = 0;
  int _answered = 0;
  int _best = 0;

  int get _boostCost => Flags.instance.intOf('gem_timer_cost', 50);

  @override
  void initState() {
    super.initState();
    SharedPreferences.getInstance().then((p) {
      if (mounted) setState(() => _best = p.getInt('timed_best') ?? 0);
    });
  }

  @override
  void dispose() {
    _tick?.cancel();
    super.dispose();
  }

  void _start() {
    Sfx.instance.tap();
    setState(() {
      _running = true;
      _done = false;
      _i = 0;
      _correct = 0;
      _answered = 0;
      _left = widget.duration.inSeconds + (_boosted ? 15 : 0);
    });
    _tick?.cancel();
    _tick = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() => _left--);
      if (_left <= 0) _finish();
    });
  }

  Future<void> _finish() async {
    _tick?.cancel();
    final int gems = timedGems(_correct);
    if (gems > 0) appState.addGems(gems);
    final int score = _correct * 10;
    try {
      final p = await SharedPreferences.getInstance();
      if (score > (_best)) {
        _best = score;
        await p.setInt('timed_best', score);
      }
    } catch (_) {}
    Sfx.instance.complete();
    if (mounted) {
      setState(() {
        _running = false;
        _done = true;
      });
    }
  }

  void _pick(int o) {
    final ex = _pool[_i % _pool.length];
    if (o == ex.correctIndex) {
      _correct++;
      Sfx.instance.correct();
    } else {
      Sfx.instance.wrong(); // cosmetic: nothing is lost, time just ticks
    }
    setState(() {
      _answered++;
      _i++;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_running) return _play(context);
    return _gate(context);
  }

  Widget _gate(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Timed challenge')),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                RatelMascot(
                    pose: _done ? RatelPose.celebrate : RatelPose.point,
                    size: 110),
                const SizedBox(height: 12),
                Text(_done ? 'Nice run!' : 'Beat the clock!',
                    style: const TextStyle(
                        fontSize: 22, fontWeight: FontWeight.w800)),
                const SizedBox(height: 8),
                Text(
                    _done
                        ? 'Score ${_correct * 10} · $_correct correct '
                            'of $_answered · +${timedGems(_correct)} gems'
                        : 'Answer as many as you can in '
                            '${widget.duration.inSeconds} seconds. '
                            'No hearts at risk — ever.',
                    textAlign: TextAlign.center,
                    style:
                        const TextStyle(color: RatelColors.textMuted)),
                const SizedBox(height: 6),
                Text('Best: $_best',
                    style: const TextStyle(
                        color: RatelColors.textMuted,
                        fontWeight: FontWeight.w700)),
                const SizedBox(height: 20),
                if (!_boosted)
                  TextButton.icon(
                    onPressed: () {
                      if (appState.spendGems(_boostCost)) {
                        Sfx.instance.tap();
                        setState(() => _boosted = true);
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                                content: Text(S.instance.t(
                                    'gems_short',
                                    'Not enough gems yet — '
                                    'keep learning!'))));
                      }
                    },
                    icon: const Icon(Icons.flash_on,
                        color: RatelColors.coral, size: 18),
                    label: Text('Start with +15s · $_boostCost gems'),
                  )
                else
                  const Padding(
                    padding: EdgeInsets.only(bottom: 4),
                    child: Text('+15s boost armed!',
                        style: TextStyle(
                            color: RatelColors.coral,
                            fontWeight: FontWeight.w800)),
                  ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    style: FilledButton.styleFrom(
                        backgroundColor: RatelColors.teal,
                        padding:
                            const EdgeInsets.symmetric(vertical: 16)),
                    onPressed: _pool.isEmpty ? null : _start,
                    child: Text(_done ? 'Run it again' : 'Start'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _play(BuildContext context) {
    final ex = _pool[_i % _pool.length];
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.timer_outlined,
                      color: RatelColors.coral),
                  const SizedBox(width: 6),
                  Text('${_left}s',
                      style: const TextStyle(
                          fontSize: 20, fontWeight: FontWeight.w800)),
                  const Spacer(),
                  Text('Score ${_correct * 10}',
                      style: const TextStyle(
                          fontWeight: FontWeight.w800, fontSize: 16)),
                ],
              ),
              const SizedBox(height: 14),
              Text(ex.prompt,
                  style: const TextStyle(
                      fontSize: 17, fontWeight: FontWeight.w700)),
              if ((ex.sentence ?? '').isNotEmpty) ...[
                const SizedBox(height: 6),
                Text(ex.sentence!, style: const TextStyle(fontSize: 16)),
              ],
              const SizedBox(height: 12),
              Expanded(
                child: ListView(
                  children: [
                    for (int o = 0; o < ex.options.length; o++)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 14)),
                          onPressed: () => _pick(o),
                          child: Text(ex.options[o],
                              style: const TextStyle(fontSize: 16)),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
