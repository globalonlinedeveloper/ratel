import 'package:flutter/material.dart';
import '../../core/theme/tokens.dart';

/// App bottom navigation for the tab-root screens (home / practice / leagues /
/// profile). The active tab is tinted with the primary colour. Tokens only.
class RatelBottomNav extends StatelessWidget {
  const RatelBottomNav({super.key, required this.currentIndex, this.onTap});

  final int currentIndex;
  final ValueChanged<int>? onTap;

  static const List<(IconData, String)> items = <(IconData, String)>[
    (Icons.home_outlined, 'Home'),
    (Icons.fitness_center, 'Practice'),
    (Icons.emoji_events_outlined, 'Leagues'),
    (Icons.person_outline, 'Profile'),
  ];

  @override
  Widget build(BuildContext context) {
    final tk = context.tokens;
    return Container(
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: tk.border, width: tk.hairline)),
      ),
      padding: const EdgeInsets.symmetric(vertical: RatelSpacing.sm),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          for (int i = 0; i < items.length; i++)
            IconButton(
              icon: Icon(items[i].$1),
              iconSize: 22,
              color: i == currentIndex ? tk.primary : tk.textMuted,
              tooltip: items[i].$2,
              onPressed: () => onTap?.call(i),
            ),
        ],
      ),
    );
  }
}
