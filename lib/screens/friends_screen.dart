import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme.dart';
import '../app_state.dart';
import '../widgets/streak_flame.dart';

/// Friends: share your code, add friends by code, and see their streaks + XP.
class FriendsScreen extends StatefulWidget {
  const FriendsScreen({super.key});

  @override
  State<FriendsScreen> createState() => _FriendsScreenState();
}

class _FriendsScreenState extends State<FriendsScreen> {
  final _codeCtrl = TextEditingController();
  late Future<List<Map<String, dynamic>>> _friends = appState.loadFriends();
  bool _adding = false;

  @override
  void dispose() {
    _codeCtrl.dispose();
    super.dispose();
  }

  Future<void> _add() async {
    final code = _codeCtrl.text.trim();
    if (code.isEmpty) return;
    setState(() => _adding = true);
    final res = await appState.addFriend(code);
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(res.message)));
    setState(() {
      _adding = false;
      if (res.ok) {
        _codeCtrl.clear();
        _friends = appState.loadFriends();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Friends')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: RatelColors.honey.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: RatelColors.honey.withValues(alpha: 0.4)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Your friend code',
                          style: TextStyle(color: RatelColors.textMuted)),
                      const SizedBox(height: 2),
                      Text(
                          appState.friendCode.isEmpty
                              ? '——————'
                              : appState.friendCode,
                          style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 2)),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.copy),
                  tooltip: 'Copy',
                  onPressed: appState.friendCode.isEmpty
                      ? null
                      : () {
                          Clipboard.setData(
                              ClipboardData(text: appState.friendCode));
                          ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Code copied')));
                        },
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _codeCtrl,
                  textCapitalization: TextCapitalization.characters,
                  decoration: const InputDecoration(
                    labelText: "Add a friend's code",
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              FilledButton(
                onPressed: _adding ? null : _add,
                child: Text(_adding ? '…' : 'Add'),
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Text('Your friends',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
          const SizedBox(height: 8),
          FutureBuilder<List<Map<String, dynamic>>>(
            future: _friends,
            builder: (context, snap) {
              if (snap.connectionState != ConnectionState.done) {
                return const Padding(
                  padding: EdgeInsets.all(16),
                  child: Center(child: CircularProgressIndicator()),
                );
              }
              final friends = snap.data ?? const [];
              if (friends.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: Text('No friends yet — share your code to add some!',
                      style: TextStyle(color: RatelColors.textMuted)),
                );
              }
              return Column(children: [for (final f in friends) _friendRow(f)]);
            },
          ),
        ],
      ),
    );
  }

  Widget _friendRow(Map<String, dynamic> f) {
    final name = (f['display_name'] ?? 'Learner').toString();
    final streak = (f['current_streak'] as num?)?.toInt() ?? 0;
    final xp = (f['total_xp'] as num?)?.toInt() ?? 0;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: RatelColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFEAEAEA)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: const Color(0xFFE0E0E0),
            child: Text(name.substring(0, 1).toUpperCase(),
                style: const TextStyle(color: Colors.white, fontSize: 13)),
          ),
          const SizedBox(width: 12),
          Expanded(
              child: Text(name,
                  style: const TextStyle(fontWeight: FontWeight.w600))),
          StreakFlame(streak: streak, size: 18),
          const SizedBox(width: 2),
          Text('$streak',
              style: const TextStyle(
                  color: RatelColors.coral, fontWeight: FontWeight.w600)),
          const SizedBox(width: 12),
          Text('$xp XP',
              style: const TextStyle(color: RatelColors.textMuted)),
        ],
      ),
    );
  }
}
