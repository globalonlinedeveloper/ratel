import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../theme.dart';
import '../models.dart';
import '../content.dart';
import '../screens/lesson_screen.dart';
import 'transitions.dart';

/// "Review your mistakes": the signed-in user's unresolved misses, pulled from
/// public.attempts (RLS = own rows). Self-cleaning — an exercise only shows
/// while its *latest* attempt is wrong, so practicing it correctly removes it.
/// A "Practice these" button rebuilds a no-stakes review drill from the misses.
class MistakesReview extends StatefulWidget {
  const MistakesReview({super.key, this.limit = 5});

  final int limit;

  @override
  State<MistakesReview> createState() => _MistakesReviewState();
}

class _MistakesReviewState extends State<MistakesReview> {
  late Future<List<Map<String, dynamic>>> _future = _load();

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
          .select('exercise_key, prompt, chosen, correct_answer, is_correct, created_at')
          .order('created_at', ascending: false)
          .limit(120);
      final seen = <String>{};
      final out = <Map<String, dynamic>>[];
      for (final r in List<Map<String, dynamic>>.from(rows)) {
        final k = (r['exercise_key'] ?? '').toString();
        if (k.isEmpty || seen.contains(k)) continue;
        seen.add(k); // first occurrence (desc order) = the latest attempt
        if (r['is_correct'] == false) {
          out.add(r);
          if (out.length >= widget.limit) break;
        }
      }
      return out;
    } catch (_) {
      return [];
    }
  }

  Future<void> _practice(List<Map<String, dynamic>> items) async {
    final exercises = <Exercise>[];
    final sourceKeys = <String>[];
    for (final m in items) {
      final key = (m['exercise_key'] ?? '').toString();
      final ex = exerciseForKey(key);
      if (ex != null) {
        exercises.add(ex);
        sourceKeys.add(key);
      }
    }
    if (exercises.isEmpty) return;
    await Navigator.of(context).push(ratelRoute(LessonScreen(
      lesson: Lesson(
          id: 'review', title: 'Review mistakes', exercises: exercises),
      reviewMode: true,
      sourceKeys: sourceKeys,
    )));
    if (mounted) setState(() => _future = _load()); // refresh: fixed ones drop off
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
            const SizedBox(height: 4),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: () => _practice(items),
                icon: const Icon(Icons.fitness_center, size: 18),
                label: Text('Practice these ${items.length}'),
              ),
            ),
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
        color: context.surfaceC,
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
