import 'package:flutter/material.dart';
import '../theme.dart';
import '../app_state.dart';
import '../content.dart';
import '../models.dart';
import '../screens/lesson_screen.dart';
import 'transitions.dart';

/// "Due for review" — the spaced-repetition entry point on the Learn screen.
/// Shows when the learner has exercises whose review is due, and launches a
/// no-stakes review drill of them. Listens to AppState so it updates after a
/// session (reviewed items reschedule out of the due window).
class ReviewCard extends StatefulWidget {
  const ReviewCard({super.key});

  @override
  State<ReviewCard> createState() => _ReviewCardState();
}

class _ReviewCardState extends State<ReviewCard> {
  @override
  void initState() {
    super.initState();
    appState.addListener(_onChange);
  }

  @override
  void dispose() {
    appState.removeListener(_onChange);
    super.dispose();
  }

  void _onChange() {
    if (mounted) setState(() {});
  }

  Future<void> _start() async {
    final exercises = <Exercise>[];
    final keys = <String>[];
    for (final k in appState.dueKeys) {
      final e = exerciseForKey(k);
      if (e != null) {
        exercises.add(e);
        keys.add(k);
      }
    }
    if (exercises.isEmpty) return;
    await Navigator.of(context).push(ratelRoute(LessonScreen(
      lesson: Lesson(id: 'review', title: 'Daily review', exercises: exercises),
      reviewMode: true,
      sourceKeys: keys,
    )));
    await appState.sync(); // refresh the due set (reviewed items reschedule)
  }

  @override
  Widget build(BuildContext context) {
    final n = appState.dueReviews;
    if (n <= 0) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: Material(
        color: RatelColors.teal.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: _start,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            child: Row(
              children: [
                const Icon(Icons.history_edu, color: RatelColors.teal),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('$n ${n == 1 ? 'exercise' : 'exercises'} due for review',
                          style: const TextStyle(
                              fontWeight: FontWeight.w700, fontSize: 14)),
                      const Text('Lock in what you have learned.',
                          style: TextStyle(
                              color: RatelColors.textMuted, fontSize: 12.5)),
                    ],
                  ),
                ),
                const Text('Review',
                    style: TextStyle(
                        color: RatelColors.teal, fontWeight: FontWeight.w700)),
                const Icon(Icons.chevron_right, color: RatelColors.teal),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
