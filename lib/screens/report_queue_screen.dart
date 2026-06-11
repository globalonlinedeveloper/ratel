import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../config.dart';
import '../content.dart';
import '../milestones.dart';
import '../theme.dart';

/// Admin triage: open exercise reports grouped by exercise, the live
/// prompt shown for context, one tap resolves the group.
class ReportQueueScreen extends StatefulWidget {
  const ReportQueueScreen({super.key, this.rowsOverride});

  final List<Map<String, dynamic>>? rowsOverride; // test injection

  @override
  State<ReportQueueScreen> createState() => _ReportQueueScreenState();
}

class _ReportQueueScreenState extends State<ReportQueueScreen> {
  List<ReportGroup>? _groups;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    if (widget.rowsOverride != null) {
      setState(() => _groups = groupReports(widget.rowsOverride!));
      return;
    }
    if (!Config.hasSupabase) {
      setState(() => _groups = const []);
      return;
    }
    try {
      final rows = await Supabase.instance.client
          .from('exercise_reports')
          .select('lesson_id, exercise_index, reason')
          .eq('resolved', false)
          .limit(200)
          .timeout(const Duration(seconds: 5));
      if (mounted) {
        setState(() => _groups =
            groupReports(List<Map<String, dynamic>>.from(rows)));
      }
    } catch (_) {
      if (mounted) setState(() => _groups = const []);
    }
  }

  String _promptFor(ReportGroup g) {
    for (final u in course) {
      for (final l in u.lessons) {
        if (l.id == g.lessonId &&
            g.exerciseIndex < l.exercises.length) {
          return l.exercises[g.exerciseIndex].prompt;
        }
      }
    }
    return '(exercise not in the current course)';
  }

  Future<void> _resolve(ReportGroup g) async {
    setState(() =>
        _groups = [..._groups!]..removeWhere((x) => x.key == g.key));
    if (widget.rowsOverride != null || !Config.hasSupabase) return;
    try {
      await Supabase.instance.client
          .from('exercise_reports')
          .update({'resolved': true})
          .eq('lesson_id', g.lessonId)
          .eq('exercise_index', g.exerciseIndex)
          .eq('resolved', false);
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final groups = _groups;
    return Scaffold(
      appBar: AppBar(title: const Text('Report queue')),
      body: groups == null
          ? const Center(child: CircularProgressIndicator())
          : groups.isEmpty
              ? const Center(
                  child: Text('No open reports — the content is happy!',
                      style: TextStyle(color: RatelColors.textMuted)))
              : ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    for (final g in groups)
                      Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: context.surfaceC,
                          borderRadius: BorderRadius.circular(12),
                          border:
                              Border.all(color: context.faintBorderC),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('${g.key} · ${g.count} '
                                'report${g.count == 1 ? '' : 's'}',
                                style: const TextStyle(
                                    fontWeight: FontWeight.w800)),
                            const SizedBox(height: 4),
                            Text(_promptFor(g),
                                style:
                                    const TextStyle(fontSize: 13.5)),
                            const SizedBox(height: 4),
                            Text(g.reasons,
                                style: const TextStyle(
                                    color: RatelColors.textMuted,
                                    fontSize: 12)),
                            const SizedBox(height: 8),
                            Align(
                              alignment: Alignment.centerRight,
                              child: OutlinedButton(
                                onPressed: () => _resolve(g),
                                child: const Text('Resolve'),
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
    );
  }
}
