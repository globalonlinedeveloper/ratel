import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../flags.dart';
import '../theme.dart';

/// Announcement banner driven by the `motd` remote flag — post events/news
/// live without shipping an update. Dismissal persists per message text.
class MotdCard extends StatefulWidget {
  const MotdCard({super.key});

  @override
  State<MotdCard> createState() => _MotdCardState();
}

class _MotdCardState extends State<MotdCard> {
  bool _dismissed = true; // hidden until we know it wasn't dismissed

  String get _motd => Flags.instance.str('motd', '');

  @override
  void initState() {
    super.initState();
    _check();
  }

  Future<void> _check() async {
    if (_motd.isEmpty) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      if (mounted && (prefs.getString('motd_dismissed') ?? '') != _motd) {
        setState(() => _dismissed = false);
      }
    } catch (_) {}
  }

  Future<void> _dismiss() async {
    setState(() => _dismissed = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('motd_dismissed', _motd);
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    if (_dismissed || _motd.isEmpty) return const SizedBox.shrink();
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: context.tintC(RatelColors.honey),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 8, 4, 8),
        child: Row(
          children: [
            const Icon(Icons.campaign, color: RatelColors.honey),
            const SizedBox(width: 10),
            Expanded(
              child: Text(_motd,
                  style: const TextStyle(
                      fontSize: 13.5, fontWeight: FontWeight.w600)),
            ),
            IconButton(
                onPressed: _dismiss,
                icon: const Icon(Icons.close, size: 18)),
          ],
        ),
      ),
    );
  }
}
