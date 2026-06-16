import 'package:flutter/material.dart';
import '../theme.dart';
import 'ratel_tone.dart';

/// Compact stat: icon + value + label, tinted by [tone]. Supersedes the
/// completion scoreStat/speedStat stat chips.
class RatelStatTile extends StatelessWidget {
  const RatelStatTile({
    super.key,
    required this.icon,
    required this.value,
    required this.label,
    this.tone = RatelTone.primary,
  });

  final IconData icon;
  final String value;
  final String label;
  final RatelTone tone;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: RatelSpacing.md,
        vertical: RatelSpacing.md,
      ),
      decoration: BoxDecoration(
        color: context.toneContainer(tone),
        borderRadius: BorderRadius.circular(t.radiusMd),
        border: Border.all(color: context.toneBorder(tone), width: t.hairline),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: context.toneFg(tone), size: 22),
          const SizedBox(height: 4),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontFamily: kDisplayFont,
              fontWeight: FontWeight.w800,
              fontSize: 18,
              color: context.textC,
            ),
          ),
          Text(
            label,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontFamily: kBodyFont,
              fontSize: 12,
              color: context.mutedC,
            ),
          ),
        ],
      ),
    );
  }
}
