import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../app_state.dart';
import '../config.dart';
import '../content.dart';
import '../milestones.dart';
import '../models.dart';
import '../screens/lesson_screen.dart';
import '../theme.dart';
import '../widgets/transitions.dart';

/// One tap -> a personal no-stakes drill: due reviews + fresh mistakes
/// + weak-area items, deduped and capped (pure composeDrill).
class SmartPracticeCard extends StatelessWidget {
  const SmartPracticeCard({super.key, this.keysOverride});

  final List<String>? keysOverride; // test injection

  Future<List<String>> _gather() async {
    if (keysOverride != null) return keysOverride!;
    if (!Config.hasSupabase) return const [];
    final c = Supabase.instance.client;
    final uid = c.auth.currentUser?.id;
    if (uid == null) return const [];
    List<String> due = const [], mistakes = const [], weak = const [];
    try {
      due = List<String>.from(appState.dueKeys);
    } catch (_) {}
    try {
      final rows = await c
          .from('attempts')
          .select('exercise_key, is_correct, created_at')
          .eq('user_id', uid)
          .order('created_at', ascending: false)
          .limit(60)
          .timeout(const Duration(seconds: 5));
      final latest = <String, bool>{};
      for (final r in rows) {
        final k = (r['exercise_key'] ?? '').toString();
        latest.putIfAbsent(k, () => (r['is_correct'] as bool?) ?? true);
      }
      mistakes = [
        for (final e in latest.entries)
          if (!e.value) e.key
      ];
    } catch (_) {}
    try {
      final rows = await c
          .rpc('my_weak_areas')
          .timeout(const Duration(seconds: 5));
      weak = [
        for (final r in rows as List)
          for (final l in course.expand((u) => u.lessons))
            if (l.id == (r['lesson_id'] ?? '').toString())
              for (int i = 0; i < l.exercises.length && i < 2; i++)
                '${l.id}:$i'
      ];
    } catch (_) {}
    return composeDrill(due: due, mistakes: mistakes, weak: weak);
  }

  Future<void> _start(BuildContext context, List<String> keys) async {
    final exercises = <Exercise>[];
    final sourceKeys = <String>[];
    for (final key in keys) {
      final ex = exerciseForKey(key);
      if (ex != null) {
        exercises.add(ex);
        sourceKeys.add(key);
      }
    }
    if (exercises.isEmpty || !context.mounted) return;
    await Navigator.of(context).push(ratelRoute(LessonScreen(
      lesson: Lesson(
          id: 'smart', title: 'Smart practice', exercises: exercises),
      reviewMode: true,
      sourceKeys: sourceKeys,
    )));
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<String>>(
      future: _gather(),
      builder: (context, snap) {
        final keys = snap.data ?? const [];
        if (keys.isEmpty) return const SizedBox.shrink();
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: context.tintC(RatelColors.teal),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: context.faintBorderC),
          ),
          child: Row(
            children: [
              const Icon(Icons.auto_awesome, color: RatelColors.teal),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Smart practice',
                        style: TextStyle(fontWeight: FontWeight.w800)),
                    Text(
                        '${keys.length} items picked for you — reviews, '
                        'misses and weak spots',
                        style: const TextStyle(
                            color: RatelColors.textMuted,
                            fontSize: 12)),
                  ],
                ),
              ),
              FilledButton(
                style: FilledButton.styleFrom(
                    backgroundColor: RatelColors.teal,
                    visualDensity: VisualDensity.compact),
                onPressed: () => _start(context, keys),
                child: const Text('Start'),
              ),
            ],
          ),
        );
      },
    );
  }
}
