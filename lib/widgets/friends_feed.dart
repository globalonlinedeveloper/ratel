import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../config.dart';
import '../milestones.dart';
import '../strings.dart';
import '../theme.dart';

/// One row of friend activity (from the friends_feed RPC).
class FeedItem {
  const FeedItem(
      {required this.name,
      required this.amount,
      required this.reason,
      required this.at,
      this.friendId = ''});

  factory FeedItem.fromRow(Map<String, dynamic> r) => FeedItem(
        friendId: (r['friend_id'] ?? '').toString(),
        name: (r['display_name'] ??
                S.instance.t('feed_badger', 'Badger'))
            .toString(),
        amount: (r['amount'] as num?)?.toInt() ?? 0,
        reason: (r['reason'] ?? '').toString(),
        at: DateTime.tryParse((r['created_at'] ?? '').toString()) ??
            DateTime.now(),
      );

  final String name;
  final int amount;
  final String reason;
  final DateTime at;
  final String friendId; // '' for cheer-received rows
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
      final c = Supabase.instance.client;
      final rows =
          await c.rpc('friends_feed').timeout(const Duration(seconds: 5));
      List<dynamic> cheers = const [];
      try {
        cheers = await c
            .rpc('my_cheers')
            .timeout(const Duration(seconds: 4)) as List;
      } catch (_) {}
      final items = [
        for (final r in rows as List)
          FeedItem.fromRow(r as Map<String, dynamic>),
        for (final r in cheers)
          FeedItem(
              name: ((r as Map)['display_name'] ??
                      S.instance.t('feed_friend', 'A friend'))
                  .toString(),
              amount: 0,
              reason: 'cheer',
              at: DateTime.tryParse(
                      (r['created_at'] ?? '').toString()) ??
                  DateTime.now()),
      ]..sort((a, b) => b.at.compareTo(a.at));
      if (mounted) setState(() => _items = items);
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
        Padding(
          padding: const EdgeInsets.only(top: 18, bottom: 8),
          child: Text(S.instance.t('feed_title', 'Friend activity'),
              style: const TextStyle(
                  fontWeight: FontWeight.w800, fontSize: 16)),
        ),
        for (final it in items.take(20)) _row(context, it),
      ],
    );
  }

  final Set<String> _cheered = {};

  Future<void> _cheer(FeedItem it) async {
    setState(() => _cheered.add(it.friendId));
    try {
      await Supabase.instance.client
          .from('feed_cheers')
          .insert({'to_user': it.friendId});
    } catch (_) {} // once-per-day unique: a repeat just no-ops
  }

  Widget _row(BuildContext context, FeedItem it) {
    final String what = it.reason == 'cheer'
        ? S.instance.t('feed_cheer', 'cheered you on!')
        : it.reason == 'chest'
            ? S.instance
                .t('feed_chest', 'opened a chest (+{n} XP)')
                .replaceAll('{n}', '${it.amount}')
            : S.instance
                .t('feed_xp', 'earned {n} XP')
                .replaceAll('{n}', '${it.amount}');
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
          if (it.reason != 'cheer' && it.friendId.isNotEmpty)
            IconButton(
              visualDensity: VisualDensity.compact,
              tooltip: S.instance.t('cheer_tip', 'Cheer'),
              onPressed: _cheered.contains(it.friendId)
                  ? null
                  : () => _cheer(it),
              icon: Icon(
                  _cheered.contains(it.friendId)
                      ? Icons.celebration
                      : Icons.celebration_outlined,
                  size: 18,
                  color: RatelColors.honey),
            ),
          Text(timeAgo(DateTime.now().difference(it.at)),
              style: const TextStyle(
                  color: RatelColors.textMuted, fontSize: 11.5)),
        ],
      ),
    );
  }
}
