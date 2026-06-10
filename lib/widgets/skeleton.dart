import 'package:flutter/material.dart';
import '../theme.dart';

/// Soft loading placeholder: a rounded, theme-aware block that gently
/// breathes (no shimmer dependency). Static under reduce-motion.
class SkeletonBox extends StatefulWidget {
  const SkeletonBox(
      {super.key, this.width = double.infinity, this.height = 16, this.radius = 12});
  final double width;
  final double height;
  final double radius;

  @override
  State<SkeletonBox> createState() => _SkeletonBoxState();
}

class _SkeletonBoxState extends State<SkeletonBox>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 900));

  @override
  void initState() {
    super.initState();
    _c.repeat(reverse: true);
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final box = Container(
      width: widget.width,
      height: widget.height,
      decoration: BoxDecoration(
        color: context.borderC,
        borderRadius: BorderRadius.circular(widget.radius),
      ),
    );
    if (context.reduceMotion) {
      if (_c.isAnimating) _c.stop();
      return Opacity(opacity: 0.7, child: box);
    }
    if (!_c.isAnimating) _c.repeat(reverse: true);
    return FadeTransition(
      opacity: Tween<double>(begin: 0.45, end: 0.95)
          .animate(CurvedAnimation(parent: _c, curve: Curves.easeInOut)),
      child: box,
    );
  }
}

/// A simple column of skeleton rows for list-shaped loading states.
class SkeletonList extends StatelessWidget {
  const SkeletonList({super.key, this.rows = 4, this.height = 64});
  final int rows;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          for (int i = 0; i < rows; i++)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: SkeletonBox(height: height, radius: 14),
            ),
        ],
      ),
    );
  }
}
