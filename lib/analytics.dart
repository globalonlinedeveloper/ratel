import 'analytics_stub.dart'
    if (dart.library.js_interop) 'analytics_web.dart' as impl;

/// Crash-safe analytics facade. Logs to GA4 (Firebase Analytics) on the web;
/// a no-op on other platforms. All calls are wrapped so they can never throw.
class Analytics {
  Analytics._();

  static void log(String name, [Map<String, Object?> params = const {}]) =>
      impl.logEvent(name, params);

  static void signUp() => log('sign_up');
  static void login() => log('login');
  static void lessonStart(String lessonId) =>
      log('lesson_start', {'lesson_id': lessonId});
  static void lessonComplete(String lessonId, int xp, int correct, int total) =>
      log('lesson_complete',
          {'lesson_id': lessonId, 'xp': xp, 'correct': correct, 'total': total});
}
