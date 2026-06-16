import 'package:flutter/material.dart';
import '../theme.dart';
import 'ratel_tone.dart';

/// Standard surface container for the kit. Supersedes raw `Card` + ad-hoc
/// `Container(decoration: BoxDecoration(border: ...))` cards. Background,
/// border and radius all come from tokens; [tone] tints the whole container.
class RatelCard extends StatelessWidget {
  const RatelCard({
    super.key,
    required this.child,
    this.padding,
    this.onTap,
    this.tone = RatelTone.surface,
  });

  final Widget child;
  final EdgeInsetsGeometry? padding;
  final VoidCallback? onTap;
  final RatelTone tone;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final radius = BorderRadius.circular(t.radiusLg);
    final body = DecoratedBox(
      decoration: BoxDecoration(
        color: context.toneContainer(tone),
        borderRadius: radius,
        border: Border.all(color: context.toneBorder(tone), width: t.hairline),
      ),
      child: Padding(
        padding: padding ?? const EdgeInsets.all(RatelSpacing.lg),
        child: child,
      ),
    );
    if (onTap == null) return body;
    return Material(
      color: Colors.transparent,
      borderRadius: radius,
      clipBehavior: Clip.antiAlias,
      child: InkWell(onTap: onTap, child: body),
    );
  }
}
