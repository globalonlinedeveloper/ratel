import 'package:flutter/material.dart';
import 'ratel_toggle_row.dart';

/// One consent line for [ConsentToggles].
class ConsentItem {
  const ConsentItem({required this.key, required this.title, this.subtitle});
  final String key;
  final String title;
  final String? subtitle;
}

/// Grouped consent switches (default-OFF via the caller's [values]). Composes
/// RatelToggleRow. For data/marketing consent (compliance, default-off).
class ConsentToggles extends StatelessWidget {
  const ConsentToggles({
    super.key,
    required this.items,
    required this.values,
    required this.onChanged,
  });

  final List<ConsentItem> items;
  final Map<String, bool> values;
  final void Function(String key, bool value) onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (final it in items)
          RatelToggleRow(
            title: it.title,
            subtitle: it.subtitle,
            value: values[it.key] ?? false,
            onChanged: (v) => onChanged(it.key, v),
          ),
      ],
    );
  }
}
