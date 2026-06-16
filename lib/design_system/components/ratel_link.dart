import 'package:flutter/material.dart';
import '../../core/theme/tokens.dart';

/// Inline text link (info-blue, semibold) for secondary navigation actions
/// ("Create an account", "I already have an account"). Composes tokens only.
class RatelLink extends StatelessWidget {
  const RatelLink({
    super.key,
    required this.label,
    required this.onTap,
    this.fontSize = 13,
  });

  final String label;
  final VoidCallback onTap;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(context.tokens.radiusSm),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 2),
        child: Text(
          label,
          style: TextStyle(
            color: context.tokens.info,
            fontSize: fontSize,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
