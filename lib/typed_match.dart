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
bool typedAnswerMatches(String input, List<String> accepted) {
  final got = normalizeTyped(input);
  if (got.isEmpty) return false;
  for (final a in accepted) {
    if (normalizeTyped(a) == got) return true;
  }
  return false;
}
