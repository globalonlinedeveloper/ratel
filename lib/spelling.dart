/// Pure, locale-aware spelling/vocabulary canonicalization for the answer
/// checker (Part B / W1). Two learners who write the same word in different
/// English variants — colour/color, realise/realize, lift/elevator — are BOTH
/// correct; a real typo is NOT. We deliberately do NOT fuzzy/edit-distance
/// match: that would pass typos and stop teaching spelling. canonicalize maps
/// known variants (a curated, locale-LABELED map) + applies a few regular
/// rules to a single canonical token; equal canonical forms ⇒ a match.
library;

/// A locale-LABELED equivalence: the US form and the UK form of one word.
/// en-IN / en-AU share the UK ("gb") form. The canonical token is the US form.
class SpellingPair {
  const SpellingPair(this.us, this.gb);
  final String us;
  final String gb;
}

/// Curated US↔UK SPELLING pairs (canonical = us). Covers the irregular +
/// high-frequency cases (especially the doubled-"l" family, which a blanket
/// rule would wrongly merge with fill/call/sell). Drives both matching and the
/// locale-aware tip.
const List<SpellingPair> kSpellingPairs = [
  SpellingPair('color', 'colour'),
  SpellingPair('colors', 'colours'),
  SpellingPair('favorite', 'favourite'),
  SpellingPair('favorites', 'favourites'),
  SpellingPair('favor', 'favour'),
  SpellingPair('honor', 'honour'),
  SpellingPair('neighbor', 'neighbour'),
  SpellingPair('flavor', 'flavour'),
  SpellingPair('humor', 'humour'),
  SpellingPair('labor', 'labour'),
  SpellingPair('behavior', 'behaviour'),
  SpellingPair('center', 'centre'),
  SpellingPair('centers', 'centres'),
  SpellingPair('theater', 'theatre'),
  SpellingPair('meter', 'metre'),
  SpellingPair('liter', 'litre'),
  SpellingPair('fiber', 'fibre'),
  SpellingPair('traveling', 'travelling'),
  SpellingPair('traveled', 'travelled'),
  SpellingPair('traveler', 'traveller'),
  SpellingPair('canceled', 'cancelled'),
  SpellingPair('canceling', 'cancelling'),
  SpellingPair('modeling', 'modelling'),
  SpellingPair('labeled', 'labelled'),
  SpellingPair('jewelry', 'jewellery'),
  SpellingPair('gray', 'grey'),
  SpellingPair('practice', 'practise'),
  SpellingPair('license', 'licence'),
  SpellingPair('defense', 'defence'),
  SpellingPair('offense', 'offence'),
  SpellingPair('pajamas', 'pyjamas'),
  SpellingPair('apologize', 'apologise'),
  SpellingPair('organize', 'organise'),
  SpellingPair('organized', 'organised'),
  SpellingPair('realize', 'realise'),
  SpellingPair('recognize', 'recognise'),
  SpellingPair('personalize', 'personalise'),
  SpellingPair('customize', 'customise'),
  SpellingPair('analyze', 'analyse'),
  SpellingPair('memorize', 'memorise'),
  SpellingPair('summarize', 'summarise'),
  SpellingPair('catalog', 'catalogue'),
  SpellingPair('dialog', 'dialogue'),
];

/// Vocabulary synonyms across variants (US↔UK). Optional + tunable: default
/// ACCEPT. Unlike spelling, these are distinct words, so the list is curated
/// to unambiguous nouns to avoid homonym mis-grading.
const List<SpellingPair> kVocabPairs = [
  SpellingPair('elevator', 'lift'),
  SpellingPair('apartment', 'flat'),
  SpellingPair('truck', 'lorry'),
  SpellingPair('vacation', 'holiday'),
  SpellingPair('fall', 'autumn'),
  SpellingPair('cookie', 'biscuit'),
  SpellingPair('candy', 'sweets'),
  SpellingPair('subway', 'underground'),
  SpellingPair('gas', 'petrol'),
  SpellingPair('diaper', 'nappy'),
  SpellingPair('flashlight', 'torch'),
  SpellingPair('sweater', 'jumper'),
  SpellingPair('trash', 'rubbish'),
];

/// Master toggle for the vocab allow-list (spec: optional, default accept).
const bool kAcceptVocabSynonyms = true;

// Closed sets of words that END like a rule but are NOT US/UK variants — kept
// out of the rules so a typo can't sneak through (and we keep teaching spelling).
const Set<String> _iseKeep = {
  'noise', 'poise', 'raise', 'praise', 'cruise', 'bruise', 'wise', 'rise',
  'arise', 'otherwise', 'likewise', 'size', 'anise', 'paradise', 'tortoise',
  'porpoise', 'turquoise', 'mayonnaise', 'valise', 'malaise', 'mortise',
  'treatise', 'expertise', 'surprise', 'exercise', 'advise', 'devise', 'revise',
  'supervise', 'improvise', 'comprise', 'despise', 'demise', 'premise',
  'promise', 'compromise', 'disguise', 'franchise', 'merchandise', 'enterprise',
  'chastise', 'prise', 'guise', 'reprise', 'apprise', 'excise', 'incise',
  'concise', 'precise',
};
const Set<String> _ourKeep = {
  'devour', 'contour', 'velour', 'detour', 'paramour', 'troubadour', 'tambour',
};
const Set<String> _reKeep = {
  'genre', 'acre', 'ogre', 'massacre', 'mediocre', 'macabre', 'cadre', 'oeuvre',
};

Map<String, String>? _canonCache;
Map<String, SpellingPair>? _pairCache;

Map<String, String> get _canonOf {
  final c = _canonCache;
  if (c != null) return c;
  final m = <String, String>{};
  for (final p in kSpellingPairs) {
    m[p.us] = p.us;
    m[p.gb] = p.us;
  }
  if (kAcceptVocabSynonyms) {
    for (final p in kVocabPairs) {
      m[p.us] = p.us;
      m[p.gb] = p.us;
    }
  }
  return _canonCache = m;
}

Map<String, SpellingPair> get _pairIndex {
  final c = _pairCache;
  if (c != null) return c;
  final m = <String, SpellingPair>{};
  for (final p in [...kSpellingPairs, ...kVocabPairs]) {
    m[p.us] = p;
    m[p.gb] = p;
  }
  return _pairCache = m;
}

bool _isConsonant(String c) =>
    c.length == 1 && !'aeiou'.contains(c) && RegExp(r'[a-z]').hasMatch(c);

/// Canonical form of a single (already-lowercased-or-not) word.
String canonicalizeWord(String raw) {
  final w = raw.toLowerCase();
  if (w.isEmpty) return w;
  final mapped = _canonOf[w];
  if (mapped != null) return mapped;
  // -ise/-ize  (organise->organize); closed-set exceptions stay put.
  if (w.length > 4 && !_iseKeep.contains(w)) {
    if (w.endsWith('isation')) {
      return '${w.substring(0, w.length - 7)}ization';
    }
    if (w.endsWith('ise')) return '${w.substring(0, w.length - 3)}ize';
    if (w.endsWith('yse')) return '${w.substring(0, w.length - 3)}yze';
  }
  // -our/-or  (colour->color); len>5 skips our/four/hour/your/tour/flour.
  if (w.length > 5 && w.endsWith('our') && !_ourKeep.contains(w)) {
    return '${w.substring(0, w.length - 3)}or';
  }
  // consonant + re -> er  (centre->center); skips vowel+re (here/more/store).
  if (w.length > 4 && w.endsWith('re') && !_reKeep.contains(w)) {
    final c = w[w.length - 3];
    if (_isConsonant(c) && c != 'r') {
      return '${w.substring(0, w.length - 2)}er';
    }
  }
  // doubled-l before -ing/-ed/-er -> single l (travelling->traveling); len>=8
  // so fill/call/sell/spell (<=7) are never touched.
  if (w.length >= 8) {
    for (final suf in const ['lling', 'lled', 'ller']) {
      if (w.endsWith(suf)) {
        return w.substring(0, w.length - suf.length) + suf.substring(1);
      }
    }
  }
  return w;
}

/// Canonical key for a single word-bank/order TILE (may be a short phrase).
/// Lowercased + per-token canonicalized; preserves tile/word order (no article
/// stripping — tile placement is part of the answer).
String canonWordKey(String tile) {
  final w = tile.toLowerCase().trim();
  if (w.isEmpty) return '';
  return w.split(RegExp(r'\s+')).map(canonicalizeWord).join(' ');
}

/// Order- and spelling-tolerant equality for tile lists (word-bank, dialogue,
/// multi-blank): same length AND each tile canonically equal in order.
bool orderCanonMatches(List<String> picked, List<String> correct) {
  if (picked.length != correct.length) return false;
  for (var i = 0; i < picked.length; i++) {
    if (canonWordKey(picked[i]) != canonWordKey(correct[i])) return false;
  }
  return true;
}

bool _prefersGb(String locale) =>
    locale == 'en-GB' || locale == 'en-IN' || locale == 'en-AU';

String _variantLabel(String locale) {
  switch (locale) {
    case 'en-GB':
      return 'British';
    case 'en-IN':
      return 'Indian';
    case 'en-AU':
      return 'Australian';
    default:
      return 'US';
  }
}

/// A kind one-line tip when a correct answer used a variant spelling/vocab whose
/// form differs from the learner-locale's preferred form (works both ways + for
/// vocab). Returns null when there's nothing to teach. The screen throttles it.
String? spellingTip(String typed, String expected, String locale) {
  final t = typed.toLowerCase().trim();
  if (t.isEmpty) return null;
  final words =
      t.replaceAll(RegExp(r'[.!?,;:]'), '').split(RegExp(r'\s+'));
  final gb = _prefersGb(locale);
  for (final w in words) {
    final pair = _pairIndex[w];
    if (pair == null) continue;
    final preferred = gb ? pair.gb : pair.us;
    if (w != preferred) {
      return 'In ${_variantLabel(locale)} English it\'s "$preferred".';
    }
  }
  return null;
}
