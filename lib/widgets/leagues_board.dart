import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../theme.dart';

/// Weekly tiered league. Ranks the learners in your tier by this week's XP
/// (via the weekly_standings RPC); the top 5 are in the promotion zone, and
/// promotion/relegation rolls every Monday (roll_leagues, pg_cron).
class LeaguesBoard extends StatefulWidget {
  const LeaguesBoard({super.key});

  static const int promote = 5;

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
      final res = await c.rpc('weekly_standings');
      return List<Map<String, dynamic>>.from(res as List);
    } catch (_) {
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_client == null) {
      return _scaffold('Leagues',
          const Center(child: Text('Sign in to join a league.')));
    }
    final myId = _client?.auth.currentUser?.id;
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _future,
      builder: (context, snap) {
        if (snap.connectionState != ConnectionState.done) {
          return _scaffold(
              'Leagues', const Center(child: CircularProgressIndicator()));
        }
        final rows = snap.data ?? const [];
        final tier = rows.isNotEmpty
            ? (rows.first['tier'] ?? 'Bronze').toString()
            : 'Bronze';
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 2),
              child: Text('$tier League',
                  style: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.w700)),
            ),
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 0, 16, 4),
              child: Text('This week · top 5 advance · resets Monday',
                  style: TextStyle(color: RatelColors.textMuted)),
            ),
            Expanded(
              child: rows.isEmpty
                  ? const Center(child: Text('No one here yet — earn XP!'))
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: rows.length,
                      itemBuilder: (context, i) {
                        final r = rows[i];
                        final rank = i + 1;
                        final isYou = r['user_id'] == myId;
                        final promo = rank <= LeaguesBoard.promote;
                        final name =
                            (r['display_name'] ?? '').toString().trim();
                        final xp = (r['weekly_xp'] as num?)?.toInt() ?? 0;
                        return Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 10),
                          decoration: BoxDecoration(
                            color: isYou
                                ? const Color(0xFFFAEEDA)
                                : context.surfaceC,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                                color: promo
                                    ? RatelColors.teal.withValues(alpha: 0.5)
                                    : context.borderC),
                          ),
                          child: Row(
                            children: [
                              SizedBox(
                                width: 24,
                                child: Text('$rank',
                                    style: TextStyle(
                                        fontWeight: FontWeight.w700,
                                        color: promo
                                            ? RatelColors.teal
                                            : RatelColors.textMuted)),
                              ),
                              if (promo)
                                const Icon(Icons.arrow_upward,
                                    size: 14, color: RatelColors.teal),
                              const SizedBox(width: 6),
                              CircleAvatar(
                                radius: 16,
                                backgroundColor: isYou
                                    ? RatelColors.honey
                                    : const Color(0xFFE0E0E0),
                                child: Text(
                                    (name.isEmpty ? 'L' : name)
                                        .substring(0, 1)
                                        .toUpperCase(),
                                    style: const TextStyle(
                                        color: Colors.white, fontSize: 13)),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                    isYou
                                        ? '${name.isEmpty ? 'You' : name} (you)'
                                        : (name.isEmpty ? 'Learner' : name),
                                    style: TextStyle(
                                        fontWeight: isYou
                                            ? FontWeight.w700
                                            : FontWeight.w500)),
                              ),
                              Text('$xp XP',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                      color: RatelColors.textMuted)),
                            ],
                          ),
                        );
                      },
                    ),
            ),
          ],
        );
      },
    );
  }

  Widget _scaffold(String title, Widget body) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 2),
            child: Text(title,
                style:
                    const TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
          ),
          Expanded(child: body),
        ],
      );
}
