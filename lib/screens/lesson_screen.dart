import 'dart:math';
import 'package:flutter/foundation.dart' show listEquals;
import 'package:flutter/material.dart';
import '../widgets/mascot_anim.dart';
import '../theme.dart';
import '../widgets/ratel_mascot.dart';
import '../widgets/confetti.dart';
import '../widgets/streak_flame.dart';
import '../widgets/combo_glow.dart';
import '../models.dart';
import '../typed_match.dart';
import '../tts.dart';
import '../app_state.dart';
import '../sfx.dart';
import '../analytics.dart';
import '../explain_store.dart';
import '../config.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Runs a learner through every exercise in a [Lesson], then shows a
/// completion summary. Handles multiple-choice and word-bank exercises.
class LessonScreen extends StatefulWidget {
  final Lesson lesson;
  final bool reviewMode; // review drill: no XP/completion side effects
  final List<String>? sourceKeys; // original 'lessonId:exIdx' per review item
  const LessonScreen({
    super.key,
    required this.lesson,
    this.reviewMode = false,
    this.sourceKeys,
  });

  @override
  State<LessonScreen> createState() => _LessonScreenState();
}

class _LessonScreenState extends State<LessonScreen>
    with SingleTickerProviderStateMixin {
  int _index = 0;
  int _correctCount = 0;
  bool _answered = false;
  bool _isCorrect = false;
  bool _finished = false;

  int? _selected; // choice
  final List<int> _picked = []; // word-bank: option indices in chosen order
  final TextEditingController _typedCtl =
      TextEditingController(); // typed answer
  int _combo = 0; // in-lesson correct streak -> drives the escalation glow
  String? _explanation; // explanation for a wrong answer (local bundle, then on-demand)
  bool _explaining = false;
  int _bonusXp = 0; // occasional surprise bonus on completion

  late final AnimationController _fb; // answer feedback: pop on right, shake on wrong

  @override
  void initState() {
    super.initState();
    _fb = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 420));
    Analytics.lessonStart(widget.lesson.id);
    Sfx.instance.resetCombo();
    WidgetsBinding.instance.addPostFrameCallback((_) => _speakListen());
  }

  @override
  void dispose() {
    _fb.dispose();
    _typedCtl.dispose();
    super.dispose();
  }

  Exercise get _ex => widget.lesson.exercises[_index];
  bool get _isLast => _index == widget.lesson.exercises.length - 1;

  void _check() {
    final bool correct;
    if (_ex.type == ExerciseType.choice) {
      correct = _selected == _ex.correctIndex;
    } else if (_ex.type == ExerciseType.wordBank) {
      final chosen = _picked.map((i) => _ex.options[i]).toList();
      correct = listEquals(chosen, _ex.correctOrder);
    } else {
      correct = typedAnswerMatches(_typedCtl.text, _ex.correctOrder);
    }
    setState(() {
      _answered = true;
      _isCorrect = correct;
      if (correct) {
        _correctCount++;
        _combo++;
      } else {
        _combo = 0;
        appState.loseHeart();
      }
    });
    if (correct) {
      Sfx.instance.correct();
    } else {
      Sfx.instance.wrong();
    }
    _fb.forward(from: 0);
    final srcKey = (widget.sourceKeys != null &&
            _index < widget.sourceKeys!.length)
        ? widget.sourceKeys![_index]
        : '${widget.lesson.id}:$_index';
    final kp = srcKey.split(':');
    appState.logAttempt(
      lessonId: kp.isNotEmpty ? kp[0] : widget.lesson.id,
      exerciseIndex: kp.length > 1 ? (int.tryParse(kp[1]) ?? _index) : _index,
      prompt: _ex.prompt,
      chosen: _userText(),
      correctAnswer: _correctText(),
      isCorrect: correct,
    );
    appState.recordReview(srcKey, correct);
  }

  void _next() {
    if (!_isLast) {
      setState(() {
        _index++;
        _answered = false;
        _isCorrect = false;
        _selected = null;
        _picked.clear();
        _typedCtl.clear();
        _explanation = null;
        _explaining = false;
      });
      _speakListen();
    } else {
      if (!widget.reviewMode) {
        _bonusXp = Random().nextInt(5) == 0 ? (5 + Random().nextInt(16)) : 0;
        final total = _correctCount * 10 + _bonusXp;
        appState.completeLesson(widget.lesson.id, total);
        Analytics.lessonComplete(widget.lesson.id, total, _correctCount,
            widget.lesson.exercises.length);
      }
      Sfx.instance.complete();
      setState(() => _finished = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_finished) return _completion(context);
    final int total = widget.lesson.exercises.length;
    final double progress = (_answered ? _index + 1 : _index) / total;
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.of(context).maybePop(),
                    icon: const Icon(Icons.close, color: RatelColors.textMuted),
                  ),
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: TweenAnimationBuilder<double>(
                        tween: Tween(begin: 0, end: progress),
                        duration: const Duration(milliseconds: 450),
                        curve: Curves.easeOutCubic,
                        builder: (context, value, _) => LinearProgressIndicator(
                          value: value,
                          minHeight: 12,
                          backgroundColor: context.borderC,
                          color: RatelColors.teal,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Icon(Icons.favorite, color: RatelColors.hearts, size: 20),
                  const SizedBox(width: 3),
                  Text('${appState.hearts}',
                      style: const TextStyle(
                          color: RatelColors.hearts, fontWeight: FontWeight.w600)),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  (_answered &&
                          _isCorrect &&
                          Sfx.instance.combo.value >= 5)
                      ? const RatelActionAnim(
                          action: 'karate',
                          fallbackPose: RatelPose.celebrate,
                          size: 84)
                      : RatelMascot(pose: _pose(), size: 84),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: context.surfaceC,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: context.borderC),
                      ),
                      child: Text(_bubble()),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              if (_ex.sentence != null) ...[
                Text(_ex.sentence!,
                    style: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.w600)),
                const SizedBox(height: 16),
              ],
              Expanded(
                child: AnimatedBuilder(
                  animation: _fb,
                  builder: (context, child) => _feedbackWrap(child!),
                  child: SingleChildScrollView(
                    child: _ex.type == ExerciseType.choice
                        ? _choiceBody()
                        : _ex.type == ExerciseType.listen
                            ? _listenBody()
                            : _ex.type == ExerciseType.wordBank
                                ? _wordBankBody()
                                : _typedBody(),
                  ),
                ),
              ),
              _bottom(),
            ],
          ),
        ),
          ),
          IgnorePointer(child: ComboGlow(combo: _combo)),
        ],
      ),
    );
  }

  /// Brief pop on a correct answer, a quick horizontal shake on a wrong one.
  Widget _feedbackWrap(Widget child) {
    final v = _fb.value;
    if (v == 0) return child;
    if (_isCorrect) {
      return Transform.scale(scale: 1 + 0.06 * sin(pi * v), child: child);
    }
    return Transform.translate(
        offset: Offset(sin(v * pi * 4) * 8 * (1 - v), 0), child: child);
  }

  RatelPose _pose() {
    if (!_answered) {
      return switch (_ex.type) {
        ExerciseType.typed => RatelPose.think,
        ExerciseType.listen => RatelPose.speak,
        _ => RatelPose.point,
      };
    }
    return _isCorrect ? RatelPose.celebrate : RatelPose.oops;
  }

  String _bubble() {
    if (!_answered) return _ex.prompt;
    return _isCorrect ? 'Nice — fearless!' : 'No fear — that is how we learn.';
  }

  String _correctText() {
    if (_ex.type == ExerciseType.choice) return _ex.options[_ex.correctIndex];
    if (_ex.type == ExerciseType.typed || _ex.type == ExerciseType.listen) {
      return _ex.correctOrder.isNotEmpty ? _ex.correctOrder.first : '';
    }
    return _ex.correctOrder.join(' ');
  }

  String _userText() {
    if (_ex.type == ExerciseType.choice) {
      return _selected != null ? _ex.options[_selected!] : '(no answer)';
    }
    if (_ex.type == ExerciseType.typed || _ex.type == ExerciseType.listen) {
      final t = _typedCtl.text.trim();
      return t.isEmpty ? '(no answer)' : t;
    }
    return _picked.map((i) => _ex.options[i]).join(' ');
  }

  /// Explain a wrong answer: the bundled asset first (free/offline), then a
  /// one-time server generate-and-cache for content not in the bundle.
  Future<void> _explain() async {
    final key = _ex.type == ExerciseType.choice
        ? '${widget.lesson.id}:$_index:$_selected'
        : _ex.type == ExerciseType.wordBank
            ? '${widget.lesson.id}:$_index:wb'
            : '${widget.lesson.id}:$_index:ty';
    // Bundled seed first: free, instant, offline; covers all current content.
    final local = ExplainStore.instance.lookup(key);
    if (local != null) {
      setState(() => _explanation = local);
      return;
    }
    // New content such as a DB-added lesson: generate-on-demand, cached
    //    server-side so it costs at most one LLM call ever for that exercise.
    if (!Config.hasSupabase) {
      setState(() => _explanation = 'The correct answer is "${_correctText()}".');
      return;
    }
    setState(() => _explaining = true);
    try {
      final res = await Supabase.instance.client.functions.invoke(
        'explain-answer',
        body: {
          'key': key,
          'prompt': _ex.prompt,
          'userAnswer': _userText(),
          'correctAnswer': _correctText(),
        },
      );
      final data = res.data;
      final text = (data is Map && data['explanation'] is String)
          ? (data['explanation'] as String).trim()
          : '';
      if (!mounted) return;
      setState(() {
        _explanation = text.isNotEmpty
            ? text
            : 'The correct answer is "${_correctText()}".';
        _explaining = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _explanation = 'The correct answer is "${_correctText()}".';
        _explaining = false;
      });
    }
  }

  Widget _explainBlock() {
    if (_explanation != null) {
      return Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: context.tintC(RatelColors.honey),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
              color: RatelColors.honey.withValues(
                  alpha: context.isDark ? 0.5 : 0.35)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.auto_awesome, color: RatelColors.honey, size: 18),
            const SizedBox(width: 8),
            Expanded(child: Text(_explanation!)),
          ],
        ),
      );
    }
    if (_explaining) {
      return const Padding(
        padding: EdgeInsets.only(bottom: 10),
        child: Row(
          children: [
            SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2)),
            SizedBox(width: 10),
            Text('Ratel is thinking…',
                style: TextStyle(color: RatelColors.textMuted)),
          ],
        ),
      );
    }
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: OutlinedButton.icon(
        onPressed: _explain,
        icon: const Icon(Icons.auto_awesome, size: 18),
        label: const Text('Explain this'),
      ),
    );
  }

  // ---- choice ----
  Widget _choiceBody() {
    return Column(
      children: [
        for (int i = 0; i < _ex.options.length; i++) _optionTile(i),
      ],
    );
  }

  Widget _optionTile(int i) {
    Color border = context.faintBorderC;
    Color fill = context.surfaceC;
    double width = 1;
    if (_answered && i == _ex.correctIndex) {
      border = RatelColors.teal;
      fill = context.tintC(RatelColors.teal);
      width = 2;
    } else if (_answered && i == _selected) {
      border = RatelColors.coral;
      fill = context.tintC(RatelColors.coral);
      width = 2;
    } else if (!_answered && i == _selected) {
      border = const Color(0xFF378ADD);
      fill = context.tintC(const Color(0xFF378ADD));
      width = 2;
    }
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        onTap: _answered
            ? null
            : () {
                Sfx.instance.tap();
                setState(() => _selected = i);
              },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: fill,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: border, width: width),
          ),
          child: Text(_ex.options[i], style: const TextStyle(fontSize: 16)),
        ),
      ),
    );
  }

  // ---- word bank ----
  Widget _wordBankBody() {
    final available = [
      for (int i = 0; i < _ex.options.length; i++)
        if (!_picked.contains(i)) i
    ];
    final Color answerBorder = _answered
        ? (_isCorrect ? RatelColors.teal : RatelColors.coral)
        : context.borderC;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          constraints: const BoxConstraints(minHeight: 58),
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: context.surfaceC,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: answerBorder, width: _answered ? 2 : 1),
          ),
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final idx in _picked)
                _tile(_ex.options[idx],
                    onTap: _answered
                        ? null
                        : () => setState(() => _picked.remove(idx))),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final idx in available)
              _tile(_ex.options[idx],
                  onTap: _answered
                      ? null
                      : () => setState(() => _picked.add(idx))),
          ],
        ),
      ],
    );
  }

  // ---- typed ----
  Widget _typedField(String hint) {
    return TextField(
      key: const Key('typed-field'),
      controller: _typedCtl,
      enabled: !_answered,
      autocorrect: false,
      enableSuggestions: false,
      textInputAction: TextInputAction.done,
      onChanged: (_) => setState(() {}),
      onSubmitted: (_) {
        if (!_answered && _typedCtl.text.trim().isNotEmpty) _check();
      },
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: context.surfaceC,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: context.faintBorderC),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: context.faintBorderC),
        ),
      ),
      style: const TextStyle(fontSize: 18),
    );
  }

  Widget _typedBody() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [_typedField('Type your answer')],
    );
  }

  // ---- listen ("type what you hear") ----
  void _speakListen() {
    if (_ex.type == ExerciseType.listen && _ex.correctOrder.isNotEmpty) {
      Tts.instance.speak(_ex.correctOrder.first);
    }
  }

  Widget _listenBody() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 18),
            child: FilledButton.icon(
              onPressed: () {
                Sfx.instance.tap();
                _speakListen();
              },
              style: FilledButton.styleFrom(
                backgroundColor: RatelColors.honey,
                padding:
                    const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
              ),
              icon: const Icon(Icons.volume_up, size: 26),
              label: const Text('Play', style: TextStyle(fontSize: 18)),
            ),
          ),
        ),
        _typedField('Type what you hear'),
      ],
    );
  }

  Widget _tile(String text, {VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: context.surfaceC,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: context.faintBorderC),
        ),
        child: Text(text, style: const TextStyle(fontSize: 16)),
      ),
    );
  }

  // ---- bottom bar ----
  Widget _bottom() {
    if (!_answered) {
      final bool canCheck = _ex.type == ExerciseType.choice
          ? _selected != null
          : _ex.type == ExerciseType.wordBank
              ? _picked.isNotEmpty
              : _typedCtl.text.trim().isNotEmpty;
      return _wideButton('Check', canCheck ? _check : null);
    }
    final Color c = _isCorrect ? RatelColors.teal : RatelColors.coral;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Icon(_isCorrect ? Icons.check_circle : Icons.cancel, color: c),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                _isCorrect ? 'Correct!' : 'Answer: ${_correctText()}',
                style: TextStyle(color: c, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        if (!_isCorrect) _explainBlock(),
        _wideButton(_isLast ? 'Finish' : 'Continue', _next),
      ],
    );
  }

  Widget _wideButton(String label, VoidCallback? onPressed) {
    return SizedBox(
      width: double.infinity,
      child: FilledButton(
        style: FilledButton.styleFrom(
          backgroundColor: RatelColors.teal,
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
        onPressed: onPressed,
        child: Text(label),
      ),
    );
  }

  // ---- completion ----
  Widget _completion(BuildContext context) {
    final int earned = _correctCount * 10 + _bonusXp;
    final int total = widget.lesson.exercises.length;
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            Positioned.fill(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      TweenAnimationBuilder<double>(
                        tween: Tween(begin: 0.6, end: 1.0),
                        duration: const Duration(milliseconds: 700),
                        curve: Curves.elasticOut,
                        builder: (context, s, child) =>
                            Transform.scale(scale: s, child: child),
                        child: context.reduceMotion
                            ? const RatelMascot(
                                pose: RatelPose.celebrate, size: 170)
                            // AI-generated 6-frame celebration loop
                            // (Gemini image frames -> animated WebP).
                            : Image.asset('assets/images/ratel-jump.webp',
                                width: 170,
                                height: 170,
                                filterQuality: FilterQuality.medium),
                      ),
                      const SizedBox(height: 16),
                      Text(widget.reviewMode ? 'Review complete!' : 'Lesson complete!',
                          style: const TextStyle(
                              fontSize: 24, fontFamily: kDisplayFont, fontWeight: FontWeight.w700)),
                      const SizedBox(height: 8),
                      widget.reviewMode
                          ? Text('$_correctCount / $total correct',
                              style: const TextStyle(
                                  color: RatelColors.textMuted, fontSize: 16))
                          : TweenAnimationBuilder<int>(
                              tween: IntTween(begin: 0, end: earned),
                              duration: const Duration(milliseconds: 1200),
                              curve: Curves.easeOutCubic,
                              builder: (context, value, _) => Text(
                                '+$value XP   ·   $_correctCount / $total correct',
                                style: const TextStyle(
                                    color: RatelColors.textMuted, fontSize: 16),
                              ),
                            ),
                      if (_bonusXp > 0) ...[
                        const SizedBox(height: 6),
                        Text('🎁 Surprise bonus +$_bonusXp XP!',
                            style: const TextStyle(
                                color: RatelColors.coral,
                                fontWeight: FontWeight.w700)),
                      ],
                      const SizedBox(height: 18),
                      SizedBox(
                        width: 240,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: TweenAnimationBuilder<double>(
                            tween: Tween(begin: 0.0, end: 1.0),
                            duration: const Duration(milliseconds: 1400),
                            curve: Curves.easeOutBack,
                            builder: (context, v, _) => LinearProgressIndicator(
                              value: v.clamp(0.0, 1.0),
                              minHeight: 10,
                              backgroundColor: context.borderC,
                              color: RatelColors.honey,
                            ),
                          ),
                        ),
                      ),
                      if (!widget.reviewMode && appState.streak > 0) ...[
                        const SizedBox(height: 16),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            StreakFlame(streak: appState.streak, size: 24),
                            const SizedBox(width: 6),
                            Text('${appState.streak}-day streak',
                                style: const TextStyle(
                                    color: RatelColors.coral,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 15)),
                          ],
                        ),
                      ],
                      const SizedBox(height: 28),
                      _wideButton(
                          'Continue', () => Navigator.of(context).maybePop()),
                    ],
                  ),
                ),
              ),
            ),
            const Positioned.fill(child: ConfettiBurst(count: 140)),
          ],
        ),
      ),
    );
  }
}
