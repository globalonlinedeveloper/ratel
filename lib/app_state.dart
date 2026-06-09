import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// App-wide state: XP, hearts, streak, and completed lessons.
///
/// Backed by Supabase when a user is signed in: [sync] loads the user's
/// profile from the database, and progress is persisted on lesson
/// completion. Falls back to in-memory only when Supabase isn't
/// configured or no user is signed in.
class AppState extends ChangeNotifier {
  int xp = 0;
  int hearts = 5;
  int streak = 0;
  int dailyGoalXp = 50;
  int todayXp = 0;
  String displayName = '';
  String email = '';
  bool loaded = false;
  final Set<String> _completed = <String>{};

  bool isCompleted(String lessonId) => _completed.contains(lessonId);
  int get completedCount => _completed.length;

  /// The Supabase client if initialized AND a user is signed in, else null.
  SupabaseClient? get _client {
    try {
      final client = Supabase.instance.client;
      return client.auth.currentSession != null ? client : null;
    } catch (_) {
      return null; // Supabase not initialized
    }
  }

  /// Load the signed-in user's progress from the database.
  Future<void> sync() async {
    final client = _client;
    if (client == null) {
      loaded = true;
      notifyListeners();
      return;
    }
    email = client.auth.currentUser?.email ?? '';
    try {
      final row = await client
          .from('profiles')
          .select('total_xp, current_streak, hearts, completed_lessons, display_name, daily_goal_xp')
          .eq('id', client.auth.currentUser!.id)
          .maybeSingle();
      if (row != null) {
        xp = (row['total_xp'] as int?) ?? xp;
        streak = (row['current_streak'] as int?) ?? streak;
        hearts = (row['hearts'] as int?) ?? hearts;
        displayName = (row['display_name'] as String?) ?? displayName;
        dailyGoalXp = (row['daily_goal_xp'] as int?) ?? dailyGoalXp;
        final dynamic cl = row['completed_lessons'];
        if (cl is List) {
          _completed
            ..clear()
            ..addAll(cl.map((e) => e.toString()));
        }
      }
    } catch (_) {
      // Keep current values if the read fails (e.g., column not migrated yet).
    }
    await _loadTodayXp(client);
    loaded = true;
    notifyListeners();
  }

  /// Sum XP earned since local midnight (for the daily goal).
  Future<void> _loadTodayXp(SupabaseClient client) async {
    try {
      final now = DateTime.now();
      final start =
          DateTime(now.year, now.month, now.day).toUtc().toIso8601String();
      final rows = await client
          .from('xp_events')
          .select('amount')
          .gte('created_at', start);
      var sum = 0;
      for (final r in List<Map<String, dynamic>>.from(rows)) {
        sum += (r['amount'] as num?)?.toInt() ?? 0;
      }
      todayXp = sum;
    } catch (_) {
      // leave todayXp as-is
    }
  }

  /// Log an XP event (fire-and-forget) — powers the daily goal + history.
  void _logXpEvent(int amount, String reason) {
    final client = _client;
    if (client == null) return;
    final uid = client.auth.currentUser?.id;
    if (uid == null) return;
    try {
      client.from('xp_events')
          .insert({'user_id': uid, 'amount': amount, 'reason': reason});
    } catch (_) {}
  }

  void loseHeart() {
    if (hearts > 0) {
      hearts -= 1;
      notifyListeners();
    }
  }

  void refillHearts() {
    hearts = 5;
    notifyListeners();
  }

  /// Clear all state on sign-out so the next user re-syncs from the database.
  void reset() {
    xp = 0;
    hearts = 5;
    streak = 0;
    todayXp = 0;
    displayName = '';
    email = '';
    loaded = false;
    _completed.clear();
    notifyListeners();
  }

  void completeLesson(String lessonId, int earnedXp) {
    _completed.add(lessonId);
    xp += earnedXp;
    todayXp += earnedXp;
    notifyListeners();
    _persist();
    _logXpEvent(earnedXp, 'lesson');
  }

  /// Log a single exercise attempt (fire-and-forget) for mistake analysis.
  /// Only runs when signed in; user_id is filled by the DB default (auth.uid()).
  Future<void> logAttempt({
    required String lessonId,
    required int exerciseIndex,
    required String prompt,
    required String chosen,
    required String correctAnswer,
    required bool isCorrect,
  }) async {
    final client = _client;
    if (client == null) return;
    try {
      await client.from('attempts').insert({
        'lesson_id': lessonId,
        'exercise_index': exerciseIndex,
        'exercise_key': '$lessonId:$exerciseIndex',
        'prompt': prompt,
        'chosen': chosen,
        'correct_answer': correctAnswer,
        'is_correct': isCorrect,
      });
    } catch (_) {
      // Non-blocking: ignore logging errors (offline, etc.).
    }
  }

  Future<void> _persist() async {
    final client = _client;
    if (client == null) return;
    try {
      await client.from('profiles').update({
        'total_xp': xp,
        'current_streak': streak,
        'hearts': hearts,
        'completed_lessons': _completed.toList(),
      }).eq('id', client.auth.currentUser!.id);
    } catch (_) {
      // Ignore persistence errors (e.g., offline); state stays in memory.
    }
  }
}

final AppState appState = AppState();
