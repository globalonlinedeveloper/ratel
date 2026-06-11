import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../config.dart';
import '../milestones.dart';
import '../theme.dart';

/// One row of friend activity (from the friends_feed RPC).
class FeedItem {
  const FeedItem(
      {required this.name,
      required this.amount,
      required this.reason,
      required this.at});

  factory FeedItem.fromRow(Map<String, dynamic> r) => FeedItem(
        name: (r['display_name'] ?? 'Badger').toString(),
        amount: (r['amount'] as num?)?.toInt() ?? 0,
        reason: (r['reason'] ?? '').toString(),
        at: DateTime.tryParse((r['created_at'] ?? '').toString()) ??
            DateTime.now(),
      );

  final String name;
  final int amount;
  final String reason;
  final DateTime at;
}

/// Read-only friend activity. Kind by design: no rankings here, just
/// 'your people are learning too'.
class FriendsFeed extends StatefulWidget {
  const FriendsFeed({super.key, this.items});

  final List<FeedItem>? items; // test injection

  @override
  State<FriendsFeed> createState() => _FriendsFeedState();
}

class _FriendsFeedState extends State<FriendsFeed> {
  List<FeedItem>? _items;

  @override
  void initState() {
    super.initState();
    if (widget.items != null) {
      _items = widget.items;
      return;
    }
    _load();
  }

  Future<void> _load() async {
    if (!Config.hasSupabase) {
      if (mounted) setState(() => _items = const []);
      return;
    }
    try {
      final rows = await Supabase.instance.client
          .rpc('friends_feed')
          .timeout(const Duration(seconds: 5));
      if (mounted) {
        setState(() => _items = [
              for (final r in rows as List)
                FeedItem.fromRow(r as Map<String, dynamic>),
            ]);
      }
    } catch (_) {
      if (mounted) setState(() => _items = const []);
    }
  }

  @override
  Widget build(BuildContext context) {
    final items = _items;
    if (items == null || items.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(top: 18, bottom: 8),
          child: Text('Friend activity',
              style:
                  TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
        ),
        for (final it in items.take(20)) _row(context, it),
      ],
    );
  }

  Widget _row(BuildContext context, FeedItem it) {
    final String what = it.reason == 'chest'
        ? 'opened a chest (+${it.amount} XP)'
        : 'earned ${it.amount} XP';
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          CircleAvatar(
            radius: 14,
            backgroundColor: RatelColors.teal,
            child: Text(
                it.name.isEmpty ? 'B' : it.name[0].toUpperCase(),
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w800)),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text('${it.name} $what',
                style: const TextStyle(fontSize: 13.5)),
          ),
          Text(timeAgo(DateTime.now().difference(it.at)),
              style: const TextStyle(
                  color: RatelColors.textMuted, fontSize: 11.5)),
        ],
      ),
    );
  }
}
