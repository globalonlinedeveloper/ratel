import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import '../config.dart';
import '../screens/paywall_screen.dart';
import '../theme.dart';
import '../widgets/transitions.dart';

/// A campaign row designed in the database (public.campaigns).
class Campaign {
  const Campaign(
      {required this.id,
      required this.title,
      this.body = '',
      this.art = '',
      this.button = '',
      this.action = ''});

  factory Campaign.fromRow(Map<String, dynamic> r) => Campaign(
        id: (r['id'] as num?)?.toInt() ?? 0,
        title: (r['title'] ?? '').toString(),
        body: (r['body'] ?? '').toString(),
        art: (r['art'] ?? '').toString(),
        button: (r['button'] ?? '').toString(),
        action: (r['action'] ?? '').toString(),
      );

  final int id;
  final String title;
  final String body;
  final String art;
  final String button;
  final String action;
}

/// 'paywall' | 'coach' | 'url' | 'none' (+ url payload). Pure, testable.
(String, String) campaignAction(String action) {
  if (action == 'paywall') return ('paywall', '');
  if (action == 'coach') return ('coach', '');
  if (action.startsWith('url:https://')) {
    return ('url', action.substring(4));
  }
  return ('none', '');
}

/// Server-driven promo cards on the Learn screen. One safe native renderer;
/// marketing happens in the database.
class CampaignCards extends StatefulWidget {
  const CampaignCards({super.key, this.campaigns, this.onCoach});

  final List<Campaign>? campaigns; // test injection
  final VoidCallback? onCoach;

  @override
  State<CampaignCards> createState() => _CampaignCardsState();
}

class _CampaignCardsState extends State<CampaignCards> {
  List<Campaign> _items = [];
  Set<String> _dismissed = {};

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _dismissed =
          (prefs.getStringList('camp_dismissed') ?? const []).toSet();
    } catch (_) {}
    if (widget.campaigns != null) {
      if (mounted) setState(() => _items = widget.campaigns!);
      return;
    }
    if (!Config.hasSupabase) return;
    try {
      final rows = await Supabase.instance.client
          .from('campaigns')
          .select()
          .order('sort_order')
          .timeout(const Duration(seconds: 5));
      if (mounted) {
        setState(() => _items = [
              for (final r in rows) Campaign.fromRow(r),
            ]);
      }
    } catch (_) {}
  }

  Future<void> _dismiss(Campaign c) async {
    setState(() => _dismissed = {..._dismissed, '${c.id}'});
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList('camp_dismissed', _dismissed.toList());
    } catch (_) {}
  }

  void _act(Campaign c) {
    final (kind, payload) = campaignAction(c.action);
    switch (kind) {
      case 'paywall':
        Navigator.of(context).push(ratelRoute(const PaywallScreen()));
      case 'coach':
        widget.onCoach?.call();
      case 'url':
        launchUrl(Uri.parse(payload));
      default:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final live =
        _items.where((c) => !_dismissed.contains('${c.id}')).toList();
    if (live.isEmpty) return const SizedBox.shrink();
    return Column(
      children: [for (final c in live) _card(context, c)],
    );
  }

  Widget _card(BuildContext context, Campaign c) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      padding: const EdgeInsets.fromLTRB(12, 10, 4, 10),
      decoration: BoxDecoration(
        color: context.tintC(RatelColors.teal),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: context.faintBorderC),
      ),
      child: Row(
        children: [
          if (c.art.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(right: 10),
              child: Image.asset('assets/images/ratel-${c.art}.webp',
                  width: 54,
                  height: 54,
                  errorBuilder: (_, _, _) => const SizedBox.shrink()),
            ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(c.title,
                    style: const TextStyle(
                        fontWeight: FontWeight.w800, fontSize: 14)),
                if (c.body.isNotEmpty)
                  Text(c.body,
                      style: TextStyle(
                          fontSize: 12.5, color: context.mutedC)),
                if (c.button.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: FilledButton(
                      style: FilledButton.styleFrom(
                          visualDensity: VisualDensity.compact,
                          backgroundColor: RatelColors.teal),
                      onPressed: () => _act(c),
                      child: Text(c.button,
                          style: const TextStyle(fontSize: 12.5)),
                    ),
                  ),
              ],
            ),
          ),
          IconButton(
              onPressed: () => _dismiss(c),
              icon: const Icon(Icons.close, size: 16)),
        ],
      ),
    );
  }
}
