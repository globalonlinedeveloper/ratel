import 'spelling.dart';

/// Lenient matching for free-typed answers. Keeps typing exercises fair:
/// case-insensitive, trimmed, surrounding punctuation stripped, internal
/// whitespace collapsed, and a single leading article (a/an/the) ignored —
/// so "The Shop." matches accepted answer "shop".
String normalizeTyped(String s) {
  var t = s.toLowerCase().trim();
  t = t.replaceAll(RegExp(r'[.!?,;:]'), '');
  t = t.replaceAll(RegExp(r'\s+'), ' ').trim();
  t = t.replaceFirst(RegExp(r'^(a|an|the)\s+'), '');
  return t;
}

/// True when [input] matches any of the [accepted] answers after normalising.
/// Empty input never matches.
/// Canonical comparison key: normalized (case/space/punctuation/article) AND
/// each remaining word spelling-canonicalized, so US/UK variants compare equal
/// while real typos do not.
String _canonKey(String s) {
  final n = normalizeTyped(s);
  if (n.isEmpty) return '';
  return n.split(' ').map(canonicalizeWord).join(' ');
}

bool typedAnswerMatches(String input, List<String> accepted) {
  final got = _canonKey(input);
  if (got.isEmpty) return false;
  for (final a in accepted) {
    if (_canonKey(a) == got) return true;
  }
  return false;
}
