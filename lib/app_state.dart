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
  int lessonsToday = 0;
  int longestStreak = 0;
  int streakFreezes = 2;
  String displayName = '';
  String email = '';
  bool loaded = false;
  bool isAdmin = false;
  bool onboarded = true;
  bool isPro = false;
  List<String> dueKeys = [];
  final Set<String> _completed = <String>{};

  bool isCompleted(String lessonId) => _completed.contains(lessonId);
  int get completedCount => _completed.length;
  int get dueReviews => dueKeys.length;

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
          .select('total_xp, current_streak, hearts, completed_lessons, display_name, daily_goal_xp, longest_streak, streak_freezes, is_admin')
          .eq('id', client.auth.currentUser!.id)
          .maybeSingle();
      if (row != null) {
        xp = (row['total_xp'] as int?) ?? xp;
        streak = (row['current_streak'] as int?) ?? streak;
        hearts = (row['hearts'] as int?) ?? hearts;
        displayName = (row['display_name'] as String?) ?? displayName;
        dailyGoalXp = (row['daily_goal_xp'] as int?) ?? dailyGoalXp;
        longestStreak = (row['longest_streak'] as int?) ?? longestStreak;
        streakFreezes = (row['streak_freezes'] as int?) ?? streakFreezes;
        isAdmin = (row['is_admin'] as bool?) ?? false;
        onboarded = (row['onboarded'] as bool?) ?? true;
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
    await _loadPro(client);
    await _loadDueReviews(client);
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
          .select('amount, reason')
          .gte('created_at', start);
      var sum = 0;
      var lessons = 0;
      for (final r in List<Map<String, dynamic>>.from(rows)) {
        sum += (r['amount'] as num?)?.toInt() ?? 0;
        if ((r['reason'] ?? '').toString() == 'lesson') lessons++;
      }
      todayXp = sum;
      lessonsToday = lessons;
    } catch (_) {
      // leave todayXp as-is
    }
  }

  /// Read the user's subscription; Pro = an active/trialing, unexpired row.
  Future<void> _loadPro(SupabaseClient client) async {
    try {
      final rows = await client
          .from('subscriptions')
          .select('status, expires_at');
      isPro = false;
    dueKeys = [];
      for (final r in List<Map<String, dynamic>>.from(rows)) {
        final status = (r['status'] ?? '').toString();
        final active = status == 'active' || status == 'trialing';
        final exp = r['expires_at'];
        final notExpired = exp == null ||
            (DateTime.tryParse(exp.toString())?.isAfter(DateTime.now()) ?? false);
        if (active && notExpired) {
          isPro = true;
          break;
        }
      }
    } catch (_) {}
  }

  /// Start the 7-day Pro trial (test mode — real billing replaces the RPC).
  Future<void> startProTrial() async {
    final client = _client;
    if (client == null) return;
    try {
      await client.rpc('start_pro_trial');
      isPro = true;
      notifyListeners();
    } catch (_) {}
  }

  Future<void> cancelPro() async {
    final client = _client;
    if (client == null) return;
    try {
      await client.rpc('cancel_pro');
      isPro = false;
      notifyListeners();
    } catch (_) {}
  }

  /// Load exercises whose spaced-repetition review is due (due_on <= today).
  Future<void> _loadDueReviews(SupabaseClient client) async {
    try {
      final today = DateTime.now().toIso8601String().split('T').first;
      final rows = await client
          .from('review_state')
          .select('exercise_key')
          .lte('due_on', today)
          .order('due_on')
          .limit(30);
      dueKeys = List<Map<String, dynamic>>.from(rows)
          .map((r) => (r['exercise_key'] ?? '').toString())
          .where((k) => k.isNotEmpty)
          .toList();
    } catch (_) {
      dueKeys = [];
    }
  }

  /// Record an answer into the spaced-repetition schedule (fire-and-forget).
  void recordReview(String exerciseKey, bool correct) {
    final client = _client;
    if (client == null || exerciseKey.isEmpty) return;
    try {
      client.rpc('review_answer',
          params: {'p_key': exerciseKey, 'p_correct': correct});
    } catch (_) {}
  }

  /// Set the daily XP goal (onboarding / settings). Persists to the profile.
  Future<void> setDailyGoal(int xp) async {
    dailyGoalXp = xp;
    notifyListeners();
    final client = _client;
    if (client == null) return;
    try {
      await client.from('profiles')
          .update({'daily_goal_xp': xp}).eq('id', client.auth.currentUser!.id);
    } catch (_) {}
  }

  /// Mark first-run onboarding complete.
  Future<void> markOnboarded() async {
    onboarded = true;
    notifyListeners();
    final client = _client;
    if (client == null) return;
    try {
      await client.from('profiles')
          .update({'onboarded': true}).eq('id', client.auth.currentUser!.id);
    } catch (_) {}
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

  /// Update the date-based streak server-side (touch_streak RPC) and reflect
  /// the result locally. Streak freezes can save a single missed day.
  Future<void> touchStreak() async {
    final client = _client;
    if (client == null) return;
    try {
      final res = await client.rpc('touch_streak');
      final rows = List<Map<String, dynamic>>.from(res as List);
      if (rows.isNotEmpty) {
        final r = rows.first;
        streak = (r['current_streak'] as num?)?.toInt() ?? streak;
        longestStreak = (r['longest_streak'] as num?)?.toInt() ?? longestStreak;
        streakFreezes = (r['streak_freezes'] as num?)?.toInt() ?? streakFreezes;
        notifyListeners();
      }
    } catch (_) {}
  }

  void loseHeart() {
    if (isPro) return; // Pro: unlimited hearts
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
    longestStreak = 0;
    streakFreezes = 2;
    todayXp = 0;
    lessonsToday = 0;
    displayName = '';
    email = '';
    loaded = false;
    isAdmin = false;
    onboarded = true;
    isPro = false;
    _completed.clear();
    notifyListeners();
  }

  void completeLesson(String lessonId, int earnedXp) {
    _completed.add(lessonId);
    xp += earnedXp;
    todayXp += earnedXp;
    lessonsToday += 1;
    notifyListeners();
    _persist();
    _logXpEvent(earnedXp, 'lesson');
    touchStreak();
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
