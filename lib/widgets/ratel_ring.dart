import 'package:flutter/material.dart';
import '../theme.dart';
import 'ratel_tone.dart';

/// Circular progress ring with an optional center label. Supersedes bespoke
/// CircularProgressIndicator + Stack score rings. [value] clamped 0..1.
class RatelRing extends StatelessWidget {
  const RatelRing({
    super.key,
    required this.value,
    this.size = 64,
    this.label,
    this.tone = RatelTone.primary,
    this.stroke = 6,
  });

  final double value;
  final double size;
  final String? label;
  final RatelTone tone;
  final double stroke;

  @override
  Widget build(BuildContext context) {
    final v = value.clamp(0.0, 1.0).toDouble();
    final track = context.isDark
        ? RatelColorsDark.surface2
        : RatelColors.surface2;
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: size,
            height: size,
            child: CircularProgressIndicator(
              value: 1,
              strokeWidth: stroke,
              color: track,
            ),
          ),
          SizedBox(
            width: size,
            height: size,
            child: CircularProgressIndicator(
              value: v,
              strokeWidth: stroke,
              color: context.toneFg(tone),
              backgroundColor: Colors.transparent,
            ),
          ),
          if (label != null)
            Text(
              label!,
              style: TextStyle(
                fontFamily: kDisplayFont,
                fontWeight: FontWeight.w800,
                fontSize: size * 0.26,
                color: context.textC,
              ),
            ),
        ],
      ),
    );
  }
}
