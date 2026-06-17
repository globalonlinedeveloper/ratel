import 'dart:async';
import 'package:flutter/material.dart';
import '../../../core/i18n/strings.dart';
import '../../../core/theme/tokens.dart';
import '../../../design_system/components/ratel_button.dart';
import '../../../design_system/components/ratel_choice_chip.dart';
import '../../../design_system/components/ratel_medallion.dart';

/// Timed challenge — mock Page-4 · screen 3 (60-second sprint, no energy at
/// risk). A live client-side countdown + in-session scoring loop
/// (idle → running → done). Mock questions; the "best score" stays a stub
/// (real persistence + a calibrated item bank land Phase 2/3). No backend.
enum _Phase { idle, running, done }

class TimedChallengeScreen extends StatefulWidget {
  const TimedChallengeScreen({super.key});

  @override
  State<TimedChallengeScreen> createState() => _TimedChallengeScreenState();
}

class _TimedChallengeScreenState extends State<TimedChallengeScreen> {
  static const int _duration = 60;
  static const List<_Q> _questions = <_Q>[
    _Q('Past tense of go', <String>['went', 'goed', 'gone', 'going'], 0),
    _Q('Article before apple', <String>['an', 'a', 'the', 'some'], 0),
    _Q('Opposite of fast', <String>['slow', 'quick', 'near', 'high'], 0),
    _Q('Plural of child', <String>['children', 'childs', 'childes', 'child'], 0),
  ];

  _Phase _phase = _Phase.idle;
  int _secondsLeft = _duration;
  int _score = 0;
  int _q = 0;
  Timer? _timer;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _start() {
    _timer?.cancel();
    setState(() {
      _phase = _Phase.running;
      _secondsLeft = _duration;
      _score = 0;
      _q = 0;
    });
    _timer = Timer.periodic(const Duration(seconds: 1), (Timer t) {
      setState(() {
        _secondsLeft--;
        if (_secondsLeft <= 0) {
          _secondsLeft = 0;
          _phase = _Phase.done;
          t.cancel();
        }
      });
    });
  }

  void _answer(int i) {
    if (_phase != _Phase.running) return;
    setState(() {
      if (i == _questions[_q].correct) _score++;
      _q = (_q + 1) % _questions.length;
    });
  }

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
                tooltip: S.t('a11y_back', 'Back'),
                onPressed: () => Navigator.of(context).maybePop(),
              )
            : null,
      ),
      body: SafeArea(
        child: Align(
          alignment: Alignment.topCenter,
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
                children: switch (_phase) {
                  _Phase.idle => _idle(tk),
                  _Phase.running => _running(tk),
                  _Phase.done => _done(tk),
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _idle(RatelTokens tk) => <Widget>[
    Center(
      child: RatelMedallion(
        icon: Icons.timer_outlined,
        background: tk.warningBg,
        foreground: tk.coral,
        size: 66,
        iconSize: 34,
      ),
    ),
    const SizedBox(height: RatelSpacing.md),
    Text(
      S.t('timed_title', 'Timed challenge'),
      textAlign: TextAlign.center,
      style: TextStyle(color: tk.text, fontSize: 18, fontWeight: FontWeight.w800),
    ),
    const SizedBox(height: RatelSpacing.xs),
    Text(
      S.t('timed_sub', 'Answer as many as you can in 60 seconds. No energy at risk — pure practice.'),
      textAlign: TextAlign.center,
      style: TextStyle(color: tk.textMuted, fontSize: 12, height: 1.5),
    ),
    const SizedBox(height: RatelSpacing.md),
    Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        _Stat(value: S.t('timed_clock', '60s'), label: S.t('timed_clock_l', 'clock'), color: tk.text),
        const SizedBox(width: RatelSpacing.xl),
        _Stat(value: S.t('timed_best', '42'), label: S.t('timed_best_l', 'best score'), color: tk.brand),
      ],
    ),
    const SizedBox(height: RatelSpacing.lg),
    RatelButton.filled(label: S.t('timed_cta', 'Start challenge'), onPressed: _start),
  ];

  List<Widget> _running(RatelTokens tk) => <Widget>[
    Center(
      child: Text(
        '$_secondsLeft',
        style: TextStyle(color: tk.coral, fontSize: 44, fontWeight: FontWeight.w800),
      ),
    ),
    Center(
      child: Text(
        S.t('timed_left', 'seconds left'),
        style: TextStyle(color: tk.textMuted, fontSize: 11),
      ),
    ),
    const SizedBox(height: RatelSpacing.xs),
    Center(
      child: Text(
        '${S.t('timed_score', 'Score')} $_score',
        style: TextStyle(color: tk.brand, fontSize: 13, fontWeight: FontWeight.w700),
      ),
    ),
    const SizedBox(height: RatelSpacing.lg),
    Text(
      _questions[_q].prompt,
      textAlign: TextAlign.center,
      style: TextStyle(color: tk.text, fontSize: 16, fontWeight: FontWeight.w700),
    ),
    const SizedBox(height: RatelSpacing.md),
    Wrap(
      alignment: WrapAlignment.center,
      spacing: RatelSpacing.sm,
      runSpacing: RatelSpacing.sm,
      children: <Widget>[
        for (int i = 0; i < _questions[_q].options.length; i++)
          RatelChoiceChip(
            label: _questions[_q].options[i],
            selected: false,
            onTap: () => _answer(i),
          ),
      ],
    ),
  ];

  List<Widget> _done(RatelTokens tk) => <Widget>[
    Center(
      child: RatelMedallion(
        icon: Icons.emoji_events,
        background: tk.warningBg,
        foreground: tk.win,
        size: 66,
        iconSize: 34,
      ),
    ),
    const SizedBox(height: RatelSpacing.md),
    Text(
      S.t('timed_done', "Time's up!"),
      textAlign: TextAlign.center,
      style: TextStyle(color: tk.text, fontSize: 18, fontWeight: FontWeight.w800),
    ),
    const SizedBox(height: RatelSpacing.md),
    Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        _Stat(value: '$_score', label: S.t('timed_yours_l', 'your score'), color: tk.brand),
        const SizedBox(width: RatelSpacing.xl),
        _Stat(value: S.t('timed_best', '42'), label: S.t('timed_best_l', 'best score'), color: tk.text),
      ],
    ),
    const SizedBox(height: RatelSpacing.lg),
    RatelButton.filled(label: S.t('timed_again', 'Play again'), onPressed: _start),
  ];
}

class _Q {
  const _Q(this.prompt, this.options, this.correct);
  final String prompt;
  final List<String> options;
  final int correct;
}

class _Stat extends StatelessWidget {
  const _Stat({required this.value, required this.label, required this.color});

  final String value;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final tk = context.tokens;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Text(value, style: TextStyle(color: color, fontSize: 17, fontWeight: FontWeight.w600)),
        const SizedBox(height: 2),
        Text(label, style: TextStyle(color: tk.textMuted, fontSize: 10)),
      ],
    );
  }
}
