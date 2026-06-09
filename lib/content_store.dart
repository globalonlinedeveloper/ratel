import 'package:supabase_flutter/supabase_flutter.dart';
import 'models.dart';
import 'content.dart';

/// Loads lesson content from Supabase (public read) and swaps it in for the
/// built-in course. If the DB is empty, slow, or unreachable, the built-in
/// course stays active — so content is never blank and the app works offline.
/// Lesson ids + exercise order match the built-in set, keeping attempt and
/// explanation keys (lessonId:sortOrder) stable.
class ContentStore {
  ContentStore._();
  static final ContentStore instance = ContentStore._();

  Future<void> load() async {
    try {
      final c = Supabase.instance.client;
      final res = await Future.wait([
        c.from('content_units').select('id,title,subtitle,sort_order'),
        c.from('content_lessons').select('id,unit_id,title,sort_order'),
        c.from('content_exercises').select(
            'lesson_id,sort_order,type,prompt,sentence,options,correct_index,correct_order'),
      ]).timeout(const Duration(seconds: 5));
      final built = _assemble(
        List<Map<String, dynamic>>.from(res[0] as List),
        List<Map<String, dynamic>>.from(res[1] as List),
        List<Map<String, dynamic>>.from(res[2] as List),
      );
      if (built.isNotEmpty) setActiveCourse(built);
    } catch (_) {
      // Keep the built-in course.
    }
  }

  List<String> _strs(dynamic v) =>
      (v is List) ? v.map((e) => e.toString()).toList() : <String>[];

  List<Unit> _assemble(
    List<Map<String, dynamic>> units,
    List<Map<String, dynamic>> lessons,
    List<Map<String, dynamic>> exercises,
  ) {
    int ord(Map<String, dynamic> m) => (m['sort_order'] as num?)?.toInt() ?? 0;

    // exercises grouped by lesson, sorted by sort_order
    final exByLesson = <String, List<Map<String, dynamic>>>{};
    for (final e in exercises) {
      (exByLesson[(e['lesson_id'] ?? '').toString()] ??= []).add(e);
    }
    Exercise toExercise(Map<String, dynamic> e) {
      final type = (e['type'] ?? '').toString();
      final opts = _strs(e['options']);
      final prompt = (e['prompt'] ?? '').toString();
      if (type == 'wordBank') {
        return Exercise.wordBank(
            prompt: prompt, options: opts, correctOrder: _strs(e['correct_order']));
      }
      return Exercise.choice(
        prompt: prompt,
        sentence: e['sentence'] as String?,
        options: opts,
        correctIndex: (e['correct_index'] as num?)?.toInt() ?? 0,
      );
    }

    // lessons grouped by unit, sorted by sort_order
    final lessonsByUnit = <String, List<Map<String, dynamic>>>{};
    for (final l in lessons) {
      (lessonsByUnit[(l['unit_id'] ?? '').toString()] ??= []).add(l);
    }

    final out = <Unit>[];
    final sortedUnits = [...units]..sort((a, b) => ord(a).compareTo(ord(b)));
    for (final u in sortedUnits) {
      final uid = (u['id'] ?? '').toString();
      final uLessons = [...(lessonsByUnit[uid] ?? [])]
        ..sort((a, b) => ord(a).compareTo(ord(b)));
      final builtLessons = <Lesson>[];
      for (final l in uLessons) {
        final lid = (l['id'] ?? '').toString();
        final exs = [...(exByLesson[lid] ?? [])]
          ..sort((a, b) => ord(a).compareTo(ord(b)));
        builtLessons.add(Lesson(
          id: lid,
          title: (l['title'] ?? '').toString(),
          exercises: exs.map(toExercise).toList(),
        ));
      }
      if (builtLessons.isEmpty) continue;
      out.add(Unit(
        title: (u['title'] ?? '').toString(),
        subtitle: (u['subtitle'] ?? '').toString(),
        lessons: builtLessons,
      ));
    }
    return out;
  }
}
