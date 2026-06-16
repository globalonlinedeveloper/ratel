import 'package:flutter/material.dart';
import '../theme.dart';

/// Dual language select: "I speak" + "I want to learn". Supersedes the
/// hardcoded en/ta SegmentedButton in onboarding — pass the full locale map.
class LanguagePicker extends StatelessWidget {
  const LanguagePicker({
    super.key,
    required this.options,
    required this.spoken,
    required this.target,
    required this.onSpokenChanged,
    required this.onTargetChanged,
    this.spokenLabel = 'I speak',
    this.targetLabel = 'I want to learn',
  });

  /// code -> display name, e.g. {'en':'English','ta':'Tamil'}.
  final Map<String, String> options;
  final String spoken;
  final String target;
  final ValueChanged<String> onSpokenChanged;
  final ValueChanged<String> onTargetChanged;
  final String spokenLabel;
  final String targetLabel;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        _row(context, spokenLabel, spoken, onSpokenChanged),
        const SizedBox(height: RatelSpacing.md),
        _row(context, targetLabel, target, onTargetChanged),
      ],
    );
  }

  Widget _row(
    BuildContext context,
    String label,
    String value,
    ValueChanged<String> onChanged,
  ) {
    final t = context.tokens;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 6, left: 2),
          child: Text(
            label,
            style: TextStyle(
              fontFamily: kBodyFont,
              fontWeight: FontWeight.w600,
              fontSize: 13,
              color: context.mutedC,
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: RatelSpacing.md),
          decoration: BoxDecoration(
            color: context.isDark
                ? RatelColorsDark.surface2
                : RatelColors.surface2,
            borderRadius: BorderRadius.circular(t.radiusMd),
            border: Border.all(color: context.borderC, width: t.hairline),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              isExpanded: true,
              value: options.containsKey(value) ? value : null,
              items: [
                for (final e in options.entries)
                  DropdownMenuItem(value: e.key, child: Text(e.value)),
              ],
              onChanged: (v) {
                if (v != null) onChanged(v);
              },
            ),
          ),
        ),
      ],
    );
  }
}
