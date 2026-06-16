import 'package:flutter/material.dart';

/// Decorative icon medallion — a coloured disc (or rounded square) with a
/// centred icon. Recurs across the auth screens (splash, verify, success,
/// warning states). Composes tokens only; caller passes semantic token colours.
class RatelMedallion extends StatelessWidget {
  const RatelMedallion({
    super.key,
    required this.icon,
    required this.background,
    required this.foreground,
    this.size = 62,
    this.iconSize = 32,
    this.cornerRadius,
  });

  final IconData icon;
  final Color background;
  final Color foreground;
  final double size;
  final double iconSize;

  /// Null = circle; a value = rounded square with that corner radius.
  final double? cornerRadius;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: background,
        shape: cornerRadius == null ? BoxShape.circle : BoxShape.rectangle,
        borderRadius:
            cornerRadius == null ? null : BorderRadius.circular(cornerRadius!),
      ),
      child: Icon(icon, size: iconSize, color: foreground),
    );
  }
}
