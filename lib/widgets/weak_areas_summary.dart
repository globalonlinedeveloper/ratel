import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../theme.dart';
import '../content.dart';

/// A no-cost analytics card: overall accuracy + the lessons the signed-in user
/// struggles with most, from the my_weak_areas() RPC (per-lesson stats over
/// public.attempts, own rows only). Renders nothing when signed out / no data.
class WeakAreasSummary extends StatefulWidget {
  const WeakAreasSummary({super.key});

  @override
  State<WeakAreasSummary> createState() => _WeakAreasSummaryState();
}

class _WeakAreasSummaryState extends State<WeakAreasSummary> {
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
      final res = await c.rpc('my_weak_areas');
      return List<Map<String, dynamic>>.from(res as List);
    } catch (_) {
      return [];
    }
  }

  int _i(dynamic v) => (v as num?)?.toInt() ?? 0;

  @override
  Widget build(BuildContext context) {
    if (_client == null) return const SizedBox.shrink();
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _future,
      builder: (context, snap) {
        if (snap.connectionState != ConnectionState.done) {
          return const SizedBox.shrink();
        }
        final rows = snap.data ?? const [];
        var total = 0, wrong = 0;
        for (final r in rows) {
          total += _i(r['total']);
          wrong += _i(r['wrong']);
        }
        if (total == 0) return const SizedBox.shrink();
        final acc = ((total - wrong) * 100 / total).round();
        final weak =
            rows.where((r) => _i(r['wrong']) > 0).take(3).toList();
        return Container(
          margin: const EdgeInsets.fromLTRB(16, 4, 16, 8),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: RatelColors.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFEAEAEA)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Your accuracy',
                  style: TextStyle(
                      fontWeight: FontWeight.w700, fontSize: 16)),
              const SizedBox(height: 4),
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text('$acc%',
                      style: TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.w800,
                          color: acc >= 80
                              ? RatelColors.teal
                              : (acc >= 60
                                  ? RatelColors.honey
                                  : RatelColors.coral))),
                  const SizedBox(width: 8),
                  Text('over $total answers',
                      style: const TextStyle(color: RatelColors.textMuted)),
                ],
              ),
              if (weak.isNotEmpty) ...[
                const SizedBox(height: 12),
                const Text('Work on these:',
                    style: TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 6),
                ...weak.map((r) {
                  final id = (r['lesson_id'] ?? '').toString();
                  final title = lessonTitleForId(id) ?? id;
                  final a = _i(r['accuracy']);
                  final w = _i(r['wrong']);
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Row(
                      children: [
                        const Icon(Icons.trending_up,
                            color: RatelColors.coral, size: 16),
                        const SizedBox(width: 6),
                        Expanded(
                            child: Text(title,
                                style: const TextStyle(
                                    fontWeight: FontWeight.w500))),
                        Text('$a% · $w missed',
                            style: const TextStyle(
                                color: RatelColors.textMuted, fontSize: 13)),
                      ],
                    ),
                  );
                }),
              ],
            ],
          ),
        );
      },
    );
  }
}
