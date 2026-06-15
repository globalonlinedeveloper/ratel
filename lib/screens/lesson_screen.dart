import '../guest.dart';
import '../widgets/save_account_sheet.dart';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../content.dart';
import '../exercise_kit.dart';
import '../art.dart';
import '../exercise_art.dart';
import '../exercise_audio.dart';
import '../widgets/ratel_art.dart';
import '../flags.dart';
import '../strings.dart';
import '../push.dart';
import '../widgets/battle_stage.dart';
import '../widgets/milestone_card.dart';
import '../milestones.dart';
import '../achievements.dart';
import 'dart:math' as math;
import 'package:shared_preferences/shared_preferences.dart';
import '../widgets/mascot_anim.dart';
import '../widgets/completion_mascot.dart';
import '../theme.dart';
import '../widgets/ratel_mascot.dart';
import '../widgets/confetti.dart';
import '../widgets/streak_flame.dart';
import '../widgets/stagger.dart';
import '../widgets/combo_glow.dart';
import '../models.dart';
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
  int _index = 0; // position in the PLAYLIST (not the exercise list)
  late List<int> _playlist =
      List<int>.generate(widget.lesson.exercises.length, (i) => i);
  bool _fixPhase = false; // replaying first-pass mistakes (no hearts)
  final List<int> _missedFirstPass = [];
  final Map<int, int> _fixAttempts = {};
  final DateTime _startedAt = DateTime.now();
  Duration _elapsed = Duration.zero;
  int _correctCount = 0;
  bool _answered = false;
  bool _isCorrect = false;
  int _missStreak = 0;
  String? _reaction;
  bool _firstToday = false;
  bool _newBadge = false;
  bool _unitDone = false;
  final math.Random _rng = math.Random();
  final BattleController _battle = BattleController();
  bool _isBoss = false;
  String _villain = 'cobra';
  bool _finished = false;
  // Inc 157: object-art vocab index (built once; empty offline).
  final Map<String, String> _vocab = buildVocab(Art.instance.manifestPaths);

  int? _selected; // choice
  List<int> _order = const []; // shuffled display order (choice)
  int? _mLeft; // match-pairs: selected left item (original index)
  Set<int> _mDone = {}; // match-pairs: locked pairs
  List<int> _mLO = const [], _mRO = const []; // column shuffles
  final List<int> _picked = []; // word-bank: option indices in chosen order
  final TextEditingController _typedCtl =
      TextEditingController(); // typed answer
  int _combo = 0; // in-lesson correct streak -> drives the escalation glow
  String? _explanation; // explanation for a wrong answer (local bundle, then on-demand)
  bool _explaining = false;
  int _bonusXp = 0; // occasional surprise bonus on completion
  int _gemsEarned = 0; // combo milestones + flawless bonus
  bool _boosted = false; // timed XP-boost window (chest / comeback)
  int _boostMult = 2; // written by whoever lit the boost (chest 2, comeback 3)
  late final int _scoreBefore; // captured EAGERLY in initState

  late final AnimationController _fb; // answer feedback: pop on right, shake on wrong

  @override
  void initState() {
    super.initState();
    _scoreBefore = _scoreNow(); // late-final-on-access would have
    // captured the POST-completion score (the delta chip's bug)
    _applyListenPref();
    SharedPreferences.getInstance().then((p) {
      final until =
          DateTime.tryParse(p.getString('xp_boost_until') ?? '');
      if (mounted && boostActive(until, DateTime.now())) {
        setState(() {
          _boosted = true;
          _boostMult = p.getInt('xp_boost_mult') ?? 2;
        });
      }
    });
    for (int u = 0; u < course.length; u++) {
      final unit = course[u];
      if (unit.lessons.any((l) => l.id == widget.lesson.id)) {
        _villain =
            villainFor(u, Flags.instance.str('event_villain', ''));
        if (unit.lessons.last.id == widget.lesson.id) _isBoss = true;
      }
    }
    SharedPreferences.getInstance().then((prefs) {
      final String today =
          DateTime.now().toIso8601String().substring(0, 10);
      if (prefs.getString('last_open_day') != today) {
        prefs.setString('last_open_day', today);
        if (mounted) setState(() => _firstToday = true);
      }
    });
    _fb = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 420));
    Analytics.lessonStart(widget.lesson.id);
    Sfx.instance.resetCombo();
    WidgetsBinding.instance.addPostFrameCallback((_) => _speakListen());
  }

  @override
  void dispose() {
    _battle.dispose();
    _fb.dispose();
    _typedCtl.dispose();
    super.dispose();
  }

  int get _eIdx => _playlist[_index]; // real exercise index
  Exercise get _ex => widget.lesson.exercises[_eIdx];
  bool get _isLast => _index == _playlist.length - 1;

  void _check() {
    final bool correct = gradeAnswer(_ex,
        selected: _selected,
        pickedWords: [for (final i in _picked) _ex.options[i]],
        typed: _typedCtl.text);
    setState(() {
      _answered = true;
      _isCorrect = correct;
      if (correct) {
        _missStreak = 0;
        _reaction =
            pickReaction(Sfx.instance.combo.value, _rng.nextInt(12));
      } else {
        _missStreak++;
        _reaction = null;
      }
      if (battleModeNotifier.value && !widget.reviewMode) {
        final int combo = Sfx.instance.combo.value;
        if (correct) {
          _battle.fire(
              combo >= 5 ? BattleEvent.finisher : BattleEvent.correct,
              combo: combo);
        } else if (appState.hearts <= 0 && !appState.isPro) {
          _battle.fire(BattleEvent.defeat, combo: combo);
        } else {
          _battle.fire(BattleEvent.wrong, combo: combo);
        }
      }
      if (correct) {
        if (!_fixPhase) _correctCount++;
        _combo++;
        if (!_fixPhase && !widget.reviewMode) {
          _gemsEarned += comboGemBonus(_combo); // first pass only
        }
      } else {
        _combo = 0;
        if (_fixPhase) {
          // mercy mode: no hearts at risk; try the item again (max 2)
          final a = (_fixAttempts[_eIdx] ?? 0) + 1;
          _fixAttempts[_eIdx] = a;
          if (a < 2) _playlist.add(_eIdx);
        } else {
          _missedFirstPass.add(_eIdx);
          appState.loseHeart();
        }
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
    if (_isLast &&
        !_fixPhase &&
        !widget.reviewMode &&
        _missedFirstPass.isNotEmpty) {
      // the honey badger never leaves a fight unfinished
      _playlist = [..._playlist, ..._missedFirstPass];
      _missedFirstPass.clear();
      _fixPhase = true;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.fromLTRB(RatelSpacing.lg, 0, RatelSpacing.lg, 96),
          duration: const Duration(milliseconds: 2200),
          content: Text(S.instance.t('fix_phase_toast',
              "Let's fix your mistakes — no hearts at risk!"))));
    }
    if (!_isLast) {
      setState(() {
        _index++;
        _answered = false;
        _isCorrect = false;
        _selected = null;
        _picked.clear();
        _order = const [];
        _mLeft = null;
        _mDone = {};
        _mLO = const [];
        _mRO = const [];
        _typedCtl.clear();
        _explanation = null;
        _explaining = false;
      });
      _speakListen();
    } else {
      if (!widget.reviewMode) {
        final oneIn = max(1, Flags.instance.intOf('xp_bonus_one_in', 5));
        _bonusXp =
            Random().nextInt(oneIn) == 0 ? (5 + Random().nextInt(16)) : 0;
        final total =
            (_correctCount * 10 + _bonusXp) * (_boosted ? _boostMult : 1);
        final int badgesBefore =
            achievements.where((a) => isEarned(a, appState)).length;
        appState.completeLesson(widget.lesson.id, total);
        _battle.fire(BattleEvent.victory);
        Push.instance.requestOnce();
        _newBadge =
            achievements.where((a) => isEarned(a, appState)).length >
                badgesBefore;
        _unitDone = course.any((u) =>
            u.lessons.any((l) => l.id == widget.lesson.id) &&
            u.lessons.every((l) => appState.isCompleted(l.id)));
        Analytics.lessonComplete(widget.lesson.id, total, _correctCount,
            widget.lesson.exercises.length);
      } else {
        appState.earnHeart(); // practicing your mistakes restores one
      }
      _elapsed = DateTime.now().difference(_startedAt);
      if (!widget.reviewMode &&
          _correctCount >= widget.lesson.exercises.length) {
        _gemsEarned += 5; // flawless first pass
      }
      if (_gemsEarned > 0) appState.addGems(_gemsEarned);
      Sfx.instance.complete();
      setState(() => _finished = true);
    }
  }

  Widget _chatBody() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            const ExcludeSemantics(child: RatelMascot(pose: RatelPose.speak, size: 52)),
            const SizedBox(width: RatelSpacing.sm),
            Flexible(
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: context.tintC(RatelColors.honey),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(14),
                    topRight: Radius.circular(14),
                    bottomRight: Radius.circular(14),
                    bottomLeft: Radius.circular(4),
                  ),
                  border: Border.all(color: context.faintBorderC),
                ),
                child: Text(_ex.sentence ?? '',
                    style: const TextStyle(fontSize: 16)),
              ),
            ),
            if (_audioOn && (_ex.sentence ?? '').trim().isNotEmpty)
              _speakerButton(spokenText(_ex.sentence!)),
          ],
        ),
        const SizedBox(height: RatelSpacing.lg),
        _typedField(S.instance.t('chat_hint', 'Type your reply')),
      ],
    );
  }

  bool get _canCheck => canCheckAnswer(_ex,
      selected: _selected,
      pickedCount: _ex.type == ExerciseType.matchPairs
          ? _mDone.length
          : _picked.length, // dialogue uses _picked too
      typed: _typedCtl.text);

  /// Keyboard (web/desktop): 1-4 pick a choice, Enter checks / continues.
  KeyEventResult _onKey(FocusNode node, KeyEvent e) {
    if (e is! KeyDownEvent || _finished) return KeyEventResult.ignored;
    final k = e.logicalKey;
    if (k == LogicalKeyboardKey.enter ||
        k == LogicalKeyboardKey.numpadEnter) {
      if (_answered) {
        _next();
        return KeyEventResult.handled;
      }
      if (_canCheck) {
        _check();
        return KeyEventResult.handled;
      }
      return KeyEventResult.ignored;
    }
    if (_answered || _ex.type != ExerciseType.choice) {
      return KeyEventResult.ignored;
    }
    const digits = [
      LogicalKeyboardKey.digit1,
      LogicalKeyboardKey.digit2,
      LogicalKeyboardKey.digit3,
      LogicalKeyboardKey.digit4,
    ];
    final d = digits.indexOf(k);
    if (d >= 0 && d < _ex.options.length) {
      Sfx.instance.tap();
      setState(() => _selected = _ensureOrder(_ex.options.length)[d]);
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  /// X / system back with progress at stake: a gentle confirm first.
  Future<void> _confirmQuit() async {
    final bool? quit = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(S.instance.t('quit_title', "Wait, don't go!")),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ExcludeSemantics(child: Image.asset('assets/images/ratel-crying-anim.webp',
                width: 96,
                height: 96,
                errorBuilder: (_, _, _) => const SizedBox(height: RatelSpacing.sm))),
            const SizedBox(height: 10),
            Text(S.instance.t('quit_body',
                "Quit now and this lesson's progress is gone.")),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(S.instance.t('btn_quit', 'Quit')),
          ),
          FilledButton(
            style:
                FilledButton.styleFrom(backgroundColor: RatelColors.teal),
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(S.instance.t('btn_keep', 'Keep learning')),
          ),
        ],
      ),
    );
    if (quit == true && mounted) Navigator.of(context).pop();
  }

  /// Skip = an escape hatch, not a failure: reveal the answer, charge no
  /// heart, and (first pass) queue the item for the fix phase.
  void _skip() {
    Sfx.instance.tap();
    setState(() {
      _answered = true;
      _isCorrect = false;
      _combo = 0;
      _reaction = null;
      if (_fixPhase) {
        final a = (_fixAttempts[_eIdx] ?? 0) + 1;
        _fixAttempts[_eIdx] = a;
        if (a < 2) _playlist.add(_eIdx);
      } else if (!widget.reviewMode) {
        _missedFirstPass.add(_eIdx);
      }
    });
  }

  /// "Can't listen right now": reveal this one kindly (no penalty, no
  /// queue) and drop every not-yet-played listening item from the lesson.
  void _muteListens() {
    Sfx.instance.tap();
    setState(() {
      final ex = widget.lesson.exercises;
      _playlist = [
        for (int k = 0; k < _playlist.length; k++)
          if (k <= _index ||
              ex[_playlist[k]].type != ExerciseType.listen)
            _playlist[k]
      ];
      _missedFirstPass
          .removeWhere((i) => ex[i].type == ExerciseType.listen);
      _answered = true;
      _isCorrect = false;
      _combo = 0;
      _reaction = null;
    });
  }

  /// Persistent Profile switch: listening exercises off filters them out
  /// of the playlist before the first answer.
  Future<void> _applyListenPref() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (prefs.getBool('listen_on') ?? true) return;
      if (!mounted || _index > 0 || _answered) return;
      setState(() {
        final ex = widget.lesson.exercises;
        final keep = [
          for (final i in _playlist)
            if (ex[i].type != ExerciseType.listen) i
        ];
        if (keep.isNotEmpty) _playlist = keep;
      });
    } catch (_) {}
  }

  /// Inc 157: a small topic illustration above the prompt for SAFE exercise
  /// types when a content word maps to a promoted art cell. Flag-gated
  /// (`exercise_art`) + graceful: no match => nothing, so grammar items and
  /// answer-revealing types are never illustrated.
  List<Widget> _exerciseArtHeader() {
    if (!Flags.instance.flag('exercise_art', true)) return const [];
    final name = exerciseArt(_ex, _vocab);
    if (name == null) return const [];
    return [
      Center(child: RatelArt(name, height: 92)),
      const SizedBox(height: RatelSpacing.md),
    ];
  }

  /// Inc 159: a recap strip of the object concepts practiced in this lesson,
  /// shown on the completion screen. Reuses the Inc-157 vocab index but scans
  /// the whole finished lesson (no answer left to reveal). Flag-gated
  /// (`concepts_strip`) + graceful: no matched concepts => nothing.
  List<Widget> _conceptsStrip() {
    if (!Flags.instance.flag('concepts_strip', true)) return const [];
    final names = lessonConcepts(widget.lesson.exercises, _vocab);
    if (names.isEmpty) return const [];
    return [
      const SizedBox(height: 18),
      Text(
        S.instance.t('concepts_practiced', 'Concepts you practiced'),
        style: const TextStyle(
            color: RatelColors.textMuted,
            fontWeight: FontWeight.w600,
            fontSize: 14),
      ),
      const SizedBox(height: 10),
      Wrap(
        spacing: 12,
        runSpacing: 10,
        alignment: WrapAlignment.center,
        children: [for (final n in names) RatelArt(n, height: 52)],
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    if (_finished) return _completion(context);
    final int total = _playlist.length;
    final double progress = (_answered ? _index + 1 : _index) / total;
    return Focus(
      autofocus: true,
      onKeyEvent: _onKey,
      child: PopScope(
        canPop: _index == 0 && !_answered && !_fixPhase,
        onPopInvokedWithResult: (didPop, _) {
          if (!didPop) _confirmQuit();
        },
        child: Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(RatelSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  IconButton(
                    tooltip: S.instance.t('btn_close', 'Close'),
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
                  const SizedBox(width: 10),
                  Text('${_index + 1}/$total',
                      style: const TextStyle(
                          color: RatelColors.textMuted,
                          fontSize: 12,
                          fontWeight: FontWeight.w700)),
                  if (_fixPhase) ...[
                    const SizedBox(width: RatelSpacing.sm),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                          color: context.tintC(RatelColors.fixChip),
                          borderRadius: BorderRadius.circular(12)),
                      child: Text(
                          S.instance.t('fix_chip', 'FIXING MISTAKES'),
                          style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              color: RatelColors.fixChip)),
                    ),
                  ],
                  if (_combo >= 2) ...[
                    const SizedBox(width: RatelSpacing.sm),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                          color: context.tintC(RatelColors.honey),
                          borderRadius: BorderRadius.circular(12)),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.local_fire_department,
                              size: 14, color: RatelColors.honey),
                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 220),
                            transitionBuilder: (child, anim) => ScaleTransition(
                                scale: anim, child: child),
                            child: Text('×$_combo',
                                key: ValueKey<int>(_combo),
                                style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w800,
                                    color: RatelColors.honey)),
                          ),
                        ],
                      ),
                    ),
                  ],
                  if (_boosted) ...[
                    const SizedBox(width: 6),
                    const Icon(Icons.flash_on,
                        size: 16, color: RatelColors.coral),
                  ],
                  if (_answered &&
                      _isCorrect &&
                      !_fixPhase &&
                      !widget.reviewMode &&
                      comboGemBonus(_combo) > 0) ...[
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                          color: context.tintC(RatelColors.teal),
                          borderRadius: BorderRadius.circular(12)),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.diamond,
                              size: 13, color: RatelColors.teal),
                          SizedBox(width: 3),
                          Text('+1',
                              style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w800,
                                  color: RatelColors.teal)),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(width: RatelSpacing.md),
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
                  (battleModeNotifier.value && !widget.reviewMode)
                      ? BattleStage(
                          controller: _battle,
                          villain: _villain,
                          isBoss: _isBoss,
                          width: 196,
                          height: 98)
                      : ExcludeSemantics(child: _mascotSlot()),
                  const SizedBox(width: RatelSpacing.md),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(RatelSpacing.md),
                      decoration: BoxDecoration(
                        color: context.surfaceC,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: context.borderC),
                      ),
                      child: Text(_bubble()),
                    ),
                  ),
                  _reportButton(),
                ],
              ),
              const SizedBox(height: 20),
              ..._exerciseArtHeader(),
              if (_ex.sentence != null &&
                  _ex.type != ExerciseType.listenRespond &&
                  _ex.type != ExerciseType.multiBlank &&
                  _ex.type != ExerciseType.chat) ...[
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(_ex.sentence!,
                          style: const TextStyle(
                              fontSize: 20, fontWeight: FontWeight.w600)),
                    ),
                    if (_audioOn && audioStimulus(_ex) != null)
                      _speakerButton(audioStimulus(_ex)!),
                  ],
                ),
                const SizedBox(height: RatelSpacing.lg),
              ],
              Expanded(
                child: AnimatedBuilder(
                  animation: _fb,
                  builder: (context, child) => _feedbackWrap(child!),
                  child: SingleChildScrollView(
                    child: switch (_ex.type) {
                      ExerciseType.choice => _choiceBody(),
                      ExerciseType.listen => _listenBody(),
                      ExerciseType.wordBank => _wordBankBody(),
                      ExerciseType.typed => _typedBody(),
                      ExerciseType.matchPairs => _matchBody(),
                      ExerciseType.dialogueOrder => _dialogueBody(),
                      ExerciseType.multiBlank => _multiBlankBody(),
                      ExerciseType.listenRespond =>
                        _listenRespondBody(),
                      ExerciseType.chat => _chatBody(),
                    },
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
        ),
      ),
    );
  }

  Widget _statChip(IconData icon, String value, String label, Color c) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: RatelSpacing.md, vertical: RatelSpacing.sm),
      decoration: BoxDecoration(
        color: context.tintC(c),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: c.withValues(alpha: 0.5)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label,
              style: TextStyle(
                  fontSize: 9, fontWeight: FontWeight.w800, color: c)),
          const SizedBox(height: 2),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 14, color: c),
              const SizedBox(width: RatelSpacing.xs),
              Text(value,
                  style: TextStyle(
                      fontSize: 13, fontWeight: FontWeight.w800,
                      color: c)),
            ],
          ),
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

  Widget _completionAnim() {
    if (context.reduceMotion) {
      return const RatelMascot(pose: RatelPose.celebrate, size: 132);
    }
    final bool perfect = !widget.reviewMode &&
        _correctCount >= widget.lesson.exercises.length;
    return CompletionMascot(perfect: perfect, size: 132);
  }

  Widget _mascotSlot() {
    const double s = 84;
    if (_answered) {
      if (!_isCorrect && appState.hearts <= 0 && !appState.isPro) {
        return const RatelActionAnim(
            action: 'tired', fallbackPose: RatelPose.oops, size: s);
      }
      if (_isCorrect && Sfx.instance.combo.value >= 5) {
        return const RatelActionAnim(
            action: 'karate', fallbackPose: RatelPose.celebrate, size: s);
      }
      if (!_isCorrect && _missStreak >= 2) {
        return const RatelActionAnim(
            action: 'shrugok', fallbackPose: RatelPose.oops, size: s);
      }
      if (_isCorrect && _reaction != null) {
        return RatelActionAnim(
            action: _reaction!,
            fallbackPose: RatelPose.celebrate,
            size: s);
      }
    } else {
      if (widget.reviewMode && !_answered) {
        return const RatelActionAnim(
            action: 'snakestare', fallbackPose: RatelPose.think, size: s);
      }
      if (_ex.type == ExerciseType.listen) {
        return const RatelActionAnim(
            action: 'listening', fallbackPose: RatelPose.speak, size: s);
      }
      if (_firstToday) {
        return const RatelActionAnim(
            action: 'morningstretch',
            fallbackPose: RatelPose.wave,
            size: s);
      }
    }
    return RatelMascot(pose: _pose(), size: s);
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
    return _isCorrect
        ? S.instance.t('bub_correct', 'Nice — fearless!')
        : S.instance.t('bub_wrong', 'No fear — that is how we learn.');
  }

  String _correctText() => correctTextFor(_ex);

  /// Offline/empty-response fallback line, localized (EN render byte-identical
  /// to the historical literal).
  String _fallbackExplain() => S.instance
      .t('explain_fallback', 'The correct answer is "{answer}".')
      .replaceAll('{answer}', _correctText());

  String _userText() => userTextFor(_ex,
      selected: _selected,
      pickedWords: [for (final i in _picked) _ex.options[i]],
      typed: _typedCtl.text);

  /// Explain a wrong answer: the bundled asset first (free/offline), then a
  /// one-time server generate-and-cache for content not in the bundle.
  Future<void> _explain() async {
    final key = '${widget.lesson.id}:$_eIdx:'
        '${explainSuffixFor(_ex, selected: _selected)}';
    // Bundled seed first: free, instant, offline; covers all current content.
    final local = ExplainStore.instance.lookup(key);
    if (local != null) {
      setState(() => _explanation = local);
      return;
    }
    // New content such as a DB-added lesson: generate-on-demand, cached
    //    server-side so it costs at most one LLM call ever for that exercise.
    if (!Config.hasSupabase) {
      setState(() => _explanation = _fallbackExplain());
      return;
    }
    setState(() => _explaining = true);
    try {
      final res = await Supabase.instance.client.functions.invoke(
        'explain-answer',
        body: {
          'key': key,
          'locale': S.instance.locale,
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
            : _fallbackExplain();
        _explaining = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _explanation = _fallbackExplain();
        _explaining = false;
      });
    }
  }

  Widget _explainBlock() {
    if (_explanation != null) {
      return Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(RatelSpacing.md),
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
            const SizedBox(width: RatelSpacing.sm),
            Expanded(child: Text(_explanation!)),
          ],
        ),
      );
    }
    if (_explaining) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Row(
          children: [
            const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2)),
            const SizedBox(width: 10),
            Text(S.instance.t('explain_wait', 'Ratel is thinking…'),
                style: const TextStyle(color: RatelColors.textMuted)),
          ],
        ),
      );
    }
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: OutlinedButton.icon(
        onPressed: _explain,
        icon: const Icon(Icons.auto_awesome, size: 18),
        label: Text(S.instance.t('explain_btn', 'Explain this')),
      ),
    );
  }

  // ---- choice ----
  Widget _choiceBody() {
    return Column(
      children: [
        for (final i in _ensureOrder(_ex.options.length)) _optionTile(i),
      ],
    );
  }

  List<int> _ensureOrder(int n) {
    if (_order.length != n) _order = displayOrder(n, _rng);
    return _order;
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
      border = RatelColors.selected;
      fill = context.tintC(RatelColors.selected);
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
        const SizedBox(height: RatelSpacing.lg),
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
  bool get _audioOn => Flags.instance.flag('item_audio', true);

  /// Phase 2.1: speak [text] for any item. Device TTS today; pre-recorded
  /// audio_manifest clips will be preferred here once seeded (the resolver
  /// seam). Guarded no-op when TTS is unavailable (test VM / no platform).
  void _say(String text, {bool slow = false}) {
    if (text.trim().isEmpty) return;
    Sfx.instance.tap();
    Tts.instance.speak(text, slow: slow);
  }

  /// A compact tap-to-hear speaker for an item's stimulus or solution.
  Widget _speakerButton(String text, {bool small = false}) {
    return IconButton(
      visualDensity: VisualDensity.compact,
      tooltip: S.instance.t('act_listen', 'Listen'),
      onPressed: () => _say(text),
      icon: Icon(Icons.volume_up_outlined,
          size: small ? 18 : 22, color: RatelColors.honey),
    );
  }

  void _speakListen() {
    if (_ex.type == ExerciseType.listen && _ex.correctOrder.isNotEmpty) {
      Tts.instance.speak(_ex.correctOrder.first);
    }
    if (_ex.type == ExerciseType.listenRespond &&
        (_ex.sentence ?? '').isNotEmpty) {
      Tts.instance.speak(_ex.sentence!);
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
              label: Text(S.instance.t('btn_play', 'Play'),
                  style: const TextStyle(fontSize: 18)),
            ),
          ),
        ),
        Center(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: OutlinedButton.icon(
              onPressed: () {
                Sfx.instance.tap();
                if (_ex.type == ExerciseType.listen &&
                    _ex.correctOrder.isNotEmpty) {
                  Tts.instance
                      .speak(_ex.correctOrder.first, slow: true);
                }
              },
              icon: const Text('🐢', style: TextStyle(fontSize: 16)),
              label: Text(S.instance.t('btn_slower', 'Slower')),
            ),
          ),
        ),
        Center(
          child: TextButton(
            onPressed: _muteListens,
            child: const Text("Can't listen right now"),
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

  // ---- multi-blank ----
  Widget _multiBlankBody() {
    final parts = (_ex.sentence ?? '').split('___');
    final blanks = parts.length - 1;
    final available = [
      for (final i in _ensureOrder(_ex.options.length))
        if (!_picked.contains(i)) i
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          crossAxisAlignment: WrapCrossAlignment.center,
          runSpacing: 8,
          children: [
            for (int b = 0; b < parts.length; b++) ...[
              if (parts[b].isNotEmpty)
                Text(parts[b], style: const TextStyle(fontSize: 17)),
              if (b < blanks)
                b < _picked.length
                    ? Padding(
                        padding:
                            const EdgeInsets.symmetric(horizontal: 2),
                        child: InkWell(
                          onTap: _answered
                              ? null
                              : () => setState(() =>
                                  _picked.remove(_picked[b])),
                          borderRadius: BorderRadius.circular(8),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: context.tintC(RatelColors.teal),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                  color: RatelColors.teal),
                            ),
                            child: Text(_ex.options[_picked[b]],
                                style: const TextStyle(fontSize: 16)),
                          ),
                        ),
                      )
                    : Container(
                        width: 64,
                        height: 28,
                        margin: const EdgeInsets.symmetric(
                            horizontal: 2),
                        decoration: BoxDecoration(
                          border: Border(
                              bottom: BorderSide(
                                  color: context.borderC, width: 2)),
                        ),
                      ),
            ],
          ],
        ),
        const SizedBox(height: 18),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final idx in available)
              _tile(_ex.options[idx],
                  onTap: _answered ||
                          _picked.length >= blanks
                      ? null
                      : () => setState(() => _picked.add(idx))),
          ],
        ),
      ],
    );
  }

  // ---- listen & respond ----
  Widget _listenRespondBody() {
    return Column(
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
                padding: const EdgeInsets.symmetric(
                    horizontal: 28, vertical: 16),
              ),
              icon: const Icon(Icons.volume_up, size: 26),
              label: Text(S.instance.t('btn_play', 'Play'),
                  style: const TextStyle(fontSize: 18)),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Text(S.instance.t('pick_reply', 'Pick the best reply'),
              style: const TextStyle(color: RatelColors.textMuted)),
        ),
        _choiceBody(),
      ],
    );
  }

  // ---- dialogue order ----
  Widget _dialogueBody() {
    final available = [
      for (final i in _ensureOrder(_ex.options.length))
        if (!_picked.contains(i)) i
    ];
    final Color answerBorder = _answered
        ? (_isCorrect ? RatelColors.teal : RatelColors.coral)
        : context.borderC;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          constraints: const BoxConstraints(minHeight: 84),
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: context.surfaceC,
            borderRadius: BorderRadius.circular(12),
            border:
                Border.all(color: answerBorder, width: _answered ? 2 : 1),
          ),
          child: Column(
            children: [
              for (int p = 0; p < _picked.length; p++)
                _lineTile(
                    '${p.isEven ? 'A' : 'B'}:  ${_ex.options[_picked[p]]}',
                    bold: p.isEven,
                    onTap: _answered
                        ? null
                        : () =>
                            setState(() => _picked.remove(_picked[p]))),
            ],
          ),
        ),
        const SizedBox(height: RatelSpacing.lg),
        for (final idx in available)
          _lineTile(_ex.options[idx],
              onTap: _answered
                  ? null
                  : () => setState(() => _picked.add(idx))),
      ],
    );
  }

  Widget _lineTile(String text, {VoidCallback? onTap, bool bold = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: RatelSpacing.sm),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          width: double.infinity,
          padding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: context.surfaceC,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: context.faintBorderC),
          ),
          child: Text(text,
              style: TextStyle(
                  fontSize: 14.5,
                  fontWeight: bold ? FontWeight.w600 : FontWeight.w400)),
        ),
      ),
    );
  }

  // ---- match the pairs ----
  Widget _matchBody() {
    final int n = _ex.options.length;
    if (_mLO.length != n) _mLO = displayOrder(n, _rng);
    if (_mRO.length != n) _mRO = displayOrder(n, _rng);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            children: [
              for (final i in _mLO)
                _mChip(_ex.options[i],
                    done: _mDone.contains(i),
                    sel: _mLeft == i,
                    onTap: () => setState(() => _mLeft = i)),
            ],
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            children: [
              for (final i in _mRO)
                _mChip(_ex.correctOrder[i],
                    done: _mDone.contains(i),
                    sel: false,
                    onTap: () => _mPickRight(i)),
            ],
          ),
        ),
      ],
    );
  }

  void _mPickRight(int i) {
    if (_mLeft == null) return;
    if (_mLeft == i) {
      Sfx.instance.tap();
      setState(() {
        _mDone = {..._mDone, i};
        _mLeft = null;
      });
      // board complete -> grade through the normal path (always correct;
      // mismatches en route are cosmetic, Duolingo-style)
      if (_mDone.length == _ex.options.length && !_answered) _check();
    } else {
      // cosmetic miss: clear the selection, no heart, no state
      setState(() => _mLeft = null);
    }
  }

  Widget _mChip(String text,
      {required bool done, required bool sel, VoidCallback? onTap}) {
    final Color border = done
        ? RatelColors.teal
        : sel
            ? RatelColors.honey
            : context.faintBorderC;
    return Padding(
      padding: const EdgeInsets.only(bottom: RatelSpacing.sm),
      child: InkWell(
        onTap: done || _answered ? null : onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          width: double.infinity,
          padding:
              const EdgeInsets.symmetric(horizontal: RatelSpacing.md, vertical: RatelSpacing.md),
          decoration: BoxDecoration(
            color: done ? context.tintC(RatelColors.teal) : context.surfaceC,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: border, width: done || sel ? 2 : 1),
          ),
          child: Text(text,
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 15,
                  color: done ? context.mutedC : context.textC)),
        ),
      ),
    );
  }

  int _scoreNow() {
    final int totalLessons = [
      for (final u in course) u.lessons.length
    ].fold(0, (a, b) => a + b);
    return appState.englishScoreNode(totalLessons);
  }

  // ---- report this exercise ----
  /// Phase 2.5: a standard report flag, shown on EVERY item in EVERY state
  /// (the prompt row) — not only after answering — so the quality loop into
  /// `exercise_reports` is always one tap away.
  Widget _reportButton() => IconButton(
        visualDensity: VisualDensity.compact,
        tooltip: S.instance.t('report_btn', 'Report this exercise'),
        onPressed: _reportSheet,
        icon: const Icon(Icons.flag_outlined,
            size: 18, color: RatelColors.textMuted),
      );

  void _reportSheet() {
    const reasons = [
      'My answer should be accepted',
      'Something is wrong here',
      'Audio problem',
      'Typo or unnatural English',
    ];
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (ctx) => SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(S.instance.t('report_btn', 'Report this exercise'),
                  style: const TextStyle(
                      fontSize: 17, fontWeight: FontWeight.w800)),
              const SizedBox(height: RatelSpacing.md),
              for (final r in reasons)
                Padding(
                  padding: const EdgeInsets.only(bottom: RatelSpacing.sm),
                  child: OutlinedButton(
                    onPressed: () {
                      appState.reportExercise(
                        lessonId: widget.lesson.id,
                        exerciseIndex: _eIdx,
                        reason: r,
                      );
                      Navigator.of(ctx).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                              content: Text(S.instance.t(
                                  'report_thanks',
                                  'Thanks! The honey badger '
                                  'is on it.'))));
                    },
                    child: Text(r),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  // ---- bottom bar ----
  Widget _bottom() {
    if (!_answered) {
      return Row(
        children: [
          Expanded(
            child: OutlinedButton(
              style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: RatelSpacing.lg)),
              onPressed: _skip,
              child: Text(S.instance.t('btn_skip', 'Skip')),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            flex: 2,
            child: FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: RatelColors.teal,
                padding: const EdgeInsets.symmetric(vertical: RatelSpacing.lg),
              ),
              onPressed: _canCheck ? _check : null,
              child: Text(S.instance.t('btn_check', 'Check')),
            ),
          ),
        ],
      );
    }
    final Color c = _isCorrect ? RatelColors.teal : RatelColors.coral;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Icon(_isCorrect ? Icons.check_circle : Icons.cancel, color: c),
            const SizedBox(width: RatelSpacing.sm),
            Expanded(
              child: Text(
                _isCorrect
                    ? S.instance.t('correct_banner', 'Correct!')
                    : '${S.instance.t('answer_prefix', 'Answer:')} '
                        '${_ex.type == ExerciseType.multiBlank
                            ? _correctText()
                            : solutionText(_ex.sentence, _correctText())}',
                style: TextStyle(color: c, fontWeight: FontWeight.w600),
              ),
            ),
            if (_audioOn) _speakerButton(_correctText(), small: true),
          ],
        ),
        const SizedBox(height: 10),
        if (!_isCorrect) _explainBlock(),
        _wideButton(
            _isLast &&
                    (_fixPhase ||
                        widget.reviewMode ||
                        _missedFirstPass.isEmpty)
                ? S.instance.t('btn_finish', 'Finish')
                : S.instance.t('btn_continue', 'Continue'),
            _next),
      ],
    );
  }

  Widget _wideButton(String label, VoidCallback? onPressed) {
    return SizedBox(
      width: double.infinity,
      child: FilledButton(
        style: FilledButton.styleFrom(
          backgroundColor: RatelColors.teal,
          padding: const EdgeInsets.symmetric(vertical: RatelSpacing.lg),
        ),
        onPressed: onPressed,
        child: Text(label),
      ),
    );
  }

  // ---- completion ----
  Widget _completion(BuildContext context) {
    final int earned =
        (_correctCount * 10 + _bonusXp) * (_boosted ? _boostMult : 1);
    final int total = widget.lesson.exercises.length;
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            Positioned.fill(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(RatelSpacing.xl),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TweenAnimationBuilder<double>(
                        tween: Tween(begin: 0.6, end: 1.0),
                        duration: const Duration(milliseconds: 700),
                        curve: Curves.elasticOut,
                        builder: (context, s, child) =>
                            Transform.scale(scale: s, child: child),
                        child: ExcludeSemantics(child: _completionAnim()),
                      ),
                      const SizedBox(height: RatelSpacing.lg),
                      Text(
                          widget.reviewMode
                              ? S.instance.t('review_complete',
                                  'Review complete!')
                              : S.instance.t('lesson_complete',
                                  'Lesson complete!'),
                          style: const TextStyle(
                              fontSize: 24, fontFamily: kDisplayFont, fontWeight: FontWeight.w700)),
                      const StreakMilestoneCard(),
                      if (isGuest && !widget.reviewMode)
                        Padding(
                          padding: const EdgeInsets.only(top: 10),
                          child: OutlinedButton.icon(
                            onPressed: () =>
                                showSaveAccountSheet(context),
                            icon: const Icon(Icons.cloud_done, size: 18),
                            label: Text(S.instance.t('save_banner',
                                'Save your progress — free account')),
                          ),
                        ),
                      if (_unitDone)
                        Padding(
                          padding: const EdgeInsets.only(top: 10),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.school,
                                  size: 30, color: RatelColors.honey),
                              const SizedBox(width: RatelSpacing.sm),
                              Flexible(
                                  child: Text(
                                      S.instance.t('unit_complete',
                                          'Unit complete!'),
                                      style: TextStyle(
                                          fontWeight: FontWeight.w700,
                                      color: context.textC))),
                            ],
                          ),
                        ),
                      if (_newBadge)
                        Padding(
                          padding: const EdgeInsets.only(top: 10),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.military_tech,
                                  size: 30, color: RatelColors.honey),
                              const SizedBox(width: RatelSpacing.sm),
                              Flexible(
                                  child: Text(
                                      S.instance.t('new_achievement',
                                          'New achievement earned!'),
                                      style: TextStyle(
                                          fontWeight: FontWeight.w700,
                                          color: context.textC))),
                            ],
                          ),
                        ),
                      if (_fixPhase && !widget.reviewMode)
                        Padding(
                          padding: const EdgeInsets.only(top: 10),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.task_alt,
                                  size: 30, color: RatelColors.teal),
                              const SizedBox(width: RatelSpacing.sm),
                              Flexible(
                                  child: Text(
                                      S.instance.t('mistakes_cleared',
                                          'Mistakes cleared!'),
                                      style: TextStyle(
                                          fontWeight: FontWeight.w700,
                                          color: context.textC))),
                            ],
                          ),
                        ),
                      const SizedBox(height: RatelSpacing.sm),
                      widget.reviewMode
                          ? Text(
                              S.instance
                                  .t('n_correct', '{a} / {b} correct')
                                  .replaceAll('{a}', '$_correctCount')
                                  .replaceAll('{b}', '$total'),
                              style: const TextStyle(
                                  color: RatelColors.textMuted, fontSize: 16))
                          : TweenAnimationBuilder<int>(
                              tween: IntTween(begin: 0, end: earned),
                              duration: const Duration(milliseconds: 1200),
                              curve: Curves.easeOutCubic,
                              builder: (context, value, _) => Text(
                                S.instance
                                    .t('xp_and_correct',
                                        '+{x} XP   ·   {a} / {b} correct')
                                    .replaceAll('{x}', '$value')
                                    .replaceAll('{a}', '$_correctCount')
                                    .replaceAll('{b}', '$total'),
                                style: const TextStyle(
                                    color: RatelColors.textMuted, fontSize: 16),
                              ),
                            ),
                      if (!widget.reviewMode) ...[
                        const SizedBox(height: 14),
                        StaggeredIn(
                            index: 3,
                            child: Wrap(
                          spacing: 10,
                          runSpacing: 8,
                          alignment: WrapAlignment.center,
                          children: [
                            _statChip(Icons.bolt, '+$earned XP', 'TOTAL',
                                RatelColors.honey),
                            if (_gemsEarned > 0)
                              _statChip(Icons.diamond, '+$_gemsEarned',
                                  'GEMS', RatelColors.teal),
                            if (_boosted)
                              _statChip(Icons.flash_on, '${_boostMult}x',
                                  'BOOST', RatelColors.coral),
                            if (_scoreNow() > _scoreBefore)
                              TweenAnimationBuilder<int>(
                                tween: IntTween(
                                    begin: _scoreBefore,
                                    end: _scoreNow()),
                                duration: const Duration(
                                    milliseconds: 900),
                                curve: Curves.easeOutCubic,
                                builder: (context, v, _) => _statChip(
                                    Icons.school,
                                    '$_scoreBefore → $v',
                                    'SCORE',
                                    RatelColors.scoreStat),
                              ),
                            _statChip(
                                Icons.track_changes,
                                '${(_correctCount * 100 ~/ widget.lesson.exercises.length)}%',
                                accuracyTier(_correctCount * 100 ~/
                                    widget.lesson.exercises.length),
                                RatelColors.teal),
                            _statChip(
                                Icons.timer_outlined,
                                '${_elapsed.inMinutes}:${(_elapsed.inSeconds % 60).toString().padLeft(2, '0')}',
                                speedTier(_elapsed),
                                RatelColors.speedStat),
                          ],
                        )),
                      ],
                      if (_bonusXp > 0) ...[
                        const SizedBox(height: 6),
                        Text(
                            S.instance
                                .t('bonus_xp', '🎁 Surprise bonus +{n} XP!')
                                .replaceAll('{n}', '$_bonusXp'),
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
                        const SizedBox(height: RatelSpacing.lg),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            StreakFlame(streak: appState.streak, size: 24),
                            const SizedBox(width: 6),
                            Text(
                                S.instance
                                    .t('streak_days_title', '{n}-day streak')
                                    .replaceAll('{n}', '${appState.streak}'),
                                style: const TextStyle(
                                    color: RatelColors.coral,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 15)),
                          ],
                        ),
                      ],
                      ..._conceptsStrip(),
                      const SizedBox(height: 28),
                      _wideButton(
                          S.instance.t('btn_continue', 'Continue'),
                          () => Navigator.of(context).maybePop()),
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
