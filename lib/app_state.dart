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
    try {
      final row = await client
          .from('profiles')
          .select('total_xp, current_streak, hearts, completed_lessons')
          .eq('id', client.auth.currentUser!.id)
          .maybeSingle();
      if (row != null) {
        xp = (row['total_xp'] as int?) ?? xp;
        streak = (row['current_streak'] as int?) ?? streak;
        hearts = (row['hearts'] as int?) ?? hearts;
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
    loaded = true;
    notifyListeners();
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
    loaded = false;
    _completed.clear();
    notifyListeners();
  }

  void completeLesson(String lessonId, int earnedXp) {
    _completed.add(lessonId);
    xp += earnedXp;
    notifyListeners();
    _persist();
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
