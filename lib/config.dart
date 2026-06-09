/// Runtime configuration, supplied at launch via:
///   flutter run -d chrome --dart-define-from-file=config.json
///
/// `config.json` is GITIGNORED — never commit it. A template lives in
/// `config.example.json`. The Supabase anon key is safe to embed in the
/// client (it is protected by row-level security); the DB password and
/// service_role key must NEVER appear here.
class Config {
  static const String supabaseUrl = String.fromEnvironment('SUPABASE_URL');
  static const String supabaseAnonKey =
      String.fromEnvironment('SUPABASE_ANON_KEY');

  /// True once Supabase config has been provided at launch.
  static bool get hasSupabase =>
      supabaseUrl.isNotEmpty && supabaseAnonKey.isNotEmpty;
}
