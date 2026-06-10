import 'package:flutter/material.dart';
import '../theme.dart';
import 'ratel_mascot.dart';

/// Answer-driven duel events (fired by the lesson).
enum BattleEvent { correct, finisher, wrong, defeat, victory }

enum RatelBattleState { guard, swipe, karate, stagger, tired, win }

enum CobraState { idle, taunt, strike, recoil, dizzy, defeated }

/// Owns the duel state; the lesson fires events, the stage renders them.
class BattleController extends ChangeNotifier {
  RatelBattleState ratel = RatelBattleState.guard;
  CobraState cobra = CobraState.idle;
  int combo = 0;
  bool over = false;

  void fire(BattleEvent e, {int combo = 0}) {
    this.combo = combo;
    switch (e) {
      case BattleEvent.correct:
        ratel = RatelBattleState.swipe;
        cobra = CobraState.recoil;
      case BattleEvent.finisher:
        ratel = RatelBattleState.karate;
        cobra = CobraState.dizzy;
      case BattleEvent.wrong:
        ratel = RatelBattleState.stagger;
        cobra = CobraState.strike;
      case BattleEvent.defeat:
        ratel = RatelBattleState.tired;
        cobra = CobraState.taunt;
        over = true;
      case BattleEvent.victory:
        ratel = RatelBattleState.win;
        cobra = CobraState.defeated;
        over = true;
    }
    notifyListeners();
  }

  /// Transient states settle back to guard/idle after the beat plays.
  void settle() {
    if (over) return;
    ratel = RatelBattleState.guard;
    cobra = CobraState.idle;
    notifyListeners();
  }
}

/// The duel strip: Ratel vs the cobra, reacting to every answer.
/// Pure presentation — IgnorePointer, never blocks the exercise.
class BattleStage extends StatefulWidget {
  const BattleStage({
    super.key,
    required this.controller,
    this.villain = 'cobra',
    this.isBoss = false,
    this.width = 168,
    this.height = 84,
  });

  final BattleController controller;

  /// cobra | scorpion | bees | jackal | vulture (unit-tier roster).
  final String villain;
  final bool isBoss;
  final double width;
  final double height;

  @override
  State<BattleStage> createState() => _BattleStageState();
}

class _BattleStageState extends State<BattleStage>
    with TickerProviderStateMixin {
  late final AnimationController _sway = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 900))
    ..repeat(reverse: true);
  late final AnimationController _act = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 420));

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onEvent);
    _act.addStatusListener((st) {
      if (st == AnimationStatus.completed) widget.controller.settle();
    });
  }

  void _onEvent() {
    if (!mounted) return;
    final c = widget.controller;
    final bool transient = !c.over &&
        (c.ratel != RatelBattleState.guard || c.cobra != CobraState.idle);
    if (transient) _act.forward(from: 0);
    setState(() {});
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onEvent);
    _sway.dispose();
    _act.dispose();
    super.dispose();
  }

  String _ratelAsset() {
    switch (widget.controller.ratel) {
      case RatelBattleState.guard:
        return _sway.value > 0.5
            ? 'assets/battle/ratel_guard2.webp'
            : 'assets/battle/ratel_guard1.webp';
      case RatelBattleState.swipe:
        return _act.value < 0.5
            ? 'assets/battle/ratel_swipe1.webp'
            : 'assets/battle/ratel_swipe2.webp';
      case RatelBattleState.karate:
        return 'assets/images/ratel-karate-anim.webp';
      case RatelBattleState.stagger:
        return _act.value < 0.5
            ? 'assets/battle/ratel_stagger1.webp'
            : 'assets/battle/ratel_stagger2.webp';
      case RatelBattleState.tired:
        return 'assets/images/ratel-tired-anim.webp';
      case RatelBattleState.win:
        return 'assets/images/ratel-jump.webp';
    }
  }

  String _cobraAsset() {
    final String p = (widget.isBoss && widget.villain == 'cobra')
        ? 'boss'
        : widget.villain;
    final n = widget.controller.cobra.name;
    return 'assets/battle/${p}_$n.webp';
  }

  @override
  Widget build(BuildContext context) {
    final bool still = context.reduceMotion;
    if (still && _sway.isAnimating) _sway.stop();
    if (!still && !_sway.isAnimating) _sway.repeat(reverse: true);
    final c = widget.controller;
    final double h = widget.height;
    return IgnorePointer(
      child: SizedBox(
        width: widget.width,
        height: h,
        child: AnimatedBuilder(
          animation: Listenable.merge([_sway, _act]),
          builder: (context, _) {
            final double a = Curves.easeOut.transform(_act.value);
            // cobra lunges toward Ratel on strike, jolts back on recoil
            double cobraDx = 0;
            if (c.cobra == CobraState.strike) cobraDx = -10 * (1 - a);
            if (c.cobra == CobraState.recoil) cobraDx = 8 * (1 - a);
            final double cobraDrop =
                c.cobra == CobraState.defeated ? 16 * a : 0;
            return Stack(
              children: [
                // power meter (combo toward the karate finisher)
                Positioned(
                  left: 4,
                  right: 4,
                  bottom: 0,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(2),
                    child: LinearProgressIndicator(
                      value: (c.combo.clamp(0, 5)) / 5.0,
                      minHeight: 3,
                      backgroundColor: context.borderC,
                      color: RatelColors.honey,
                    ),
                  ),
                ),
                Positioned(
                  left: 0,
                  bottom: 6,
                  child: Image.asset(_ratelAsset(),
                      width: h - 8,
                      height: h - 8,
                      filterQuality: FilterQuality.medium,
                      errorBuilder: (_, _, _) => RatelMascot(
                          pose: RatelPose.idle, size: h - 8)),
                ),
                Positioned(
                  right: 0,
                  bottom: 6 - cobraDrop,
                  child: Opacity(
                    opacity:
                        c.cobra == CobraState.defeated ? 1 - 0.7 * a : 1,
                    child: Transform.translate(
                      offset: Offset(cobraDx,
                          still ? 0 : 1.5 * (_sway.value - 0.5)),
                      child: Image.asset(_cobraAsset(),
                          width: (h - 12) *
                              (widget.isBoss && widget.villain != 'cobra'
                                  ? 1.12
                                  : 1.0),
                          height: (h - 12) *
                              (widget.isBoss && widget.villain != 'cobra'
                                  ? 1.12
                                  : 1.0),
                          filterQuality: FilterQuality.medium,
                          errorBuilder: (_, _, _) =>
                              SizedBox(width: h - 12, height: h - 12)),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
