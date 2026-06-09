import 'package:flutter/foundation.dart' show listEquals;
import 'package:flutter/material.dart';
import '../theme.dart';
import '../widgets/ratel_mascot.dart';
import '../models.dart';
import '../app_state.dart';

/// Runs a learner through every exercise in a [Lesson], then shows a
/// completion summary. Handles multiple-choice and word-bank exercises.
class LessonScreen extends StatefulWidget {
  final Lesson lesson;
  const LessonScreen({super.key, required this.lesson});

  @override
  State<LessonScreen> createState() => _LessonScreenState();
}

class _LessonScreenState extends State<LessonScreen> {
  int _index = 0;
  int _correctCount = 0;
  bool _answered = false;
  bool _isCorrect = false;
  bool _finished = false;

  int? _selected; // choice
  final List<int> _picked = []; // word-bank: option indices in chosen order

  Exercise get _ex => widget.lesson.exercises[_index];
  bool get _isLast => _index == widget.lesson.exercises.length - 1;

  void _check() {
    final bool correct;
    if (_ex.type == ExerciseType.choice) {
      correct = _selected == _ex.correctIndex;
    } else {
      final chosen = _picked.map((i) => _ex.options[i]).toList();
      correct = listEquals(chosen, _ex.correctOrder);
    }
    setState(() {
      _answered = true;
      _isCorrect = correct;
      if (correct) {
        _correctCount++;
      } else {
        appState.loseHeart();
      }
    });
  }

  void _next() {
    if (!_isLast) {
      setState(() {
        _index++;
        _answered = false;
        _isCorrect = false;
        _selected = null;
        _picked.clear();
      });
    } else {
      appState.completeLesson(widget.lesson.id, _correctCount * 10);
      setState(() => _finished = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_finished) return _completion(context);
    final int total = widget.lesson.exercises.length;
    final double progress = (_answered ? _index + 1 : _index) / total;
    return Scaffold(
      body: SafeArea(
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
                      child: LinearProgressIndicator(
                        value: progress,
                        minHeight: 12,
                        backgroundColor: const Color(0xFFE6E6E6),
                        color: RatelColors.teal,
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
                  RatelMascot(pose: _pose(), size: 84),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: RatelColors.surface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFE0E0E0)),
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
                child: SingleChildScrollView(
                  child: _ex.type == ExerciseType.choice
                      ? _choiceBody()
                      : _wordBankBody(),
                ),
              ),
              _bottom(),
            ],
          ),
        ),
      ),
    );
  }

  RatelPose _pose() {
    if (!_answered) return RatelPose.speak;
    return _isCorrect ? RatelPose.celebrate : RatelPose.oops;
  }

  String _bubble() {
    if (!_answered) return _ex.prompt;
    return _isCorrect ? 'Nice — fearless!' : 'No fear — that is how we learn.';
  }

  String _correctText() {
    if (_ex.type == ExerciseType.choice) return _ex.options[_ex.correctIndex];
    return _ex.correctOrder.join(' ');
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
    Color border = const Color(0xFFD8D8D8);
    Color fill = RatelColors.surface;
    double width = 1;
    if (_answered && i == _ex.correctIndex) {
      border = RatelColors.teal;
      fill = const Color(0xFFE1F5EE);
      width = 2;
    } else if (_answered && i == _selected) {
      border = RatelColors.coral;
      fill = const Color(0xFFFAECE7);
      width = 2;
    } else if (!_answered && i == _selected) {
      border = const Color(0xFF378ADD);
      fill = const Color(0xFFE6F1FB);
      width = 2;
    }
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        onTap: _answered ? null : () => setState(() => _selected = i),
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
        : const Color(0xFFE0E0E0);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          constraints: const BoxConstraints(minHeight: 58),
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: RatelColors.surface,
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

  Widget _tile(String text, {VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: RatelColors.surface,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xFFD8D8D8)),
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
          : _picked.isNotEmpty;
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
    final int earned = _correctCount * 10;
    final int total = widget.lesson.exercises.length;
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const RatelMascot(pose: RatelPose.celebrate, size: 170),
                const SizedBox(height: 16),
                const Text('Lesson complete!',
                    style:
                        TextStyle(fontSize: 24, fontWeight: FontWeight.w700)),
                const SizedBox(height: 8),
                TweenAnimationBuilder<int>(
                  tween: IntTween(begin: 0, end: earned),
                  duration: const Duration(milliseconds: 700),
                  builder: (context, value, _) => Text(
                    '+$value XP   ·   $_correctCount / $total correct',
                    style: const TextStyle(
                        color: RatelColors.textMuted, fontSize: 16),
                  ),
                ),
                const SizedBox(height: 28),
                _wideButton('Continue', () => Navigator.of(context).maybePop()),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
