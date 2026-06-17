import 'package:flutter/material.dart';
import '../../../core/i18n/strings.dart';
import '../../../core/theme/tokens.dart';
import '../../../design_system/components/ratel_toggle_row.dart';

/// Notifications — mock Page-6 · screen 8 (granular per-type toggles).
/// Design-only (no backend yet).
class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final Map<String, bool> _v = <String, bool>{
    'streak': true,
    'goal': true,
    'league': false,
    'friend': true,
    'offers': false,
  };

  @override
  Widget build(BuildContext context) {
    final tk = context.tokens;
    Widget toggle(String key, String label) => RatelToggleRow(
          label: label,
          value: _v[key]!,
          onChanged: (bool val) => setState(() => _v[key] = val),
        );
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Navigator.of(context).canPop()
            ? IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => Navigator.of(context).maybePop())
            : null,
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(RatelSpacing.md, 0, RatelSpacing.md, RatelSpacing.md),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text(S.t('notif_title', 'Notifications'), style: TextStyle(color: tk.text, fontSize: 15, fontWeight: FontWeight.w600)),
                  const SizedBox(height: RatelSpacing.xs),
                  Text(S.t('notif_sub', 'Granular — pick exactly what you want.'), style: TextStyle(color: tk.textMuted, fontSize: 10)),
                  const SizedBox(height: RatelSpacing.md),
                  toggle('streak', S.t('notif_streak', 'Streak reminder')),
                  const SizedBox(height: RatelSpacing.md),
                  toggle('goal', S.t('notif_goal', 'Daily goal nudge')),
                  const SizedBox(height: RatelSpacing.md),
                  toggle('league', S.t('notif_league', 'League updates')),
                  const SizedBox(height: RatelSpacing.md),
                  toggle('friend', S.t('notif_friend', 'Friend activity')),
                  const SizedBox(height: RatelSpacing.md),
                  toggle('offers', S.t('notif_offers', 'Product & offers')),
                  const SizedBox(height: RatelSpacing.md),
                  Text(S.t('notif_note', 'quiet hours respected · marketing off lock-screen unless opted in'), style: TextStyle(color: tk.textMuted, fontSize: 9)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
