import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../theme.dart';
import '../app_state.dart';

/// Real global leaderboard from `profiles` (public read), ranked by total XP.
/// Highlights the signed-in learner; if they're outside the top list, a footer
/// row shows their own XP. Falls back to a friendly note when signed out.
class LeaguesBoard extends StatefulWidget {
  const LeaguesBoard({super.key, this.top = 25});

  final int top;

  @override
  State<LeaguesBoard> createState() => _LeaguesBoardState();
}

class _LeaguesBoardState extends State<LeaguesBoard> {
  late final Future<List<Map<String, dynamic>>> _future = _load();

  SupabaseClient? get _client {
    try {
      final c = Supabase.instance.client;
      return c.auth.currentSession != null ? c : null;
    } catch (_) {
      return null;
    }
  }

  Future<List<Map<String, dynamic>>> _load() async {
    final c = _client;
    if (c == null) return [];
    try {
      final rows = await c
          .from('profiles')
          .select('id, display_name, total_xp')
          .order('total_xp', ascending: false)
          .order('updated_at', ascending: true)
          .limit(widget.top);
      return List<Map<String, dynamic>>.from(rows);
    } catch (_) {
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    final header = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const [
        Padding(
          padding: EdgeInsets.fromLTRB(16, 16, 16, 2),
          child: Text('Leaderboard',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
        ),
        Padding(
          padding: EdgeInsets.fromLTRB(16, 0, 16, 4),
          child: Text('Top learners by XP — climb by completing lessons.',
              style: TextStyle(color: RatelColors.textMuted)),
        ),
      ],
    );
    if (_client == null) {
      return Column(children: [
        header,
        const Expanded(
          child: Center(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: Text('Sign in to join the leaderboard.',
                  style: TextStyle(color: RatelColors.textMuted)),
            ),
          ),
        ),
      ]);
    }
    final myId = _client?.auth.currentUser?.id;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        header,
        Expanded(
          child: FutureBuilder<List<Map<String, dynamic>>>(
            future: _future,
            builder: (context, snap) {
              if (snap.connectionState != ConnectionState.done) {
                return const Center(child: CircularProgressIndicator());
              }
              final rows = snap.data ?? const [];
              if (rows.isEmpty) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(24),
                    child: Text('No learners yet — be the first!',
                        style: TextStyle(color: RatelColors.textMuted)),
                  ),
                );
              }
              final meInList = rows.any((r) => r['id'] == myId);
              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: rows.length + (meInList ? 0 : 1),
                itemBuilder: (context, i) {
                  if (i >= rows.length) {
                    // current user is outside the top list
                    return _row(rows.length + 1,
                        appState.displayName.isEmpty ? 'You' : appState.displayName,
                        appState.xp, true);
                  }
                  final r = rows[i];
                  final isYou = r['id'] == myId;
                  final name = (r['display_name'] ?? '').toString().trim();
                  return _row(i + 1, name.isEmpty ? 'Learner' : name,
                      (r['total_xp'] as num?)?.toInt() ?? 0, isYou);
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _row(int rank, String name, int xp, bool isYou) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: isYou ? const Color(0xFFFAEEDA) : RatelColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFEAEAEA)),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 24,
            child: Text('$rank',
                style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: rank <= 3 ? RatelColors.teal : RatelColors.textMuted)),
          ),
          const SizedBox(width: 8),
          CircleAvatar(
            radius: 16,
            backgroundColor:
                isYou ? RatelColors.honey : const Color(0xFFE0E0E0),
            child: Text(name.substring(0, 1).toUpperCase(),
                style: const TextStyle(color: Colors.white, fontSize: 13)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(isYou ? '$name (you)' : name,
                style: TextStyle(
                    fontWeight: isYou ? FontWeight.w700 : FontWeight.w500)),
          ),
          Text('$xp XP',
              style: const TextStyle(
                  fontWeight: FontWeight.w600, color: RatelColors.textMuted)),
        ],
      ),
    );
  }
}
