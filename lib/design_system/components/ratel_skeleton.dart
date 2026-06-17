import 'package:flutter/material.dart';
import '../../core/theme/tokens.dart';

/// Loading placeholder with a NON-looping shimmer. Charter §4: looping
/// animations break `pumpAndSettle` — the controller runs `forward()` ONCE
/// (never `repeat()`), so tests pump a fixed `Duration` safely.
class RatelSkeleton extends StatefulWidget {
  const RatelSkeleton({
    super.key,
    this.width = double.infinity,
    this.height = 16,
    this.radius,
  });

  final double width;
  final double height;
  final double? radius;

  @override
  State<RatelSkeleton> createState() => _RatelSkeletonState();
}

class _RatelSkeletonState extends State<RatelSkeleton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _c.forward(); // ONCE, not repeat() — keeps tests pump(Duration)-safe (charter §4).
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tk = context.tokens;
    final double r = widget.radius ?? tk.radiusSm;
    return AnimatedBuilder(
      animation: _c,
      builder: (BuildContext context, Widget? child) {
        final double t = _c.value;
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(r),
            gradient: LinearGradient(
              begin: Alignment(-1 - 2 * (1 - t), 0),
              end: Alignment(1 - 2 * (1 - t), 0),
              colors: <Color>[tk.surface2, tk.border, tk.surface2],
            ),
          ),
        );
      },
    );
  }
}

/// "Loading list" convention: [rows] skeleton lines separated by md gaps.
class RatelSkeletonList extends StatelessWidget {
  const RatelSkeletonList({super.key, this.rows = 4});

  final int rows;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        for (int i = 0; i < rows; i++) ...<Widget>[
          if (i > 0) const SizedBox(height: RatelSpacing.md),
          const RatelSkeleton(height: 14),
        ],
      ],
    );
  }
}
