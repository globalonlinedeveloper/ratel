import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../theme.dart';

/// "Review your mistakes": pulls the signed-in user's recent wrong answers
/// from public.attempts (RLS = own rows), de-duplicated per exercise. Renders
/// nothing when signed out or when there's nothing to review.
class MistakesReview extends StatefulWidget {
  const MistakesReview({super.key, this.limit = 5});

  final int limit;

  @override
  State<MistakesReview> createState() => _MistakesReviewState();
}

class _MistakesReviewState extends State<MistakesReview> {
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
          .from('attempts')
          .select('exercise_key, prompt, chosen, correct_answer, created_at')
          .eq('is_correct', false)
          .order('created_at', ascending: false)
          .limit(60);
      final seen = <String>{};
      final out = <Map<String, dynamic>>[];
      for (final r in List<Map<String, dynamic>>.from(rows)) {
        final k = (r['exercise_key'] ?? '').toString();
        if (k.isEmpty || seen.contains(k)) continue;
        seen.add(k);
        out.add(r);
        if (out.length >= widget.limit) break;
      }
      return out;
    } catch (_) {
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_client == null) return const SizedBox.shrink();
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _future,
      builder: (context, snap) {
        if (snap.connectionState != ConnectionState.done) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Center(
              child: SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2)),
            ),
          );
        }
        final items = snap.data ?? const [];
        if (items.isEmpty) return const SizedBox.shrink();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.auto_stories,
                    color: RatelColors.coral, size: 18),
                const SizedBox(width: 6),
                Text('Review your mistakes (${items.length})',
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w700)),
              ],
            ),
            const SizedBox(height: 8),
            ...items.map(_card),
            const SizedBox(height: 16),
          ],
        );
      },
    );
  }

  Widget _card(Map<String, dynamic> m) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: RatelColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFF0D9BE)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text((m['prompt'] ?? '').toString(),
              style: const TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 6),
          Row(children: [
            const Icon(Icons.close, color: RatelColors.coral, size: 16),
            const SizedBox(width: 4),
            Expanded(
              child: Text('You said: ${m['chosen'] ?? ''}',
                  style: const TextStyle(color: RatelColors.textMuted)),
            ),
          ]),
          const SizedBox(height: 2),
          Row(children: [
            const Icon(Icons.check, color: RatelColors.teal, size: 16),
            const SizedBox(width: 4),
            Expanded(
              child: Text('Correct: ${m['correct_answer'] ?? ''}',
                  style: const TextStyle(
                      color: RatelColors.teal, fontWeight: FontWeight.w600)),
            ),
          ]),
        ],
      ),
    );
  }
}
