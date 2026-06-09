import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:rive/rive.dart' as rive;

/// The eight Ratel animation states (each maps to a WebP asset and to the
/// `pose` index the Rive state machine reads).
enum RatelPose { idle, wave, celebrate, encourage, think, oops, speak, point }

/// The fearless honey badger mascot.
///
/// If a rigged `assets/rive/ratel.riv` is bundled (state machine `RatelSM`,
/// Number input `pose`), it renders that. Otherwise it falls back to animated
/// WebP poses with idle breathing + a squash-and-stretch pop. See
/// `RIVE_MASCOT_SPEC.md`.
class RatelMascot extends StatefulWidget {
  final RatelPose pose;
  final double size;
  const RatelMascot({super.key, this.pose = RatelPose.idle, this.size = 96});

  @override
  State<RatelMascot> createState() => _RatelMascotState();
}

class _RatelMascotState extends State<RatelMascot>
    with TickerProviderStateMixin {
  late final AnimationController _breath;
  late final AnimationController _pop;

  rive.Artboard? _artboard;
  rive.SMINumber? _poseInput;

  @override
  void initState() {
    super.initState();
    _breath = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 2600))
      ..repeat(reverse: true);
    _pop = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 480), value: 1);
    _loadRive();
  }

  Future<void> _loadRive() async {
    try {
      final data = await rootBundle.load('assets/rive/ratel.riv');
      final file = rive.RiveFile.import(data);
      final artboard = file.mainArtboard.instance();
      final controller =
          rive.StateMachineController.fromArtboard(artboard, 'RatelSM');
      if (controller == null) return;
      artboard.addController(controller);
      final input = controller.findInput<double>('pose');
      if (input is rive.SMINumber) {
        _poseInput = input;
        _poseInput!.value = widget.pose.index.toDouble();
      }
      if (mounted) setState(() => _artboard = artboard);
    } catch (_) {
      // No .riv yet (or load failed) -> keep the WebP fallback. Silent by design.
    }
  }

  @override
  void didUpdateWidget(RatelMascot oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.pose != widget.pose) {
      _pop.forward(from: 0);
      _poseInput?.value = widget.pose.index.toDouble();
    }
  }

  @override
  void dispose() {
    _breath.dispose();
    _pop.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Rigged Rive character, once a matching .riv is bundled.
    if (_artboard != null) {
      return SizedBox(
        height: widget.size,
        width: widget.size,
        child: rive.Rive(artboard: _artboard!, fit: BoxFit.contain),
      );
    }
    // Animated WebP fallback: idle breathing + squash-and-stretch pop.
    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: Listenable.merge([_breath, _pop]),
        builder: (context, child) {
          final breath = math.sin(_breath.value * math.pi);
          final stretch = math.sin(_pop.value * math.pi) * (1 - _pop.value);
          final scaleX = (1 - 0.012 * breath) - 0.10 * stretch;
          final scaleY = (1 + 0.020 * breath) + 0.18 * stretch;
          return Transform.translate(
            offset: Offset(0, -2.0 * breath),
            child: Transform.scale(
              scaleX: scaleX,
              scaleY: scaleY,
              alignment: Alignment.bottomCenter,
              child: child,
            ),
          );
        },
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 220),
          child: Image.asset(
            'assets/images/ratel-${widget.pose.name}.webp',
            key: ValueKey<RatelPose>(widget.pose),
            height: widget.size,
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }
}
