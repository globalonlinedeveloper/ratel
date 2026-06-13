import 'package:flutter/foundation.dart' show visibleForTesting;
import 'package:supabase_flutter/supabase_flutter.dart';

import 'config.dart';

/// Remote art delivery (Inc 140) — the index side of the public `art`
/// storage bucket. Mirrors the Flags/S pattern: a startup load of the
/// public-read `art_manifest` table (one row per processed catalog cell,
/// uploaded by tool/upload_art.py). Offline/slow/missing → the index stays
/// empty and every consumer falls back to bundled art (offline-first).
///
/// Resolution is BUNDLED-FIRST: core art ships in the app bundle forever
/// (the lean-bundle anti-goal — only NEW sets are delivered remotely), so a
/// name in [kBundledArt] always wins over the manifest. Adoption of remote
/// sets by features happens in separate future increments.
class Art {
  Art._();
  static final Art instance = Art._();

  /// Names that ship in the bundle and must never load remotely. Adoption
  /// increments add entries here when a remote name gains a bundled twin.
  static const Map<String, String> kBundledArt = {};

  final Map<String, String> _paths = {}; // manifest: name -> storage path
  final Map<String, String> _bundledOverride = {}; // tests only
  String _publicBase = '';

  Future<void> load() async {
    if (!Config.hasSupabase) return;
    _publicBase = '${Config.supabaseUrl}/storage/v1/object/public/art/';
    try {
      final rows = await Supabase.instance.client
          .from('art_manifest')
          .select('name, path')
          .eq('state', 'live')
          .timeout(const Duration(seconds: 4));
      for (final r in rows) {
        final name = (r['name'] ?? '').toString();
        final path = (r['path'] ?? '').toString();
        if (name.isNotEmpty && path.isNotEmpty) _paths[name] = path;
      }
    } catch (_) {
      // Defaults stand: bundled-only behavior, never a blank screen.
    }
  }

  /// Bundled asset path for [name], when the name ships in the bundle.
  String? bundledFor(String name) =>
      _bundledOverride[name] ?? kBundledArt[name];

  /// Public storage URL for a manifest-listed [name]; null when the name is
  /// bundled (bundled-first) or unknown (caller falls back to bundled art).
  String? urlFor(String name) {
    if (bundledFor(name) != null) return null;
    final p = _paths[name];
    if (p == null || _publicBase.isEmpty) return null;
    return '$_publicBase$p';
  }

  /// Whether [name] resolves at all (bundled or remote).
  bool has(String name) =>
      bundledFor(name) != null || _paths.containsKey(name);

  @visibleForTesting
  void debugSet({
    Map<String, String>? paths,
    String? publicBase,
    Map<String, String>? bundled,
  }) {
    if (paths != null) {
      _paths
        ..clear()
        ..addAll(paths);
    }
    if (publicBase != null) _publicBase = publicBase;
    if (bundled != null) {
      _bundledOverride
        ..clear()
        ..addAll(bundled);
    }
  }
}
