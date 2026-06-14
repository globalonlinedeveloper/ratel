import 'package:flutter/material.dart';
import '../strings.dart';
import 'ratel_mascot.dart';
import 'mascot_anim.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../theme.dart';
import 'skeleton.dart';
import 'empty_state.dart';

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
          Center(
          child: Text(S.instance
              .t('lg_signin', 'Sign in to join a league.'))));
    }
    final myId = _client?.auth.currentUser?.id;
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _future,
      builder: (context, snap) {
        if (snap.connectionState != ConnectionState.done) {
          return _scaffold('Leagues', const SkeletonList(rows: 6));
        }
        final rows = snap.data ?? const [];
        final tier = rows.isNotEmpty
            ? (rows.first['tier'] ?? 'Bronze').toString()
            : 'Bronze';
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(RatelSpacing.lg, RatelSpacing.lg, RatelSpacing.lg, 2),
              child: Text('$tier ${S.instance.t('lg_league', 'League')}',
                  style: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.w700)),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(RatelSpacing.lg, 0, RatelSpacing.lg, RatelSpacing.xs),
              child: Row(
                children: [
                  Text(S.instance.t('lg_week', 'This week · top 5 advance'),
                      style: TextStyle(color: RatelColors.textMuted)),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                        color: context.tintC(RatelColors.coral),
                        borderRadius: BorderRadius.circular(10)),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.timer_outlined,
                            size: 13, color: RatelColors.coral),
                        const SizedBox(width: 3),
                        Text(resetCountdownLabel(DateTime.now().toUtc()),
                            style: const TextStyle(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w700,
                                color: RatelColors.coral)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            if (rows.isNotEmpty && rows.length < 5)
              Padding(
                padding: const EdgeInsets.fromLTRB(RatelSpacing.lg, 2, RatelSpacing.lg, 2),
                child: Text(
                    'Quiet week — invite friends from Profile and race them!',
                    style: TextStyle(
                        color: context.mutedC, fontSize: 12.5)),
              ),
            Builder(builder: (context) {
              final int myRank =
                  rows.indexWhere((r) => r['user_id'] == myId) + 1;
              if (myRank < 1 || myRank > 5) {
                return const SizedBox.shrink();
              }
              return Padding(
                padding: const EdgeInsets.fromLTRB(RatelSpacing.lg, 2, RatelSpacing.lg, 2),
                child: Row(
                  children: [
                    const ExcludeSemantics(child: RatelActionAnim(
                        action: 'trophy',
                        fallbackPose: RatelPose.celebrate,
                        size: 52)),
                    const SizedBox(width: RatelSpacing.sm),
                    Expanded(
                      child: Text(
              S.instance.t('lg_promo', 'Promotion zone — hold your spot!'),
                          style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              color: RatelColors.honey)),
                    ),
                  ],
                ),
              );
            }),
            Expanded(
              child: rows.isEmpty
                  ? const RatelEmptyState(
                      action: 'digging',
                      title: 'No one here yet',
                      subtitle:
                          'Earn XP this week to enter the league and climb the board.')
                  : ListView.builder(
                      padding: const EdgeInsets.all(RatelSpacing.lg),
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
                          margin: const EdgeInsets.only(bottom: RatelSpacing.sm),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 10),
                          decoration: BoxDecoration(
                            color: isYou
                                ? context.tintC(RatelColors.honey)
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
                                    : context.borderC,
                                child: Text(
                                    (name.isEmpty ? 'L' : name)
                                        .substring(0, 1)
                                        .toUpperCase(),
                                    style: const TextStyle(
                                        color: Colors.white, fontSize: 13)),
                              ),
                              const SizedBox(width: RatelSpacing.md),
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
            padding: const EdgeInsets.fromLTRB(RatelSpacing.lg, RatelSpacing.lg, RatelSpacing.lg, 2),
            child: Text(title,
                style:
                    const TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
          ),
          Expanded(child: body),
        ],
      );
}

/// "Resets in 2d 14h" — time until next Monday 00:00 UTC (roll_leagues cron).
/// Pure for testability.
String resetCountdownLabel(DateTime nowUtc) {
  int daysAhead = (DateTime.monday - nowUtc.weekday) % 7;
  DateTime next = DateTime.utc(nowUtc.year, nowUtc.month, nowUtc.day)
      .add(Duration(days: daysAhead));
  if (!next.isAfter(nowUtc)) next = next.add(const Duration(days: 7));
  final d = next.difference(nowUtc);
  if (d.inDays >= 1) {
    return S.instance
        .t('resets_dh', 'Resets in {d}d {h}h')
        .replaceAll('{d}', '${d.inDays}')
        .replaceAll('{h}', '${d.inHours % 24}');
  }
  if (d.inHours >= 1) {
    return S.instance
        .t('resets_hm', 'Resets in {h}h {m}m')
        .replaceAll('{h}', '${d.inHours}')
        .replaceAll('{m}', '${d.inMinutes % 60}');
  }
  return S.instance
      .t('resets_m', 'Resets in {m}m')
      .replaceAll('{m}', '${d.inMinutes}');
}
