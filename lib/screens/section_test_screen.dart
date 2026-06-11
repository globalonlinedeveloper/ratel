import 'package:flutter/material.dart';

import '../app_state.dart';
import '../milestones.dart';
import '../placement.dart';
import '../sfx.dart';
import '../theme.dart';
import '../widgets/ratel_mascot.dart';

/// Jump ahead by proving it: 8 probes over the skipped units; >=85%
/// unlocks the section via the side-effect-free skipAhead path.
class SectionTestScreen extends StatefulWidget {
  const SectionTestScreen({super.key, required this.section});

  final CourseSection section;

  @override
  State<SectionTestScreen> createState() => _SectionTestScreenState();
}

class _SectionTestScreenState extends State<SectionTestScreen> {
  late final List<PlacementProbe> _probes =
      sectionProbes(widget.section.firstUnit);
  int _i = 0;
  int _correct = 0;
  int? _sel;
  bool _done = false;
  bool _passed = false;

  Future<void> _answer() async {
    final ex = _probes[_i].exercise;
    if (_sel == ex.correctIndex) {
      _correct++;
      Sfx.instance.correct();
    } else {
      Sfx.instance.wrong();
    }
    if (_i + 1 < _probes.length) {
      setState(() {
        _i++;
        _sel = null;
      });
      return;
    }
    final bool pass = sectionTestPassed(_correct, _probes.length);
    if (pass) {
      await appState
          .skipAhead(lessonIdsForUnits(widget.section.firstUnit));
      Sfx.instance.complete();
    }
    if (mounted) {
      setState(() {
        _done = true;
        _passed = pass;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_done) return _result(context);
    if (_probes.isEmpty) {
      // nothing to test (fallback course too short) — let them through
      return Scaffold(
        body: Center(
          child: TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close')),
        ),
      );
    }
    final ex = _probes[_i].exercise;
    return Scaffold(
      appBar: AppBar(
        title: Text('Test out · ${widget.section.title}'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('${_i + 1} of ${_probes.length}',
                  style: const TextStyle(
                      color: RatelColors.textMuted,
                      fontWeight: FontWeight.w700)),
              const SizedBox(height: 8),
              Text(ex.prompt,
                  style: const TextStyle(
                      fontSize: 17, fontWeight: FontWeight.w700)),
              if ((ex.sentence ?? '').isNotEmpty) ...[
                const SizedBox(height: 6),
                Text(ex.sentence!,
                    style: const TextStyle(fontSize: 16)),
              ],
              const SizedBox(height: 14),
              Expanded(
                child: ListView(
                  children: [
                    for (int o = 0; o < ex.options.length; o++)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: InkWell(
                          onTap: () => setState(() => _sel = o),
                          borderRadius: BorderRadius.circular(10),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 12),
                            decoration: BoxDecoration(
                              color: _sel == o
                                  ? context.tintC(RatelColors.teal)
                                  : context.surfaceC,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                  color: _sel == o
                                      ? RatelColors.teal
                                      : context.faintBorderC,
                                  width: _sel == o ? 2 : 1),
                            ),
                            child: Text(ex.options[o],
                                style: const TextStyle(fontSize: 16)),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  style: FilledButton.styleFrom(
                      backgroundColor: RatelColors.teal,
                      padding: const EdgeInsets.symmetric(vertical: 16)),
                  onPressed: _sel == null ? null : _answer,
                  child: Text(
                      _i + 1 < _probes.length ? 'Next' : 'See result'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _result(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                RatelMascot(
                    pose: _passed
                        ? RatelPose.celebrate
                        : RatelPose.encourage,
                    size: 120),
                const SizedBox(height: 14),
                Text(_passed ? 'You jumped ahead!' : 'Not yet — keep going!',
                    style: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.w800)),
                const SizedBox(height: 8),
                Text(
                    _passed
                        ? '${widget.section.title} is unlocked. '
                            'Earlier lessons stay open for practice.'
                        : 'You got $_correct of ${_probes.length}. '
                            'A little more practice and this section '
                            'is yours.',
                    textAlign: TextAlign.center,
                    style:
                        const TextStyle(color: RatelColors.textMuted)),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    style: FilledButton.styleFrom(
                        backgroundColor: RatelColors.teal,
                        padding:
                            const EdgeInsets.symmetric(vertical: 16)),
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Continue'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
